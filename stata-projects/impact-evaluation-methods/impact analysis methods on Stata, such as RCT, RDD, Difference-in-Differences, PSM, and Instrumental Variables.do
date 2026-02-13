*II) This second part consists of all the codes used during our guided work for the impact analysis course, led by Mr. Melchior Solal CLERC, a PhD candidate at CERDI, and with course supervisor Jordan Loper, Associate Professor of Economics at the Department of Economics of Clermont Auvergne University, CERDI. During this course, we replicated various impact analysis methods on Stata, such as RCT, RDD, Difference-in-Differences, PSM, and Instrumental Variables. I will now provide the different codes, specifying the articles we used for replication.

*****A) RCT*************************************************************************************************************************** 
**************************************************************************************************************************************
************** TD 1, "Does Information Break the Political Resource Curse? Experimental Evidence from Mozambique" **************
**************************************************************************************************************************************

*Here we have replicated RCT methode use the paper "Does Information Break the Political Resource Curse? Experimental Evidence from Mozambique" by Alex Armand, Alexander Coutts, Pedro C. Vicente, and Inês Vilela 2020.

clear all 
set more off 
set matsize 800

*** Import the dataset

cd "_____"

use base_Mozambique.dta
	
xtset hh_id year

*** Many control variables: let's create some groups to organize them

global ld_contr		"ld_age ld_age2 ld_educ_2 ld_educ_3 ld_rel_muslim ld_ethn_macua ld_ethn_maconde ld_adults_HH ld_a16 ld_married" 				// Controls for community regressions (leader)
global hh_contr		"gender age age2 educ_2 educ_3 rel_muslim ethn_macua ethn_maconde hh_size a16 married sub_farmer" 								// Controls for individual regressions (households)
global ldvi_contr	"strata_rnd1-strata_rnd3 infrastructure nat_res num_tables_14 distpalma methn_macua methn_maconde meduc_3" 						// Controls for community regressions (communities)
global vi_contr		"district1-district10 strata_rnd2-strata_rnd3 infrastructure nat_res num_tables_14 distpalma methn_macua methn_maconde meduc_3" // Controls for individual regressions (community) 
			
********************************************************************************************
***************************************** Table 1 ****************************************
********************************************************************************************

*** Replication of the table	
			
reg ACLED tc1 tc2 $ld_contr $ldvi_contr L.ACLED if year == 2017 & villobs == 1
est sto A1
reg GDELT tc1 tc2 $ld_contr $ldvi_contr L.GDELT if year == 2017 & villobs == 1
est sto A2
reg ACLED_GDELT tc1 tc2 $ld_contr $ldvi_contr L.ACLED_GDELT if year == 2017 & villobs == 1
est sto A3
reg symp_violence tc1 tc2 $hh_contr $vi_contr L.symp_violence if year == 2017, cl(ae_id)
est sto A4
reg invol_violence tc1 tc2 $hh_contr $vi_contr L.invol_violence if year == 2017, cl(ae_id)
est sto A5

esttab A1 A2 A3 A4 A5, keep(tc1 tc2) se r2


*** Robustness test without time lag (footnote 13), ensuring to compare similar samples!

reg ACLED tc1 tc2 $ld_contr $ldvi_contr if year == 2017 & villobs == 1 & L.ACLED!=.	
est sto D1
reg GDELT tc1 tc2 $ld_contr $ldvi_contr if year == 2017 & villobs == 1 & L.GDELT!=.
est sto D2
reg ACLED_GDELT tc1 tc2 $ld_contr $ldvi_contr if year == 2017 & villobs == 1 & L.ACLED_GDELT!=.
est sto D3
reg symp_violence tc1 tc2 $hh_contr $vi_contr if year == 2017 & L.symp_violence!=., cl(ae_id)
est sto D4
reg invol_violence tc1 tc2 $hh_contr $vi_contr if year == 2017 & L.invol_violence!=., cl(ae_id)
est sto D5
			
esttab D1 D2 D3 D4 D5, keep(tc1 tc2) se r2

*** Complete the table with the mean, example with the first column
mean ACLED if tc1==0 & tc2==0 & year == 2017 & villobs == 1


********************************************************************************************
***************************************** Figure 2 *****************************************
********************************************************************************************

*** Preliminary regressions

reg ld_info tc2 tc1	$ld_contr $ldvi_contr if year == 2017 & villobs == 1	
est sto ld_info

