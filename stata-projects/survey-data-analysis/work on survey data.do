*III) This section pertains to codes applied in class for learning how to handle survey data. The course was taught by Émilie Caldeira, Associate Professor at the Center for Studies and Research in International Development (CERDI) at Université Clermont Auvergne.

////////////////////////////////////////////////////////////////////////////////TD 1: Sampling Weights//////////////////////////////////////////////////////////////////////////////////////////

// 1) Write the initial commands to be introduced at the start of each do-file.
// - Remove all data from memory.
clear all
// - Close the log if it is open.
capture log close
// - Increase the maximum number of variables and the number of variables in the model. What are the default values?
set maxvar 10000 
set matsize 800  
// - Make sure the do-file runs to completion without user intervention.
set more off

// 2) Indicate the data source and the backup location.
// - Create two "globals" to indicate where the data is and where to save the results.
global sourcedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Data"
global savedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Results"
// - Create a log file to record the results every time the do-file is run. (Good practice: assign the current date to the log-file).
local date 20191022
log using "$savedata\log`date'.log", replace

// 3) Use the dataset containing the sampling weights.
use "$sourcedata\weights_psu.dta"

// 4) Explore the dataset.
// - How many PSUs are included? What do "Domain" and "Strata" mean? How many are there? (Refer to the course).
count
browse

tab str
tab domain
// - What does n_hh_pre represent? How many households are there per PSU on average? Plot a histogram of the number of households per PSU.
sum n_hh_pre
hist n_hh_pre

// 5) Selection of EAs.
// - Show (generally and by each stratum) that "The selection of EAs in each stratum is random and occurs using a probability proportional to size (Probability Proportional to Size). The size measure is represented by the number of households living in each EA: higher sampling probability for EAs with more housing units (HU) in the 2001 census."
pwcorr pr_ea n_hh_pre, star(0.1)
scatter pr_ea n_hh_pre
scatter pr_ea n_hh_pre, by(str)
bysort str: sum pr_ea
// - We have the results from the census re-conducted by INSTAT for the 480 selected EAs (n_hh_post). Show that the two are close but some EAs expanded while others reduced.
scatter n_hh_pre n_hh_post

// 6) Household inclusion probability.
// * Reminder: The complete housing census is then used to randomly select 8 HUs for each of the sampled EAs.
// - Calculate the probability of inclusion for a household within each EA (PSU).
gen pr_inclusion=8/n_hh_post
// - Calculate the probability of inclusion of a household in the sample. 
// (= probability of inclusion of a household within each selected EA * sampling probability for each EA (pr_ea)).
gen pr_inclusion_global=pr_inclusion*pr_ea
// - Check the value of this result by comparing it with pr_hh and then delete the variable you created.
scatter pr_inclusion_global pr_hh
sum pr_hh pr_inclusion_global
drop pr_inclusion
drop pr_inclusion_global
// - Retrieve the sampling weight w (inverse of the inclusion probability).
*EAs may vary in size (in terms of HUs), but we have 8 HUs per EA, regardless of their size. This means that households in smaller EAs have a higher probability of being included in the sample.
gen w_check=1/pr_hh
scatter w_check w
drop w_check
sum w
*Note that weights are the same for all households in an EA. This is why we only have 480 observations. 

// 4) Adjustments after the survey
// - Ask Stata to check that there are 8 households interviewed per EA.
assert respendent == 8
*Stata returns an error message, the assertion is false
// - Ask it to list the cases where this is not true.
list respendent if respendent!=8
*There is one EA where only 6 households have been interviewed*
// - How was the "first correction" (corr__factor_f1) calculated to account for this bias in the sampling weights? 
tab corr__factor_f1
list respendent corr__factor_f1 if respendent!=8
*We have that corr__factor_f1=8/respendent (when 6 respondents instead of 8, we give a weight, not of 1 (8/8) but of 8/6: we over-weight them because there are fewer than normal)


