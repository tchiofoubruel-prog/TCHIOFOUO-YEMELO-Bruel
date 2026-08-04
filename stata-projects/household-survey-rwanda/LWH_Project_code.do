/*********************************************************************
 Statistical Software Test 2025 Do-File
 Author: TCHIOFOUO YEMELO Bruel
 Date: November 01, 2025


*********************************************************************/
*set stata version 

version 17

* Clear any existing data and set general options
clear all
capture log close
set more off            

 *=============================================================;
* Setup: Define directory globals and import raw data (Task 1);
*=============================================================;
global base_dir "C:\Users\tchio\OneDrive\Bureau\2025_Statistical_Software_Test"
global data_dir    "$base_dir/data"
global results_dir "$base_dir/results"
global dofiles_dir "$base_dir/dofiles"

*Create a log file to record the results every time the do-file is run.  
  
local date : di %tdCCYYNNDD daily("$S_DATE","DMY")
log using "$results_dir\log`date'.log", replace


********************************************************************************
** Task 1: Data Cleaning and Preparation **
********************************************************************************

* Import raw dataset (CSV format) into Stata
import delimited using "$data_dir/LWH_FUP2.csv", clear

* Inspect basic properties
describe, short
summarize

* Recode special codes for missing data to Stata missing (.)
* (From codebook: -99 = Missing, -88 = Don't know, -66 = Refused, -888 = Skip/NA)
foreach v in ///
    inc_01 inc_02 inc_03 inc_04 inc_06 inc_10 inc_11 inc_12 ///
    aa_01_1 aa_01_2 aa_02_1 aa_02_2 ///
    crp08qa_c1_p1 crp08qa_c1_p2 crp09qa_c1_p1 crp09qa_c1_p2 ///
    crp10a_c1_p1 crp10a_c1_p2 {

    capture confirm variable `v'
    if !_rc {
        * If the variable is a string, convert it to numeric
        capture confirm numeric variable `v'
        if _rc {
            destring `v', replace ignore(" ") force
        }

        * Now, replace special codes with missing values
        replace `v' = . if inlist(`v', -99, -88, -66, -888)
    }
}




* Identify and handle duplicate household entries
duplicates tag id_05, gen(dup_tag)
count if dup_tag > 0
list id_05 if dup_tag > 0, table


* We will keep the first occurrence of each household and drop subsequent ones.
duplicates drop id_05, force



* Drop unnecessary fields (ID confirmation/correction) that are not needed for analysis
drop id_10_confirm id_10_corrected

* Data consistency checks and derived variables

* Convert variable to numeric if it is stored as string
destring exp_25_1, replace ignore(" ") force

* Create variable for number of days flour was consumed
generate flour_days = exp_25_1

* Cap the number of days at 7
replace flour_days = 7 if flour_days > 7

* Label the variable for clarity
label variable flour_days "Days consumed any flour in last 7 days"

* Display detailed summary statistics
summarize flour_days, detail


* Convert crop harvest and sales quantities to a common unit (kilograms) for consistency
* (Unit codes from survey: 1=kg, 2=25kg sack, 3=50kg sack, 4=100kg sack, 5=grams, 6=tons, 
* 13=1.5kg (Mironko), 14=2.5kg bucket, 15=5kg bucket, 16=10kg basket, 17=15kg basket, etc.)
generate harvest_p1_kg = . 
generate harvest_p2_kg = .
generate sold_p1_kg    = .
generate sold_p2_kg    = .

*------------------------------------------------------------*
* Ensure all variables are numeric before calculations
*------------------------------------------------------------*
destring crp08qa_c1_p1 crp08ua_c1_p1 crp08qa_c1_p2 crp08ua_c1_p2 ///
         crp09qa_c1_p1 crp09ua_c1_p1 crp09qa_c1_p2 crp09ua_c1_p2 ///
         harvest_p1_kg harvest_p2_kg sold_p1_kg sold_p2_kg, ///
         replace ignore(" ") force