reg ld_benef tc2 tc1 $ld_contr $ldvi_contr if year == 2017 & villobs == 1	
est sto ld_benef 

reg ld_rs tc2 tc1 $ld_contr $ldvi_contr if year == 2017 & villobs == 1	
est sto ld_rs 

reg ld_violence tc2 tc1	$ld_contr $ldvi_contr if year == 2017 & villobs == 1	
est sto ld_violence

reg el_capture tc2 tc1 $ld_contr $ldvi_contr if year == 2017 & villobs == 1	
est sto el_capture

*** Generate the figure 
coefplot (ld_info) (ld_benef ) (ld_rs) (ld_violence) (el_capture), keep(tc1 tc2)||, vertical yline(0, lcolor(black) lpattern(-)) ytitle("Marginal effect") /// 
yscale(range(-0.4 0.6)) ylabel(-0.4(0.2)0.6) order(tc1 tc2)
	
********************************************************************************************
************ Table B2 (Appendix) : Balance test (partial replication) ********************
********************************************************************************************

*** Column 3 : 

*** Generate a dummy "treated"
gen t = 1 if tc1==1 | tc2==1
replace t=0 if t==.

*** Regress age on the dummy
reg age t if year == 2016, cl(ae_id)

*** Column 4 (same principle for 5 and 6) : 

*** Note: the ttest is the usual test for difference of means 
ttest age if year==2016 & tc2==0, by (tc1)
ttest hh_size if year==2016 & tc2==0, by (tc1)


*B) RDD *************************************************************************************************************************** 
**************************************************************************************************************************************
************** TD 2, "Legal Origins and Female HIV" By Siwan Anderson 2020 **************
************************************************************************************************************************************** 

**** Here, we replicated the Regression Discontinuity Design (RDD) approach based on the paper of Siwan Anderson. 
clear all 

cd "_____"

set matsize 800

ssc install estout


*****************
*** Figure 2A ***
*****************
clear


use hiv-figure2a


*** Generate a variable for distance to the border: negative in civil law countries, positive in common law countries
gen rd2=rdkm if commonlaw==1
replace rd2=-rdkm if commonlaw==0

*** Generate a variable for the square of the distance
gen rd2_2=rd2^2


*** Create a loop to group distances into 5km segments around the border 

preserve

*** Example for the group between -100 and -95:
gen group=-100 if rd2>=-100&rd2<-95

*** How to code this automatically to avoid doing it manually? 

*** Explanation of forvalues:  forvalues i=#1(#d)#2
*** For each value i, from #1 to #2 with step size #d

*** We want to create 5km groups from -100 to 100: How many groups in total? 40

forvalues i=1(1)40 {
replace group=-100+(`i'*5) if rd2>=-100+(`i'*5) & rd2<-95+(`i'*5)
}


*** Use the groups to create means by 5km intervals 
egen rd2_mean=mean(rd2), by(group)
egen hivpos_mean=mean(hivpos), by(group)



*Côté gauche (Civil law)
reg hivpos rd2 rd2_2 if rd2<0&rd2>-100,robust cluster(country)

*** Linear prediction of the above equation
predict yhat_1

*Côté droit (Common law)
reg hivpos rd2 rd2_2 if rd2>0&rd2<100,robust cluster(country)

*** Linear prediction of the above equation 
predict yhat_2

*** Create the graph itself
twoway (scatter hivpos_mean rd2_mean if rd2<100 & rd2>-100) /*
*/ (line yhat_1 rd2 if rd2<0&rd2>-100, sort)/* 
*/ (line yhat_2 rd2 if rd2>0&rd2<100, sort) , /* 
*/ xtitle(Distance to Border) ytitle(Female HIV) legend(off) xline(0)

graph save femaleRD2_hivpos.gph,replace

restore


******************
**Table 1*********


******************
**Cluster by country*********
*******************
clear


use hiv-table1.dta