// - How many households have their interview considered invalid? 
tab no__invalid_hhs
*327 EAs have no invalid household, 2 had 4 invalid households*
// - How was the "second correction" (corr__factor_f2) calculated to account for this bias in the sampling weights? 
list corr__factor_f2 no__invalid_hhs
*The second correction factor is corr__factor_f2=(8-no_invalid_hhs)/8
// - Retrieve the value of the final adjustment (ww_w). 
gen w_check=w*corr__factor_f2
scatter w_check ww_w
*The first correction factor (corr__factor_f1), has not been used (despite the name of the variable!)
//*Notice that it is different from 1 only for one EA
//Normally, we should have: 
gen w_checkcomplet=w*corr__factor_f1*corr__factor_f2
scatter w_checkcomplet ww_w

*For each district, INSTAT has made projections on the total number of households in 2005, based on the 2001 census. The weights of each PSU are multiplied by an adjustment factor for each specific district so that the sum of the weights of households in each district matches the projected number of households.
// - How does "corr_fact_post_stratif" work?
tab corr_fact_post_stratif_
bysort district: tab corr_fact_post_stratif_
*There is only one adjustment factor for district except for Tirana (two factors)*
//*The second factor refers to the additional 25 EAs included in the sample
// - Calculate the final weights and check if they match final_weights.
replace w_check= ww_w* corr_fact_post_stratif_
scatter w_check final_weights
drop w_check 

// 5) Other file with sampling weights.
// - Load the other dataset (weights_cl.dta)
clear
use "$sourcedata\weights_cl.dta"
browse


//////////////////////////////////////////////////////////////////////////////// TD 2: Household roster/////////////////////////////////////////////////////////////////////////////////////////

// 1) Write the initial commands to be included at the beginning of each do-file.
// - Delete all data in memory.
// - Close the log if open.
// - Ensure the do-file runs to completion without user intervention.
clear all
capture log close
set more off

// 2) Indicate the data source and saving location.
// - Create two global variables to specify where the data is located and where to save the results.
// - Create a log file to record the results each time the do-file is run. (Good practice: assign the log-file the current date).
global sourcedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Data"
global savedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Results"
local date 20190313
log using "$savedata\log`date'.log", replace

// 3) Use the data file related to the household roster.
use "$sourcedata\household_rosterA_cl.dta"

// 4) Familiarize yourself with the database.
// - Understand the names of the variables (*See how the labels help understand the question the variable refers to*).
browse
*For example, the variable "m1a_q02" refers to module 1 (HOUSEHOLD ROSTER) a (HOUSEHOLD MEMBERS AND PARENTS), question 2 (SEX) from the alb05hhqeng file.
// - What is the sample size?
count
*17,302 individuals*
// - Understand the construction of household and individual identification codes.
// *Each household is identified by two variables m0_q00 (psu) and m0_q01 (household ID)
// *hhid is the combination of both variables
order hhid m0_q00 m0_q01
sort hhid m0_q00 m0_q01
browse
*For example, m0_q00==5 & m0_q01==8, hhid==501
*Next, we have the variable m1a_q00, which identifies individuals within the household (ID code).
// - Recreate the hhid variable. Use the "concat" variable.
gen str_m0_q00 = string(int(m0_q00),"%01.0f") // %01.0f because we want 'm0_q00' as it is (1 to 3 digits but not padded, and no longer considered digits)
gen str_m0_q01 = string(int(m0_q01),"%02.0f") // %02.0f because we want 'm0_q01' to have 2 digits (if less than 10, add a leading zero, force 2 digits)
egen Hid = concat(str_m0_q00 str_m0_q01) // Combines both variables
destring Hid, replace // Convert back to numeric
br str_m0_q00 str_m0_q01 Hid hhid
drop Hid