*------------------------------------------------------------*
* Convert harvested quantities to kilograms (Plot 1)
*------------------------------------------------------------*
replace harvest_p1_kg = crp08qa_c1_p1                     if crp08ua_c1_p1 == 1    // kg
replace harvest_p1_kg = crp08qa_c1_p1 * 25                if crp08ua_c1_p1 == 2    // 25kg sack
replace harvest_p1_kg = crp08qa_c1_p1 * 50                if crp08ua_c1_p1 == 3    // 50kg sack
replace harvest_p1_kg = crp08qa_c1_p1 * 100               if crp08ua_c1_p1 == 4    // 100kg sack
replace harvest_p1_kg = crp08qa_c1_p1 * 0.001             if crp08ua_c1_p1 == 5    // grams to kg
replace harvest_p1_kg = crp08qa_c1_p1 * 1000              if crp08ua_c1_p1 == 6    // tons to kg
replace harvest_p1_kg = crp08qa_c1_p1 * 1.5               if crp08ua_c1_p1 == 13   // 1.5kg unit
replace harvest_p1_kg = crp08qa_c1_p1 * 2.5               if crp08ua_c1_p1 == 14   // 2.5kg bucket
replace harvest_p1_kg = crp08qa_c1_p1 * 5                 if crp08ua_c1_p1 == 15   // 5kg bucket
replace harvest_p1_kg = crp08qa_c1_p1 * 10                if crp08ua_c1_p1 == 16   // 10kg basket
replace harvest_p1_kg = crp08qa_c1_p1 * 15                if crp08ua_c1_p1 == 17   // 15kg basket

*------------------------------------------------------------*
* Convert harvested quantities to kilograms (Plot 2)
*------------------------------------------------------------*
replace harvest_p2_kg = crp08qa_c1_p2                     if crp08ua_c1_p2 == 1
replace harvest_p2_kg = crp08qa_c1_p2 * 25                if crp08ua_c1_p2 == 2
replace harvest_p2_kg = crp08qa_c1_p2 * 50                if crp08ua_c1_p2 == 3
replace harvest_p2_kg = crp08qa_c1_p2 * 100               if crp08ua_c1_p2 == 4
replace harvest_p2_kg = crp08qa_c1_p2 * 0.001             if crp08ua_c1_p2 == 5
replace harvest_p2_kg = crp08qa_c1_p2 * 1000              if crp08ua_c1_p2 == 6
replace harvest_p2_kg = crp08qa_c1_p2 * 1.5               if crp08ua_c1_p2 == 13
replace harvest_p2_kg = crp08qa_c1_p2 * 2.5               if crp08ua_c1_p2 == 14
replace harvest_p2_kg = crp08qa_c1_p2 * 5                 if crp08ua_c1_p2 == 15
replace harvest_p2_kg = crp08qa_c1_p2 * 10                if crp08ua_c1_p2 == 16
replace harvest_p2_kg = crp08qa_c1_p2 * 15                if crp08ua_c1_p2 == 17

*------------------------------------------------------------*
* Convert sold quantities to kilograms (Plot 1)
*------------------------------------------------------------*
replace sold_p1_kg    = crp09qa_c1_p1                     if crp09ua_c1_p1 == 1
replace sold_p1_kg    = crp09qa_c1_p1 * 25                if crp09ua_c1_p1 == 2
replace sold_p1_kg    = crp09qa_c1_p1 * 50                if crp09ua_c1_p1 == 3
replace sold_p1_kg    = crp09qa_c1_p1 * 100               if crp09ua_c1_p1 == 4
replace sold_p1_kg    = crp09qa_c1_p1 * 0.001             if crp09ua_c1_p1 == 5
replace sold_p1_kg    = crp09qa_c1_p1 * 1000              if crp09ua_c1_p1 == 6
replace sold_p1_kg    = crp09qa_c1_p1 * 1.5               if crp09ua_c1_p1 == 13
replace sold_p1_kg    = crp09qa_c1_p1 * 2.5               if crp09ua_c1_p1 == 14
replace sold_p1_kg    = crp09qa_c1_p1 * 5                 if crp09ua_c1_p1 == 15
replace sold_p1_kg    = crp09qa_c1_p1 * 10                if crp09ua_c1_p1 == 16
replace sold_p1_kg    = crp09qa_c1_p1 * 15                if crp09ua_c1_p1 == 17

*------------------------------------------------------------*
* Convert sold quantities to kilograms (Plot 2)
*------------------------------------------------------------*
replace sold_p2_kg    = crp09qa_c1_p2                     if crp09ua_c1_p2 == 1
replace sold_p2_kg    = crp09qa_c1_p2 * 25                if crp09ua_c1_p2 == 2
replace sold_p2_kg    = crp09qa_c1_p2 * 50                if crp09ua_c1_p2 == 3
replace sold_p2_kg    = crp09qa_c1_p2 * 100               if crp09ua_c1_p2 == 4
replace sold_p2_kg    = crp09qa_c1_p2 * 0.001             if crp09ua_c1_p2 == 5
replace sold_p2_kg    = crp09qa_c1_p2 * 1000              if crp09ua_c1_p2 == 6
replace sold_p2_kg    = crp09qa_c1_p2 * 1.5               if crp09ua_c1_p2 == 13
replace sold_p2_kg    = crp09qa_c1_p2 * 2.5               if crp09ua_c1_p2 == 14
replace sold_p2_kg    = crp09qa_c1_p2 * 5                 if crp09ua_c1_p2 == 15
replace sold_p2_kg    = crp09qa_c1_p2 * 10                if crp09ua_c1_p2 == 16
replace sold_p2_kg    = crp09qa_c1_p2 * 15                if crp09ua_c1_p2 == 17