xi: reg hivpos commonlaw   wifeage wifenoeduc i.tribe_code gdp_pop_ppp2004 abs_latitude longitude rain_min humid_max low_temp yt  j_pd0 j_l0708 j_km2split j_mean_ele j_mean_sui j_malarias j_petroleu  j_diamondd j_capdista j_seadist1 j_borderdi southafrica centralafrica eastafrica westafrica rdkm rdkmsq  if rdkm<=200      , cluster(country)
est sto A 
xi: reg hivpos commonlaw   wifeage wifenoeduc i.tribe_code gdp_pop_ppp2004 abs_latitude longitude rain_min humid_max low_temp yt  j_pd0 j_l0708 j_km2split j_mean_ele j_mean_sui j_malarias j_petroleu  j_diamondd j_capdista j_seadist1 j_borderdi southafrica centralafrica eastafrica westafrica rdkm rdkmsq  if rdkm<=150      , cluster(country)
est sto B 
xi: reg hivpos commonlaw   wifeage wifenoeduc i.tribe_code gdp_pop_ppp2004 abs_latitude longitude rain_min humid_max low_temp yt  j_pd0 j_l0708 j_km2split j_mean_ele j_mean_sui j_malarias j_petroleu  j_diamondd j_capdista j_seadist1 j_borderdi southafrica centralafrica eastafrica westafrica rdkm rdkmsq  if rdkm<=100      , cluster(country)
est sto C
xi: reg hivpos commonlaw   wifeage wifenoeduc i.tribe_code gdp_pop_ppp2004 abs_latitude longitude rain_min humid_max low_temp yt  j_pd0 j_l0708 j_km2split j_mean_ele j_mean_sui j_malarias j_petroleu  j_diamondd j_capdista j_seadist1 j_borderdi southafrica centralafrica eastafrica westafrica rdkm rdkmsq  if rdkm<=100 & target==1     , cluster(country)
est sto D
xi: reg hivpos commonlaw   wifeage wifenoeduc i.tribe_code gdp_pop_ppp2004 abs_latitude longitude rain_min humid_max low_temp yt  j_pd0 j_l0708 j_km2split j_mean_ele j_mean_sui j_malarias j_petroleu  j_diamondd j_capdista j_seadist1 j_borderdi southafrica centralafrica eastafrica westafrica rdkm rdkmsq  if rdkm<=100   & target==0   , cluster(country)
est sto E

esttab A B C D E, keep(commonlaw) se 



*C) DID ( diff in diff) *************************************************************************************************************************** 
**************************************************************************************************************************************
************** The Arrival of Fast Internet and Employment in Africa" By Jonas Hjort and Jonas Poulsen 2019 **************
************************************************************************************************************************************** 



clear all
set more off

cd "_____"

* For DHS data
* Data available only upon request, as it contains personal information: here we replicate only columns 2 and 3.

* For Afrobarometer data

use "data\afrobarometer.dta"

* Generate country x year fixed effects
* The variable "group (a b)" takes a different value for each (a b) pair in the sample
egen country_year = group(country year)

* Generate pixel x connected fixed effects
egen grid_connect = group(grid10 connected)

*** Perform the regression itself
*** areg: linear regression with many dummy variables.
*** The "absorb" function allows us to include a categorical variable (here, the fixed effects of connected grids) in the regression that would not otherwise appear.
*** Pay attention to the conditions: we don't want individuals more than 10 km (=0.1 here) from the central network, we don't want individuals older than 65 years (age = q1) to have a sample comparable to the QLFS of South Africa which doesn't have individuals older than 65 years

areg employed treatment i.country_year if q1 < 65 & distance < 0.1, a(grid_connect) cluster(grid10)
eststo reg2

clear

* For South Africa data (sa-qlfs)

use "data\qlfs.dta"

*** Only condition on the distance here
areg employed treatment i.time if time < 20103 & distance < 0.1, a(eacode) cluster(eacode)
eststo reg3

esttab reg2 reg3, se b(3) stats(N ymean, labels("Observations" "Mean of Outcome")) label alignment(center) nogaps fragment nonumbers mlabels(none) drop(*year* *time* _cons) collabels()  nocon starlevels(* 0.10 ** 0.05 *** 0.01)

*** Figure 6

* Normalize the arrival date of the submarine cables (20093) to 0 and create dates for the other quarters (from -4 to 3):

gen timesince = 0 if time == 20093

replace timesince = -4 if time == 20083
replace timesince = -3 if time == 20084
replace timesince = -2 if time == 20091
replace timesince = -1 if time == 20092

replace timesince = 1 if time == 20094
replace timesince = 2 if time == 20101
replace timesince = 3 if time == 20102

* Create the graph itself:

binscatter employed timesince, linetype(connect) by(connected) xline(0)

*** What can we say about the Common Trend Assumption?