// - How many households are in the sample?
*The variable m1a_q00 counts all individuals in a household. 
*Individual 1 is present in every household. Thus, we can type:
count if m1a_q00==1
*There are 3,840 households in the sample
// - This number does not match the figure provided by INSTAT and the World Bank (Table 5). Check for duplicate individuals.
duplicates report hhid m1a_q00

// 5) Merge with the database containing the sampling weights.
// - Merge
*The variable identifying the PSU (EAs) is m0_q00
*We need to use a "many to one merge" because the same weight applies to all households in an EA.
merge m:1 m0_q00 using "$sourcedata\weights_cl.dta" 
// - Verify that the merge worked correctly.
tab _merge
*Another way
assert _merge == 3
*If the merge is correct (all observations merged), Stata will not return any result
drop _merge

// 6) Declare the sampling weights.
help svyset
help weight  
svyset m0_q00 [pweight=weight]
// svyset m0_q00 [pweight=weight], strata (str_m0_q00) /*more accurate*/

// 7) Perform descriptive statistics.
// - Calculate the average household size and highlight the importance of sampling weights. 
*Reminder: m1a_q00 is the ID code. So max(m1a_q00) is the largest idcode
*We create a variable that is the max of the idcode. 
bysort hhid: egen hh_size=max(m1a_q00)
// Household size ranges from 1 to 6:
sum hh_size 
// Check various results:
sum hh_size
sum hh_size if m1a_q00 == 1 // *The "if" condition ensures we count each household only once (1 is household head)
sum hh_size if m1a_q00 == 1 [iw=weight]
svy: mean hh_size if m1a_q00 == 1
mean hh_size if m1a_q00 == 1 [pw=weight]
*The mean is 4.44
// - What is the proportion of men and women in the population?
svy: tab m1a_q02
tab m1a_q02 /*incorrect*/
tab m1a_q02 [iw=weight]
// - What is the proportion of married individuals?
svy: tab m1a_q06
// - What is the proportion of household members not present?
svy: tab m1a_q10  
// - What is the proportion of household heads not present?
svy: tab m1a_q10 if m1a_q00 == 1
*Recall the definition of a household.
// - How many individuals have a spouse/partner present in the household?  
tab m1a_q07 
tab m1a_q07 if m1a_q06==1
*8,035 individuals have a partner in the household (8,017 married)
// Imagine that we want to associate the spouse's age (if present) with each individual who has a spouse in the household. How to do it? 
*We use the variables "m1a_q08" (partner id: refers to the individual's number in the household that corresponds to the spouse), "m1a_q06" (married), and "m1a_q5y" (age).
*Check that m1a_q08 is not missing for the 8,017 individuals.
sum m1a_q08 if m1a_q06==1

*This command indicates that we need to take the age of the "spouse" ID within the household.
bysort hhid: gen age_spouse= m1a_q5y[m1a_q08] if m1a_q06==1
sum age_spouse /*one missing*/ 
order hhid m1a_q00 m1a_q08 m1a_q5y age_spouse m1a_q06 m1a_q07 m1a_q02
browse 
// - Make a scatterplot with the partner's age.
corr m1a_q5y age_spouse
scatter m1a_q5y age_spouse
// - What is the average age difference between spouses?
gen diff_age = m1a_q5y - age_spouse
svy: mean diff_age /*incorrect because it mixes everyone, all men and all women*/
codebook m1a_q02  /*gender*/
svy: mean diff_age if m1a_q02==1
svy: mean diff_age if m1a_q02==2
*Other possibilities:
mean diff_age if m1a_q02==2 [pw=weight]
sum diff_age if m1a_q02==2 [iw=weight]
// - Bonus: Why are there different results between men and women? 
*Do all married people have a non-missing value for m1a_q08?
count if m1a_q07==1 & m1a_q08==. /*yes*/  
*Are there errors in the variable m1a_q07 (e.g., hhid 33003)? 
list m1a_q00 m1a_q06 m1a_q07 m1a_q08 m1a_q10 if hhid==33003 
list hhid m1a_q00 m1a_q06 m1a_q07 m1a_q08 if m1a_q10==2 & m1a_q06==1 /*The problem comes from the absence of household members: m1a_q08 is not asked if the spouse is not present in the household*/

// - Bonus: Can we explain the age difference by the husband's age? 
svy: reg diff_age m1a_q5y if m1a_q02==1 

// 8) Close the log.
log close



////////////////////////////////////////////////////////////////////////////////TD 3 : Education/////////////////////////////////////////////////////////////////////////////////////////////// 

// 1) Write the initial commands to introduce at the beginning of each do-file.
// - Delete all data in memory.
// - Close the log if open.
// - Ensure that the do-file runs to completion without user intervention.
clear all
capture log close
set more off

// 2) Indicate the source of the data and the location for saving the results.
// - Create two "globals" to indicate where the data is located and where to save the results.
// - Create a log file to record results each time the do-file is run. (Good practice: assign the current date to the log file).
global sourcedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Data"
global savedata "C:\Users\bruel\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Results"
local date 20190313
log using "$savedata\log`date'.log", replace

// 3) Use the education data file.
use "$sourcedata\educationB_cl.dta"

// 4) Merge the database with the Roster and sampling weights.
// - Since the individual identifier (ID code) varies between the databases, change its name.
// * Its name is m2b_q00 in the file and m1a_q00 in the "household roster".
rename m2b_q00 m1a_q00
// - Merge the database with the "roster" database (check the help for "merge").
merge 1:1 hhid m1a_q00 using "$sourcedata\household_rosterA_cl.dta"
drop _merge

// - Merge the database with the "sampling weights" database (remember to declare your survey data).
merge m:1 m0_q00 using "$sourcedata\weights_cl.dta"
drop _merge
br m0_q00 weight m0_q01 m1a_q00
svyset m0_q00 [pweight=weight]

// 5) Enrollment rate by age.
// - Which variable gives information on school enrollment (see questionnaire/database)?
count
// We have one piece of information per individual: 17,302.
* Let's look at the variable: tab m2b_q08 Yes 1 No 2
tab m2b_q08
codebook m2b_q08
* 4,024 individuals are enrolled.
tab m2b_q08 [iw=weight]
* 26.82% of the population aged 6 and above is enrolled.
// - Calculate the enrollment rates by age group (above 6 years old) using the bysort and table functions.
// * Enrollment rate by age?
* Simple but hard to read:
bysort m1a_q5y: sum m2b_q08 [iweight=weight]
// * Another option but still hard to read:
table m1a_q5y [iweight=weight], stat(fvpercent m2b_q08)
// - Recode the variable to facilitate interpretation (you can relabel the variable). Redo the table.
// * Replace 2 (not enrolled) with zero.
recode m2b_q08 (2 = 0)
table m1a_q5y [iweight=weight], stat(fvpercent m2b_q08)
// * You can relabel to display the labels Yes and No.
label define labm2b_q08 0 "No" 1 "Yes"
label value m2b_q08 labm2b_q08
// - Restrict the table to individuals aged between 6 and 30 years.
table m1a_q5y [iweight=weight] if m1a_q5y>5 & m1a_q5y<30, stat(fvpercent m2b_q08)
// * The inrange command implies that x must be between 6 <= x <= 30
table m1a_q5y [iweight=weight] if inrange(m1a_q5y, 6, 30), stat(fvpercent m2b_q08)
// - Find another way to represent the enrollment rates using the "collapse" function.
// a) Preserve the dataset.
preserve
// b) Keep only individuals who answered the question.
keep if m2b_q08!=.
// c) Use the "collapse" function to calculate the averages.
collapse (mean) m2b_q08 [iw=weight], by(m1a_q5y)
count
list m1a_q5y m2b_q08  
// d) Represent the enrollment rates by age.
line m2b_q08 m1a_q5y 
// e) Represent the enrollment rates by age for those between 6 and 30 years old.
line m2b_q08 m1a_q5y if m1a_q5y>=6 & m1a_q5y<=30 
line m2b_q08 m1a_q5y if inrange(m1a_q5y, 6, 30) 
// f) Highlight the enrollment decline at the end of primary (14) and secondary (18/19).
line m2b_q08 m1a_q5y if inrange(m1a_q5y, 6, 30), xline(14) xline(18)
// g) Restore the dataset.
restore

// 6) Enrollment rate by age group.
// - Using the "inrange" option
// Let's say we want to get the enrollment rate for people aged 6 to 9, 10-12, and 15-19.
// * One option is to use the inrange function: for example, for individuals aged between 6-9: the option if inrange(m1a_q5y, 6, 9) means if the age variable is in the range 6-9.
// * See help for inrange(z,a,b): Description:  1 if it is known that a < z < b; otherwise, 0
sum m2b_q08 [iw=weight] if inrange(m1a_q5y, 6, 9)

// - Using the "scalar" + "sum" command
* If we have different groups and want to use a single command, we can use the "scalar" command to define the boundaries:
scalar lb1 = 6
scalar ub1 = 9
scalar lb2 = 10
scalar ub2 = 12
scalar lb3 = 13
scalar ub3 = 14
scalar lb4 = 15
scalar ub4 = 19

* The "scalar dir" command asks Stata to show the values of the scalars.
scalar dir

* Loop:
* The "inrange" command asks x to be between lb`i' <= x <= ub`i'
forvalues i=1/4 {
    sum m2b_q08 [iw=weight] if inrange(m1a_q5y, lb`i', ub`i')
}
// * Unreadable because we don't know the cohort
* We can also ask Stata to display the cohort before each summarize.
forvalues i=1/4 {
    display "Age cohort" lb`i' "-" ub`i'
    sum m2b_q08 [iw=weight] if inrange(m1a_q5y, lb`i', ub`i')
}

// * With this command, we can easily change the age ranges for which we want to calculate the enrollment rate.
// + Recreate with the scalar function if we want the rates for 6-12, 13-14, 15-16, and 17-19, we just need the high and low boundaries.
scalar lb1 = 6
scalar ub1 = 12
scalar lb2 = 13
scalar ub2 = 14
scalar lb3 = 15
scalar ub3 = 16
scalar lb4 = 17
scalar ub4 = 19
* The "scalar dir" command asks Stata to show the values of the scalars.
scalar dir

forvalues i=1/4 {
    display "Age cohort " lb`i' "-" ub`i'
    sum m2b_q08 [iw=weight] if inrange(m1a_q5y, lb`i', ub`i')
}

// 7) Construct a variable for the number of completed years of schooling.
// - Use the variables m2b_q04 and m2b_q05 (highest level completed, which grade).
tab m2b_q04
tab m2b_q05

// - How many years of schooling does each level correspond to? (Look up information on the education system structure in Albania: http://www.euroeducation.net/prof/albanco.htm + check the codebook).
* Primary school: 6 to 14 years (8 years).
* Then, vocational school and secondary (4 years).
* Let's check the codebook.
codebook m2b_q04

// - Build a variable for the number of years of education: m2b_q04 is the grade they are in (primary, secondary, etc.) and m2b_q05 is the number of years completed in that grade. Depending on the grade, add the number of years completed in previous grades.
gen sy=0 if m2b_q04==0
label var sy "completed years of schooling"
replace sy=m2b_q05 if m2b_q04==1
replace sy=8+m2b_q05 if m2b_q04==2
replace sy=8+m2b_q05 if m2b_q04==3
replace sy=8+m2b_q05 if m2b_q04==4

// * We consider 4 years of secondary education.
replace sy=8+4+m2b_q05 if m2b_q04==5
replace sy=12+m2b_q05 if m2b_q04==6
// * We consider 4 years of university education.
replace sy=16+m2b_q05 if m2b_q04==7 | m2b_q04==8
tab sy

// * We have 14,291 observations for sy corresponding to individuals who answered "yes" to m2b_q03.
tab m2b_q03
codebook m2b_q03
sum m1a_q5y if m2b_q03==2
replace sy=0 if m2b_q03==2
tab sy

// - Build a variable for the number of years of education by age, for individuals aged 25 and above.
table m1a_q5y [iw=weight] if m1a_q5y>=25, stat(mean sy)
// * We can add frequencies.
table m1a_q5y [iweight=weight] if m1a_q5y>=25, stat(mean sy freq)

// * Note: in this case, it was possible (with some assumptions) to construct a "years of education" variable.
// * When this is not possible, you can use the 'education level' variable as a qualitative variable (creating multiple dummies).

// 8) Close the log.
log close


//////////////////////////////////////////////////////////////////////////////// TD 4: Poverty//////////////////////////////////////////////////////////////////////////////////////////////////

// Start with the usual block of commands
clear all
capture log close
set more off
global sourcedata "C:\Users\emcaldei\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Data"
global savedata "C:\Users\emcaldei\Documents\Documents\1 - COURS\5-  Analyse de données d'enquête\Data\Results"
local date 2019xxxx
log using "$savedata\log`date'.log", replace

// Merge the datasets household_rosterA, weights, educationB_cl.  
use "$sourcedata\educationB_cl.dta"
rename m2b_q00 m1a_q00
*Merge with Roster
merge 1:1 hhid m1a_q00 using "$sourcedata\household_rosterA_cl.dta"
drop _merge
*Merge with sampling weights
merge m:1 m0_q00 using "$sourcedata\weights_cl.dta"
drop _merge

// Merge the dataset with the file providing information on household poverty  
merge m:1 hhid using "$sourcedata\poverty.dta"
*915 observations were not merged
*These are observations where there is no information on poverty. We drop them from the sample
drop if _merge==1
drop _merge

// Declare the sample weights
svyset m0_q00 [pweight=weight]

// Build poverty indicators:

// 1. Poverty rate, poverty gap, and severity of poverty
// In the database, you already have the variables: poor, povgap, and sevpov
svy: mean poor
svy: mean povgap
svy: mean sevpov

// Otherwise, you can use the poverty command
help poverty
* If the command is not installed 
ssc describe poverty
ssc install poverty

// rcons is the variable 'per capita consumption' 
// abline is the poverty line 
sum abline
// absolute poverty line = 4891

// You need the variables rcons and abline to construct the poverty rate (h), then povgap (pgr) and sevpov (fgt3)
poverty rcons [aw=weight], line(4891) h
poverty rcons [aw=weight], line(4891) pgr
poverty rcons [aw=weight], line(4891) fgt3

// You can also generate all the indices together (we get Income gap ratio %, Poverty gap ratio %, and Index FGT(2.0) *100)
poverty rcons [aw=weight], line(4891) all

// 2. Poverty rate in urban and rural areas
svy: mean poor, over(m0_ur)
poverty rcons [aw=weight] if m0_ur==1, line(4891) h 
poverty rcons [aw=weight] if m0_ur==2, line(4891) h
// 17.7% of the population is poor, and the poverty incidence is 10.7% in urban areas and 23.1% in rural areas.  

// 3. Poverty rate for the population living in male- and female-headed households.
// We need to create a variable that identifies whether the household head is a man;
// m1a_q02 contains the gender of each individual
codebook m1a_q02
gen male_hh=0
replace male_hh=1 if m1a_q00==1 & m1a_q02==1
tab male_hh
// The last replace only affects the observation corresponding to the household head (m1a_q00==1).
// How can we apply this information to other household members?
bysort hhid: egen male_headed=max(male_hh)
svy: tab male_headed 
// 93% of Albanians live in male-headed households. 
svy: mean poor, over(male_headed)
// The poverty rate is higher for individuals in male-headed households. 
// Explanation? Migration > the household head migrates and sends transfers to the woman, who is then considered the household head. 

// 4. Poverty ratio for the population living in households where the head has:
// (i) no education
// (ii) completed primary education, 4 years; 
// (iii) completed primary education, 8 years;
// (iv) completed secondary or higher education.

*We have the variable m2b_q06 (highest diploma) to measure the education level of the household head. 
codebook m2b_q06
gen educ=m2b_q06
replace educ=3 if m2b_q06>=3
tab educ
// There is an issue with the variable educ / 
// Too many individuals appear as having "completed secondary education and above". Why?
// Let's compare with m2b_q06:
tab m2b_q06
// This comes from how Stata handles missing data in an inequality. *When a variable is missing (.), Stata treats the inequality as satisfied.  
// If m2b_q06 is missing for an observation, the inequality is perceived as true.
count if m2b_q06>=3
count if m2b_q06>=3 & m2b_q06!=.
// When there is just an inequality, we must specify that the variable should not be missing. 
// We first drop the variable
drop educ
// We modify the last replace:
gen educ=m2b_q06
replace educ=3 if m2b_q06>=3 & m2b_q06!=.
tab educ

// We are not finished yet: the variable m2b_q06 does not exist for IDs that have never attended school
// We define educ for IDs that have never attended school
codebook m2b_q03
tab educ if m2b_q03==2
replace educ=0 if m2b_q03==2
svy: tab educ

// We create the education variable for the household heads
gen educ_h=educ if m1a_q00==1
// Then, we assign this variable to all household members. 
bysort hhid: egen educ_head=max(educ_h)
// 248 missing values generated, why? 
count if educ==. & m1a_q00==1
// For 55 household heads, we have no information on education.  
sort m1a_q00 educ
order m1a_q00 educ
browse /*see 3584-3638*/
// Missing education data for these household heads
order m1a_q00 educ m2b_q03 m2b_q04 m2b_q05 m2b_q06

// Create labels for the values (short and without spaces)
label define education 0 "No_edu" 1 "Compl_primary_4y" 2 "Compl_primary_8y" ///
label values educ_head education 
label variable educ_head "Education of the household head"
tab educ_head

(*If we want to drop the label
*label drop education
*tab educ_head)

// The education status of the household head is:
svy: tab educ_head if m1a_q00==1

*****Calculate poverty rates by education status for household heads
svy: mean poor, over(educ_head)

// 5. Calculate the poverty rate for children (i.e., individuals under 15 years old).
*By using if m1a_q00==1, we restrict the sample to one observation per household.
svy: mean poor if m1a_q00==1, over(educ_head)

// There is a correlation between education level and poverty incidence
svy: mean poor if m1a_q5y<=14
svy: mean poor if m1a_q5y<15
// 24.7% of children live below the poverty line. 

// 6. Poverty rate by household size
// First, we need to generate the "household size" variable (the famsize variable does not count household members who are not present, for consumption-related reasons) 
bysort hhid: egen hh_size=max(m1a_q00)

// Then, we have several options
svy: mean poor, over (hh_size)
// Or:
table hh_size [pweight=weight], c(mean poor freq) 

// We can also calculate the poverty rate for the population living with 1-2, 3-4, and 5 or more members.
svy: mean poor if hh_size<=2
svy: mean poor if hh_size>=3 & hh_size<=4
svy: mean poor if hh_size>4

// Poverty is strongly correlated with household size.

// 6. Additional Exercises
// 6.1 Build a variable for the father's education level 
// 6.2 Create a label for this variable

// The difficulty comes from the fact that the father's education must be extracted from 2 separate variables depending on whether the father lives in the household or not. 
// Furthermore, the two variables take different values, so they must be harmonized. 