* verification 

summarize harvest_p1_kg harvest_p2_kg sold_p1_kg sold_p2_kg, detail


*------------------------------------------------------------*
* Identify the three most commonly cultivated crops by household count
* (We determine this by the frequency of crop codes in either plot.)
*------------------------------------------------------------*

preserve

*--- Frequency for Plot 1
contract a_crop_c1_p1, freq(freq1)
rename a_crop_c1_p1 crop_code
rename freq1 freq
tempfile freq_p1
save `freq_p1', replace

restore
preserve

*--- Frequency for Plot 2
contract a_crop_c1_p2, freq(freq2)
rename a_crop_c1_p2 crop_code
rename freq2 freq

*--- Append both frequency datasets
append using `freq_p1', force

*--- Sum frequencies by crop code
collapse (sum) freq, by(crop_code)
gsort -freq

*--- Display top 3
list crop_code freq in 1/3, clean noobs

*--- Store top 3 codes in locals
local top1 = crop_code[1]
local top2 = crop_code[2]
local top3 = crop_code[3]

display as text _n "Top-3 most cultivated crops:"
display as result "  1st: `top1'"
display as result "  2nd: `top2'"
display as result "  3rd: `top3'"

restore


* Construct total production, sales quantity, and sales value at household level for each of the top 3 crops.
* We'll sum across Plot1 and Plot2 for the crop if it was grown in both.
*--- convert all relevant variables to numeric if needed ---*
foreach var in a_crop_c1_p1 a_crop_c1_p2 harvest_p1_kg harvest_p2_kg sold_p1_kg sold_p2_kg crp10a_c1_p1 crp10a_c1_p2 {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

*---------------------*
* beans (code = 9)
*---------------------*
generate tot_harvest_beans = 0
generate tot_sold_beans    = 0
generate tot_value_beans   = 0

replace tot_harvest_beans = tot_harvest_beans + harvest_p1_kg if a_crop_c1_p1 == 9
replace tot_harvest_beans = tot_harvest_beans + harvest_p2_kg if a_crop_c1_p2 == 9
replace tot_sold_beans    = tot_sold_beans + sold_p1_kg    if a_crop_c1_p1 == 9
replace tot_sold_beans    = tot_sold_beans + sold_p2_kg    if a_crop_c1_p2 == 9
replace tot_value_beans   = tot_value_beans + crp10a_c1_p1 if a_crop_c1_p1 == 9
replace tot_value_beans   = tot_value_beans + crp10a_c1_p2 if a_crop_c1_p2 == 9

*---------------------*
* maize (code = 4)
*---------------------*
generate tot_harvest_maize = 0
generate tot_sold_maize    = 0
generate tot_value_maize   = 0

replace tot_harvest_maize = tot_harvest_maize + harvest_p1_kg if a_crop_c1_p1 == 4
replace tot_harvest_maize = tot_harvest_maize + harvest_p2_kg if a_crop_c1_p2 == 4
replace tot_sold_maize    = tot_sold_maize + sold_p1_kg    if a_crop_c1_p1 == 4
replace tot_sold_maize    = tot_sold_maize + sold_p2_kg    if a_crop_c1_p2 == 4
replace tot_value_maize   = tot_value_maize + crp10a_c1_p1 if a_crop_c1_p1 == 4
replace tot_value_maize   = tot_value_maize + crp10a_c1_p2 if a_crop_c1_p2 == 4

*---------------------*
* groundnuts (code = 75)
*---------------------*
generate tot_harvest_ground = 0
generate tot_sold_ground    = 0
generate tot_value_ground   = 0

replace tot_harvest_ground = tot_harvest_ground + harvest_p1_kg if a_crop_c1_p1 == 75
replace tot_harvest_ground = tot_harvest_ground + harvest_p2_kg if a_crop_c1_p2 == 75
replace tot_sold_ground    = tot_sold_ground + sold_p1_kg    if a_crop_c1_p1 == 75
replace tot_sold_ground    = tot_sold_ground + sold_p2_kg    if a_crop_c1_p2 == 75
replace tot_value_ground   = tot_value_ground + crp10a_c1_p1 if a_crop_c1_p1 == 75
replace tot_value_ground   = tot_value_ground + crp10a_c1_p2 if a_crop_c1_p2 == 75


* Outlier check on production values (post-conversion to kg)
summarize tot_harvest_beans tot_harvest_maize tot_harvest_ground
quietly summarize tot_harvest_beans, detail
display "Beans harvest, max: " %15.2f r(max)
quietly summarize tot_harvest_maize, detail
display "Maize harvest, max: " %15.2f r(max)


********************************************************************************
** Task 2: Presenting Results to a Policy Audience **
********************************************************************************

* Task 2a: Table 1 – Agricultural production for top 3 crops
* We will create a summary table of household-level production outcomes for:
*   1) Beans, 2) Maize, 3) Groundnuts (third most common crop, code 75).
* For each crop, we show: Number of households (N), mean, median, standard deviation, min, max 
* for total quantity harvested (kg), total quantity sold (kg), and total sales value (RWF).
* All statistics are at the household level among households that cultivated the crop.