*D) Propensity matching score ( PSM) *************************************************************************************************************************** 
**************************************************************************************************************************************
************** Bernard, T., Taffesse, A. S., & Gabre-Madhin, E. (2008). Impact of cooperatives on smallholders' commercialization behavior: Evidence from Ethiopia.**************
************************************************************************************************************************************** 


* The PSM is done in two steps 

*******************************************************************************
*************** Step 1: Estimation of the propensity score *******************
*******************************************************************************

* Regression (often using a probit model) of being treated (member = 1) or not (member = 0) on the control variables:
* educ, radio_ownership, land_ownership, sexhead, agehead, hhsize
* For more predictive power, the estimation is done only on the treated kebeles (ktreated = 1), where the choice to participate in a cooperative can actually take place.

    xi: probit member educ radio_ownership land_ownership sexhead agehead hhsize i.domain if ktreated==1

* Creation of the PS: probability that the outcome is positive

    predict PSCORE

* Examine the distribution of the PS to see if there is sufficient common support

    twoway (kdensity PSCORE if ktreated==1 & member==1) 
    (kdensity PSCORE if ktreated==0)

******************************************************
*************** Step 2: Matching *******************
******************************************************

* ssc install psmatch2
* help psmatch2 if there is any doubt
* Which population do we want to exclude from the estimation sample? 

* Kernel matching: regression on the desired sample, imposing common support with the outcome being the price of cereals (pcereals)

    xi: psmatch2 member if ktreated==0 | ktreated==1 & member==1, pscore(PSCORE) kernel common outcome(pcereals)

* 5 neighbors matching: same but with a change in the matching technique

    xi: psmatch2 member if ktreated==0 | ktreated==1 & member==1, pscore(PSCORE) n(5) common outcome(pcereals)


*D) IV *************************************************************************************************************************** 
**************************************************************************************************************************************
************** "The Slave Trade and the Origins of Mistrust in Africa"By Nathan Nunn and Leonard Wantchekon**************
************************************************************************************************************************************** 

version 11.0

set more off
capture clear
clear mata
capture log close
clear matrix
set mem 300m
set matsize 800

cd "___________"

use "Nunn_Wantchekon_AER_2011.dta", clear

local baseline_controls "age age2 male urban_dum i.education i.occupation i.religion i.living_conditions district_ethnic_frac frac_ethnicity_in_district i.isocode"
local colonial_controls "malaria_ecology total_missions_area explorer_contact railway_contact cities_1400_dum i.v30 v33"

*********************************************************************
******************************** Table 5 ****************************
*********************************************************************

**** Command function: ivreg var dependent (endogenous var = instrument) exogenous variables

xi: ivreg trust_relatives (ln_export_area=distsea) `baseline_controls' `colonial_controls' ln_init_pop_density, cluster(murdock_name) 

/* First stage F-stat */
xi: reg ln_export_area distsea `baseline_controls' `colonial_controls' ln_init_pop_density if missing(trust_relatives)~=1, cluster(murdock_name)
test distsea==0

*********************************************************************
******************************** Table 7 ****************************
*********************************************************************

**** Placebo test: we want to assess the effect of distance to the coast on trust in local government (trust_local_govt) where there was slavery and where there was not.

****************************
** Columns 1 & 2: ASS ****
****************************

clear
cd "____________"

use "Nunn_Wantchekon_AER_2011.dta", clear

**** We want to conduct the estimation without controls on the sample with control: what restrictions should be introduced in the first regression?

xi: reg trust_local_govt distsea i.isocode if missing(religion)!=1 & missing(education)!=1 & missing(male)!=1 & missing(age)!=1, cluster(murdock_name)
est sto t7c1
xi: reg trust_local_govt distsea age age2 male i.education i.religion i.isocode, cluster(murdock_name)
est sto t7c2

****************************
* Columns 3 & 4: Placebo *
****************************

clear 

cd "______________"

use "Asiabarometer_falsification_dataset.dta", clear

rename distance_coast distsea

**** Same as above

xi: reg trust_local_govt distsea i.COUNTRY if missing(age)!=1 & missing(male)!=1 & missing(education)!=1 & missing(religion)!=1, cluster(distsea)
est sto t7c3
xi: reg trust_local_govt distsea age* male i.education i.religion i.COUNTRY, cluster(distsea)
est sto t7c4

esttab t7c1 t7c2 t7c3 t7c4, keep (distsea) se r2

************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************