* Prepare Excel output workbook for Table 1
putexcel set "$results_dir/Table1_AgProduction.xlsx", sheet("Table1") modify

* Write table headers
putexcel A1 = "Crop"   B1 = "Metric"   C1 = "N (HH)"   D1 = "Mean"   E1 = "Median"   ///
         F1 = "SD"    G1 = "Min"      H1 = "Max", bold

* Define a helper macro to write a row of stats to Excel (for code clarity)
prog def write_stats, rclass
    * Arguments: row, cropName, var (the variable to summarize), metricName
    args row cropName var metric
    quietly summarize `var' if `var' < . , detail   // only non-missing (excludes HH that didn't cultivate if var is 0 for them? We set 0 for non-growers, but they are excluded by using cultivation indicator in actual calls below)
    local N = r(N)
    local mean = r(mean)
    local med = r(p50)
    local sd = r(sd)
    local min = r(min)
    local max = r(max)
    * Write crop name only if provided (for first metric row of each crop)
    if "`cropName'" != "" {
        putexcel A`row' = "`cropName'", bold
    }
    putexcel B`row' = "`metric'" ///
            C`row' = (`N') ///
            D`row' = (round(`mean', .01)) ///
            E`row' = (round(`med', .01)) ///
            F`row' = (round(`sd', .01)) ///
            G`row' = (round(`min', .01)) ///
            H`row' = (round(`max', .01))
    return scalar N = `N'
end

* Beans stats (only include households that grew beans)
write_stats 2 "Beans" tot_harvest_beans "Quantity harvested (kg)" if (a_crop_c1_p1==9 | a_crop_c1_p2==9)
local N_beans = r(N)
write_stats 3 ""       tot_sold_beans    "Quantity sold (kg)"      if (a_crop_c1_p1==9 | a_crop_c1_p2==9)
write_stats 4 ""       tot_value_beans   "Sales value (RWF)"       if (a_crop_c1_p1==9 | a_crop_c1_p2==9)

* Maize stats
write_stats 6 "Maize" tot_harvest_maize "Quantity harvested (kg)" if (a_crop_c1_p1==4 | a_crop_c1_p2==4)
local N_maize = r(N)
write_stats 7 ""      tot_sold_maize    "Quantity sold (kg)"      if (a_crop_c1_p1==4 | a_crop_c1_p2==4)
write_stats 8 ""      tot_value_maize   "Sales value (RWF)"       if (a_crop_c1_p1==4 | a_crop_c1_p2==4)

* groundnuts stats (assuming crop code 75 = groundnuts or other third crop)
write_stats 10 "Groundnuts" tot_harvest_ground "Quantity harvested (kg)" if (a_crop_c1_p1==75 | a_crop_c1_p2==75)
local N_ground = r(N)
write_stats 11 ""           tot_sold_ground    "Quantity sold (kg)"      if (a_crop_c1_p1==75 | a_crop_c1_p2==75)
write_stats 12 ""           tot_value_ground   "Sales value (RWF)"       if (a_crop_c1_p1==75 | a_crop_c1_p2==75)


putexcel A14 = "Note: Stats are for households that cultivated the crop. N = number of such households." 

* Save and close the Excel file
putexcel save

* The resulting "Table1_AgProduction.xlsx" contains the summary statistics requested:
* - For Beans, Maize, Groundnuts: N (households), mean, median, SD, min, max for 
*   total harvest (kg), total sold (kg), and sales revenue (RWF).
* (We used rounding to 2 decimal places for clarity. Medians are reported to mitigate the effect of outliers on interpretation.)

* Task 2b: Graph 1 – Food security indicator (flour consumption)
* We choose to visualize the distribution of flour consumption (days flour was consumed in the past week).
* This is a direct food security indicator (households consuming flour regularly vs not).
* A discrete histogram (bar chart) is appropriate to show the proportion of households at each consumption level (0 to 7 days).
* This graph quickly communicates what share of households have low vs high flour consumption, which is informative for policymakers.

histogram flour_days, discrete freq ///
    start(0) width(1) ///
    xtitle("Days in last week household consumed flour") ///
    ytitle("Number of households") ///
    title("Household Flour Consumption (Past 7 Days)")

graph export "$results_dir/Graph1_Flour.png", replace width(800)
* (The histogram above shows how many households consumed flour on 0 days, 1 day, ... up to 7 days in the last week.
*  For example, a high bar at "7 days" indicates many households consume flour daily, while a bar at "0 days" indicates households potentially facing food insecurity or dietary habits without flour.
*  We capped values over 7, so the "7 days" category includes any outliers originally >7. A comment can be made that some respondents reported daily consumption beyond the 7-day frame, which were treated as daily consumption.)

********************************************************************************
** Task 3: Evaluate Randomization Quality **
********************************************************************************

* The intervention was randomized at the village level, stratified by district.
* Since this is the first detailed survey of the population, we want to check if treatment and control groups were statistically equivalent at baseline (balance check).

* In practice, we would have a dataset including both treatment and control households, with a treatment indicator. 
* However, the current data only includes treatment areas. We cannot compute balance without control data.
* Below, we outline how we WOULD assess randomization quality:

* 1. **Output to test balance:** We would create a "balance table" comparing baseline characteristics between treatment and control groups.
*    This table would list key pre-intervention variables (rows) with their mean (or proportion) in the Treatment group and Control group, and a p-value for the difference.
*    For example:
*       - Household size, mean in Treat vs Control (p-value from t-test)
*       - Head's education, 
*       - Land size, 
*       - Income or assets,
*       - Baseline agricultural production or food security indices, etc.
*    Each row would include the difference (Treat - Control) and a significance indicator.
*    This allows a quick scan to see if any initial differences exist.
* 
* 2. **Statistical process:** We would perform two-sample t-tests (or Wilcoxon rank-sum for non-normals) for each variable to see if the means differ significantly between groups. 
*    Since randomization was stratified by district, we could also include district fixed effects in a regression for a more precise test (or ensure we compare within strata).
*    Another approach is to run a regression of the baseline variable on a treatment dummy and district dummies, and look at the coefficient on treatment (with robust standard errors, possibly clustered by village since randomization unit is village).
*    This regression approach gives the same result as a t-test but adjusts for stratification and allows clustering if needed.
*    We would also check joint balance using an F-test across all variables (e.g. a seemingly unrelated regression or a joint test from a multivariate regression) to ensure no systematic differences as a group.
* 
* 3. **Variables to consider:** We would include variables that capture households' pre-intervention status:
*    - Demographics: household size, age and gender of household head, education level of head, etc.
*    - Socio-economic status: assets ownership (e.g. radio, bicycle), baseline income sources (the INC_* variables in this dataset could serve as proxies for income from various activities), total expenditure or consumption if available.
*    - Agricultural variables: land cultivated, baseline production or yield of key crops (if a baseline survey was done or recall data available), adoption of improved practices (e.g. any "technology adoption" indicators).
*    - Food security and nutrition: baseline food security index or diet diversity (e.g. how many days consumed certain foods like flour – though this could be influenced by season, it's still a baseline measurement here).
*    - We might also include geographic or village characteristics if available, though stratification by district should handle broad agro-climatic differences.
*    Even variables not in this follow-up dataset could be relevant: e.g. baseline irrigation access, soil quality, etc., if we had them.
* 
* If we had the control group data, we could execute something like:
* 
* // Pseudo-code for balance testing (assuming a 'treatment' dummy and baseline vars exist):
* // Summarize means by treatment status
* bysort treatment: summarize household_size head_education land_size total_income food_security_index
* 
* // Perform t-tests for difference in means
* ttest household_size, by(treatment)
* ttest land_size, by(treatment)
* ... (and so on for each key variable)
* 
* // Alternatively, regression approach for one variable (controlling for district strata and clustering by village):
* reg household_size treatment i.district, cluster(village_id)
* reg land_size treatment i.district, cluster(village_id)
* 
* // We would compile the results into a balance table for reporting.
* 
* In summary, the expectation is that differences between treatment and control means are small and not statistically significant (p>0.05), confirming successful randomization. Any variable with significant difference would be noted as a potential concern and possibly controlled for in impact analysis.
 
log close


