                        ******* 2024********
							

	
clear all
capture log close
set more off


***** Creation of globals to indicate the source of data and backup ***** 
* Source data is not included in this repository (see root README).
* Point these at your own local copy before running.
global sourcedata "./data"
global savedata "./output"

***** Creation of a log file to record results every time the do-file is run: The "log file" in Stata is a file where all outputs and commands executed during a Stata session are recorded ***** 
log using "$savedata\log2024.log", replace

**************************** Importing variables and creating the database ***************************

**** Importation using the wbopendata command ****

*** Prior installation of the package ssc install wbopendata, then downloading based on the codes provided in the metadata ****

wbopendata, indicator (                   ///
NY.GDP.PCAP.PP.KD;                       /// GDP per capita, PPP (constant 2017 international $)
NE.TRD.GNFS.ZS;			                /// Trade (% of GDP)
GB.XPD.RSDV.GD.ZS;                     ///  Research and development expenditure (% of GDP)
FS.AST.PRVT.GD.ZS;                    ///  Domestic credit to private sector (% of GDP)
SL.TLF.ADVN.ZS;                      /// Labor force with advanced education (% of total labor force) 
SL.TLF.BASC.ZS;                     /// Labor force with basic education (% of total labor force)
SL.TLF.INTM.ZS;                     /// Labor force with intermediate education (% of total labor force ) 
GC.TAX.YPKG.RV.ZS;                 ///Taxes on income, profits and capital gains (% of revenue)
TM.VAL.ICTG.ZS.UN;                ///ICT goods imports (% total goods imports)
SP.POP.TOTL;                     /// Population, total
NE.CON.GOVT.KD.ZG;              ///  General government final consumption expenditure (annual % growth)
HD.HCI.OVRL;                   /// Human capital index (HCI) 
FP.CPI.TOTL.ZG ;              ///   Inflation consumer prices (annual %)
FP.CPI.TOTL ;                ///  Consumer price index (2010 = 100)
SL.UEM.TOTL.ZS ;             ///    Unemployment, total (% of total labor force) (modeled ILO estimate)
FD.AST.PRVT.GD.ZS ;        ///     Domestic credit to private sector by banks (% of GDP) 
SP.POP.GROW              ///       Population growth (annual %)
)   long clear full year(1993:2022) 
br 
***** Rename and label the variables *****

ren sp_pop_grow popgr
la var popgr "Population growth (annual %) "

ren fd_ast_prvt_gd_zs fin_bk
la var fin_bk "Domestic credit to private sector by banks (% of GDP) "

ren ny_gdp_pcap_pp gdpcap
la var gdpcap "GDP per capita, PPP (constant 2017 international $)"

ren ne_trd_gnfs_zs trade
la var trade "trade (% of GDP)"

ren gb_xpd_rsdv_gd_zs rd
la var rd "Research and development expenditure (% of GDP)"

ren fs_ast_prvt_gd_zs finance
la var finance "Domestic credit to private sector (% of GDP)"

ren sl_tlf_advn_zs labor_ad
la var labor_ad "Labor force with advanced education (% of total labor force)"

ren sl_tlf_basc_zs labor_basc
la var labor_basc "Labor force with basic education (% of total labor force)"

ren sl_tlf_intm_zs labor_intm
la var labor_intm "Labor force with intermediate education (% of total labor force )"

ren gc_tax_ypkg_rv_zs tax
la var tax "Taxes on income, profits and capital gains (% of revenue)"

ren tm_val_ictg_zs_un ict
la var ict "ICT goods imports (% total goods imports)"

ren sp_pop_totl poptot
la var poptot "Population, total"

ren ne_con_govt_kd_zg gov_exp
la var gov_exp "General government final consumption expenditure (annual % growth)"

ren hd_hci_ovrl hci
la var hci "Human capital index (HCI) "

ren fp_cpi_totl_zg infl
la var infl "Inflation consumer prices (annual %)"

ren fp_cpi_totl cpi
la var cpi "Consumer price index (2010 = 100)"

ren sl_uem_totl_zs unempl
la var unempl "Unemployment, total (% of total labor force) (modeled ILO estimate)"

*****rename countryname and countrycode****
ren countryname country 
ren countrycode isocode

******** Variables to keep in our database ****
keep country isocode year regionname incomelevelname year gdpcap trade rd finance labor_ad labor_basc labor_intm tax ict poptot gov_exp hci infl cpi unempl fin_bk popgr

order country isocode //order used to rearrange the order of observations in your dataset
br // The "browse" command is used to open a data browser window where you can view and browse the observations in your dataset.

*** Deletion of regions such as Western and Central Africa, Arab World... contained in our database; for this, we define a list of the ISO codes of these regions, which we then delete, leaving only the countries in our database ***

local list AFE AFW ARB CSS CEB EAR EAS EAP TEA EMU ECS ECA TEC EUU FCS HPC HIC IBD IBT IDB IDX IDA LTE LCN LAC TLA LDC LMY LIC LMC MEA MNA TMN MIC NAC INX OED OSS PSS PST PRE SST SAS TSA SSF SSA TSS UMC WLD 


foreach v in `list' {
    
    drop if isocode == "`v'"

}


**** Creation of country averages ****
gen period = year 
recode period 1993/1997=1 1998/2002=2 2003/2007=3 2008/2012=4 2013/2017=5 2018/2022=6

*** We calculate 5-year averages over the entire study period ***

order country isocode year period
save"$savedata\base.dta", replace 
u "$savedata\base.dta", clear
preserve 

keep if period ==1 
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period1.dta", replace
restore


*****period2

preserve 

keep if period ==2
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period2.dta", replace
restore

**period3 
preserve 

keep if period ==3
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period3.dta", replace
restore

**** period 4

preserve 

keep if period ==4
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period4.dta", replace
restore

***period 5
preserve 

keep if period ==5
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period5.dta", replace
restore

******period 6

preserve 

keep if period ==6
keep  gdpcap cpi poptot country isocode period
egen id = group(isocode)

**** Inflation***
bysort id : gen cm_cpi= cpi/cpi[_n-1]
bysort id: gen tm_inflation = (((cm_cpi[_n-1]*cm_cpi[_n-2]*cm_cpi[_n-3]*cm_cpi)^(1/5))-1)*100

***GDP per cap****
bysort id : gen cm_gdp= gdpcap/gdpcap[_n-1]
bysort id: gen tm_gdp = (((cm_gdp[_n-1]*cm_gdp[_n-2]*cm_gdp[_n-3]*cm_gdp)^(1/5))-1)*100

***** growth
bysort id : gen cm_popg= poptot/poptot[_n-1]
bysort id: gen tm_pop = (((cm_popg[_n-1]*cm_popg[_n-2]*cm_popg[_n-3]*cm_popg)^(1/5))-1)*100
save "$savedata\period6.dta", replace
restore

preserve
cd "$savedata"
u period1.dta, clear 
append using period2 period3 period4 period5 period6  
sort id period
keep country isocode period tm_inflation tm_gdp tm_pop
collapse (mean) tm_inflation tm_gdp tm_pop , by (country isocode period)
save base_tm.dta, replace
restore

*****mdesc tax : to see missing variables 
 
 
 
 ********  icrg (International Country Risk Guide) Researcher Dataset***
preserve
clear all
import excel using "$sourcedata\ICRG2.xlsx", sheet("Feuil1") firstrow clear
br
reshape long var, i(country variable) j(year)
destring var, replace
replace variable = subinstr(variable, "(", "", .)
replace variable = subinstr(variable, ")", "", .)
replace variable = subinstr(variable, " ", "_", .)
replace variable = subinstr(variable, "-", "", .)
replace variable = subinstr(variable, "&", "", .)
replace variable = subinstr(variable, "%", "", .)
replace variable = subinstr(variable, "as", "", .)
replace variable = subinstr(variable, "for", "_", .)
replace variable = subinstr(variable, "__", "_", .)
reshape wide var, i(country year) j(variable) string 
br
keep country year varCorruption_F varDemocratic_Accountability_K varGovernment_Stability_A  varLaw_Order  varPolitical_Risk_Rating

ren varPolitical_Risk_Rating  pol_risk
la var pol_risk "Political_Risk_Rating "
destring pol_risk , replace force
 
ren varCorruption_F corrup_icrg
la var corrup_icrg "Control of Corruption"
destring corrup_icrg , replace force

ren varDemocratic_Accountability_K democ_icrg
la var democ_icrg "Democraty Accountability"
destring democ_icrg, replace force

ren varGovernment_Stability_A stability
la var stability "Government Stability" 
destring stability , replace force

ren varLaw_Order_I law_order
la var law_order "Law and Order"
destring law_order, replace force


drop if country =="Germany, West"
drop if country == "Germany, East"
drop if country =="USSR"

kountry country , from (other) stuck  //create isicode                                     
ren _ISO3N code_pays
kountry code_pays , from(iso3n) to(iso3c)
drop code_pays
ren _ISO3C isocode

order country isocode
tab country if isocode==""
order country isocode year
drop if country =="Czechoslovakia"
drop if country =="Serbia-Montenegro"
replace isocode = "COD" if country == "Congo, DR"
replace isocode = "PRK" if country == "Korea, DPR"
replace isocode = "CIV" if country == "CÃ´te dâ€™Ivoire"
replace country = "Côte d'Ivoire" if country== "CÃ´te dâ€™Ivoire"
drop if year < 1993
tempfile base
save `base'
restore

* Merging with data in memory.
mer m:1 isocode year using `base', nogen keep (1 3)
  
  *****TAX********
preserve
cd"$sourcedata"
u tax , clear
br
ren iso isocode
keep country isocode year tax_income resourcetaxes tot_res_rev grants
drop if year < 1993
tempfile base 
save `base'
restore 

merge m:1 isocode year using `base' , nogen keep (1 3)

*** capital humain ***
preserve 
cd"$sourcedata"
u capital_hum , clear 
br 
ren countrycode isocode
keep country isocode year hc
drop if year < 1993
tempfile base 
save `base'
restore 

mer m:1 isocode year using `base' , nogen keep (1 3)

******** finance FMI****

preserve 
cd"$sourcedata"
u FD, clear 
br 
ren code isocode
keep country isocode year FD FID FIA
drop if year < 1993
tempfile base 
save `base'
restore 

mer m:1 isocode year using `base' , nogen keep (1 3)

***** patents***
preserve 
import excel using "$sourcedata\patent.xlsx", sheet("Feuil1") firstrow clear
ren total patent_tot
ren année year
drop origincode
kountry country , from (other) stuck  //create isocode                                    
ren _ISO3N code_pays
kountry code_pays , from(iso3n) to(iso3c)
drop code_pays
ren _ISO3C isocode
order country isocode
tab country if isocode==""
order country isocode year

drop if country == "Bonaire" | country == "Soviet Union"| country == "CuraÃ§ao"| country == "Czechoslovakia" | country =="European Union" | country == "German Democratic Republic" | country == "Soviet Union"

replace isocode = "BOL" if country == "Bolivia (Plurinational State of)"
replace isocode = "CIV" if country == "CÃ´te dâ€™Ivoire"
replace isocode = "HKG" if country == "China HK"
replace isocode = "MAC" if country == "China MS "
replace isocode = "NLD" if country == "Netherlands (Kingdom of the)"
replace isocode = "TUR" if country == "TÃ¼rkiye"
replace isocode = "MAF" if country == "Sint Maarten (Dutch Part)"
replace isocode = "VEL" if country == "Venezuela (Bolivarian Republic of)"
replace isocode = "CPV" if country == "Cabo Verde" 


replace country = "Bolivia" if country== "Bolivia (Plurinational State of)"
replace country = "Côte d'Ivoire" if country== "CÃ´te d'Ivoire"
replace country = "Hong Kong SAR, China" if country== "China HK "
replace country = "Macao SAR, China" if country== "China MS "
replace country = "Netherlands" if country== " Netherlands (Kingdom of the) "
replace country = "Turkiye" if country== "TÃ¼rkiye"
replace country = "St. Martin (French part)" if country== "Sint Maarten (Dutch Part)"
replace country = "Venezuela, RB" if country== "Venezuela (Bolivarian Republic of)"

keep country isocode year patent_tot
destring patent_tot , replace force
drop if year < 1993
duplicates drop isocode year, force
tempfile base 
save `base'

restore 

mer m:1 isocode year using `base' , nogen keep (1 3)

********* inequality wid******
preserve
cd"$sourcedata"
u inequality , clear
br
drop if year < 1993
tempfile base 
save `base'
restore 

merge m:1 isocode year using `base' , nogen keep (1 3)



********GINI SWIID****
preserve 
import excel using "$sourcedata\SWIID.xlsx", sheet("Feuil1") firstrow clear
ren CountryName country
ren ISO_3 isocode
ren Time year
drop if year < 1993
duplicates drop isocode year, force
tempfile base 
save `base'
restore 

mer m:1 isocode year using `base' , nogen keep (1 3)
destring gini_disp_SWIID gini_mkt_SWIID, replace

******* KOF*****
preserve
import excel using "$sourcedata\KOF.xlsx", sheet("Sheet1") firstrow clear
ren code isocode
keep country isocode year KOFGI
drop if year < 1993
tempfile base 
save `base'
restore 

merge m:1 isocode year using `base' , nogen keep (1 3)


********* creation of arithmetic mean for our Master database (main database)***
preserve 
collapse (mean)   poptot FD FID FIA fin_bk popgr pol_risk gdpcap trade rd finance labor_ad labor_basc labor_intm tax ict gov_exp hci unempl corrup_icrg democ_icrg stability law_order tot_res_rev resourcetaxes tax_income grants hc patent_tot gini top1 top5 top10 top20 bottom40 palma gini_disp_SWIID gini_mkt_SWIID KOFGI, by (country isocode regionname incomelevelname period )
save "$savedata\base_finale.dta", replace
restore

use "$savedata\base_finale.dta", clear

********* merge  base_tm ( dataset on growthrate) with our main dataset******


merge m:1 isocode period using "$savedata\base_tm.dta", nogen 
br

foreach x in   FD FID FIA  poptot gdpcap trade rd fin_bk popgr pol_risk finance unempl ict gov_exp corrup_icrg democ_icrg stability law_order tax_income hc patent_tot tm_inflation tm_gdp tm_pop gini_mkt_SWIID {
    bys isocode : egen Mean_`x' = mean(`x') 
    drop if missing(Mean_`x')
    drop Mean_`x'
}
distinct country
***After removing the countries that have missing data on the variables of our base model throughout the entire study period, we are left with a list of 96 countries out of the initial 217.
tab country if period==1




*************Principal Component Analysis and creation of innovation and governance indicators*******************


****Normalization of innovation variables********
gen l_patent = log(patent_tot)
gen l_ict = log(ict)
gen l_rd = log(rd)
save "$savedata\base_finale1.dta",replace



***** creation of country mean

collapse (mean) l_patent l_ict l_rd corrup_icrg democ_icrg stability law_order, by (country)
br
** we then generate a fictitious year
gen year = 222
order country year
** We save the newly obtained file
save "$savedata\ACP.dta", replace
*** We put this data back into the original file
use "$savedata\base_finale1.dta", clear
append using "$savedata\ACP.dta", nolabel
br 
distinct country

***** PCA for institutional quality*****

pca corrup_icrg democ_icrg stability law_order if year==222
screeplot // We will keep only the first two axes because it is only there that the eigenvalues are greater than 1
predict axe1 axe2, score 
gen gov = (0.5730/0.9001)*axe1+(0.3270/0.9001)*axe2
screeplot, yline(1)
loadingplot 
scoreplot, xline(0) yline(0) mlabel(country)
br 



*********PCA for patents*********

pca l_patent l_ict l_rd if year==222
screeplot, yline(1)
predict innov_index, score
loadingplot 
scoreplot, xline(0) yline(0) mlabel(country)


************************** transform some variables in log form *******************


gen l_trade = log(trade)
gen l_palma = log(palma)
gen l_fin = log(finance)
gen l_unempl = log(unempl)
gen l_tax_inc = log(tax_income)
gen l_fin_bk=log( fin_bk )
gen l_FD = log(FD)
gen l_FID = log(FID)
gen l_FIA = log(FIA)
gen patent_pop= patent_tot/ poptot 
gen l_patent_pop= log(patent_pop)

g dev = 0 
replace dev = 1 if incomelevelname =="High income"

drop if year==222
drop year 

***declaration of our  panel
egen id = group(isocode)
gen year= 1993+(period-1)*5
order country isocode year
xtset id period 

sum gov,d
gen m=0
replace m=1 if gov> -.070132 
 

************************* descriptive Statistics *************

xtsum gini l_patent tm_gdp gov_exp FIA  l_trade l_tax_inc gov  	// Allows distinguishing the descriptive statistics in their within and between dimensions

// Panel data curves
xtline gini if id<=12,  	
xtline l_patent if id<=12,  

xtline gini if id<=30 | id>=65, overlay   	// Group the graphs into one
summarize
pwcorr gini_mkt_SWIID l_patent, star(05)
pwcorr gini_mkt_SWIID l_patent, sig

twoway scatter gini_mkt_SWIID l_patent || lfit gini_mkt_SWIID l_patent

pwcorr gini l_patent, star(05)
pwcorr gini l_patent, sig
twoway scatter gini l_patent || lfit gini l_patent
graph hbar  gini l_patent
 pwcorr 
histogram l_patent, kdensity	// Displays the distribution as histograms with the kernel
histogram l_patent, normal	// Displays the distribution as histograms with the kernel
xttab gini
stop
************************************* ...

*econometric tests 	
//Les MCO groupés (pooling)
regress lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp
est sto pooling 								// store the regression 
			
				
//fixe effect models 

*Dummy variable method
reg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.id		// i.id ajoutte les effets spécifiques fixes individuels
/*
Note that a specific effect is arbitrarily removed by the software in order to estimate the others.  
If we want to interpret the coefficients related to fixed specific effects, remember to interpret them based on the missing fixed effect.
*/
est sto mvm 									

*within estimator
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp, fe
est sto fe 


// Random effects models
*Estimation of REM using GMM
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp, re
est sto re_gls 
*Estimation of REM using IV
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp, mle
est sto re_ml



//exporting the regression tables 
*Package outreg2
outreg2 [pooling mvm fe re_gls re_ml] using tab_result.doc, title("Regression du modele de Base") addtext(Year FE, Yes) bdec(3) sdec(3) replace
*If we want to eliminate the i.id from the results table, then specify the option drop(i.id)
outreg2 [pooling mvm fe re_gls re_ml] using tab_result2.doc, title("Regression du modele de Base") bdec(3) sdec(3) replace drop(i.id)							



*********************************************with period fixe effect*******************************
*******model 1
xtreg gini l_patent i.period, fe cluster (regionname)
est sto r1 
xtreg gini l_patent l_tax_inc i.period, fe cluster (regionname)
est sto r2 
xtreg gini l_patent l_tax_inc l_trade  i.period, fe cluster (regionname)
est sto r3 
xtreg gini l_patent l_tax_inc l_trade tm_gdp  i.period, fe cluster (regionname)
est sto r4 
xtreg gini l_patent l_tax_inc l_trade tm_gdp FIA i.period, fe cluster (regionname)
est sto r5 
xtreg gini l_patent l_tax_inc l_trade tm_gdp FIA gov i.period, fe cluster (regionname)
est sto r6
xtreg gini l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r7


********model 2
xtreg gini l3.l_patent i.period, fe cluster (regionname)
est sto r1 
xtreg gini l3.l_patent l_tax_inc i.period, fe cluster (regionname)
est sto r2 
xtreg gini l3.l_patent l_tax_inc l_trade  i.period, fe cluster (regionname)
est sto r3 
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp  i.period, fe cluster (regionname)
est sto r4 
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA i.period, fe cluster (regionname)
est sto r5 
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov i.period, fe cluster (regionname)
est sto r6
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r7

**********model 3
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r1
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period if dev==1, fe cluster (regionname)
est sto r2
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period if dev==0, fe cluster (regionname)
est sto r3

*****robustess top10 top20 bottom40 palma gini_mkt_SWIID

xtreg top20 l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r1
xtreg bottom40 l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r2
xtreg l_palma l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r3

*********heterogeneity***********
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period, fe cluster (regionname)
est sto r1
xtreg gini l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period if m==1, fe cluster (regionname)
est sto r2
xtreg gini  l3.l_patent l_tax_inc l_trade tm_gdp FIA gov gov_exp i.period if m==0, fe cluster (regionname)
est sto r3

outreg2 [r1 r2 r3 r4 r5 r6 r7  ] using tab_result2.doc,  bdec(3) sdec(3) replace drop(i.period)
outreg2 [r1 r2 r3] using tab_result8.doc, title("Regression du modele de Base") addtext(Year FE, Yes) bdec(3) sdec(3) replace drop(i.period) // As before, if you do not want to display the coefficients of the time dummies, add the option drop(i.period)

// The Breusch-Pagan test for the absence of random effects: The Breusch and Pagan test is a test of the null hypothesis of the absence of random effects in a panel data model.
*******************************************************************************************************************************
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp, re
xttest0 									// Règle de décision : P-value < 0.10 = rejet hypothèse d'absence d'EA

*******Interpretation: Given that the p-value associated with the test is very low (0.000), we reject the null hypothesis that there are no random effects in the model. This suggests that random effects are significant and should be considered in the analysis of the panel data model.

// The Hausman test for the convergence of specific effects
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp, fe 
est sto fe
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , re 
est sto re
hausman fe re 		// Decision rule: P-value > 0.10 = Do not reject the hypothesis of convergence of specific effects; the second estimator is efficient // In our case, P-value = 0.000 < 0.1, reject the hypothesis of convergence of specific effects; the first estimator is efficient, we have fixed effects.
reg  gini l_patent l_trade tm_inflation tax_inc tm_gdp gov FIA gov_exp i.id i.period, ro

*****l_patent tm_inflation hc tm_gdp poptot KOFGI l_FID tm_pop pol_risk gov_exp unempl l_tax_inc

xtreg gini l_patent tm_inflation l_tax_inc tm_gdp gov_exp KOFGI fin_bk gov, re
xttest0 
xtreg gini l_patent tm_inflation l_tax_inc tm_gdp gov_exp KOFGI fin_bk gov , fe 
est sto fe
xtreg  gini l_patent tm_inflation l_tax_inc tm_gdp gov_exp KOFGI fin_bk gov, re 
est sto re
hausman fe re 		// Decision rule: P-value > 0.10 = Do not reject the hypothesis of convergence of specific effects; the second estimator is efficient // In our case, P-value = 0.000 < 0.1, reject the hypothesis of convergence of specific effects; the first estimator is efficient, we are dealing with fixed effects.

*********************************************************************************************************************
// Prediction and residuals estimated from a regression
predict Ypredict // Creates a variable logpgp95hat containing the predicted values of the dependent variable (logpgp95)	

predict residus1, residuals // Creates a variable (residues) containing the residuals.
twoway scatter l_patent residus  || lfit l_patent lgini // Link between the residuals and the explanatory variables
twoway scatter lat_abst residus || lfit lat_abst logpgp95hat //


// Normality test of the residuals (Jarque-Bera test (1980))
xtreg gini l_patent trade l_tax_inc tm_gdp FIA gov gov_exp i.period, fe

sktest residus // Decision rule: P-value > 0.10 = Do not reject the hypothesis of normality of the residuals


// The homoscedasticity test
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , fe
xttest0 			// Decision rule: P-value < 0.10 = Reject the hypothesis of homoscedasticity of the random errors

xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , fe ro 				// Heteroscedasticity correction to obtain robust standard errors to heteroscedasticity
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , fe cluster(id)		// Correction by clustering
predict Ypredict4
predict residus4, residuals // Creates a variable (residues) containing the residuals.
twoway scatter l_patent residus4  || lfit l_patent lgini // Link between the residuals and the explanatory variables


// The first-order serial autocorrelation test
xtregar lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , fe lbi // Règle de décision : http://www.stata.com/statalist/archive/2010-08/msg00542.html
xtregar lnhr lnwg age agesq kids disab, re lbi  // Decision rule: http://www.stata.com/statalist/archive/2010-08/msg00542.html
xtserial lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , output  // H0: No autocorrelation; HA: Presence of autocorrelation
xtserial lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , lag(1) breuschgodfrey
xttest3, serial lags(1)  /// to review, it didn't work


gen linnov = l.l_patent
order country period year l_patent linnov
xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp , fe  ro cluster(id)
predict Ypredict6
predict residus6, residuals  // Creates a variable (residuals) containing the residuals.
twoway scatter l_patent  || lfit l_patent lgini  // Link between the residuals and the explanatory variables

STOP

**********************************Draft**********************************************
   preserve 
bys isocode : egen moy = mean(innov_index)
drop if moy ==.
mdesc innov_index
distinct isocode
restore 
************************



/
xtreg gini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.period if dev ==1, fe ro

reg gini l.l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.id i.period if dev ==1
estat bgodfrey

reg gini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.id i.period if dev ==1, ro



xtreg gini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.period , fe ro
est sto fe2 

xtivreg2 gini (lpatent_pop=l.lpatent_pop) l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp pr, fe ro first

xtreg lgini l_patent l_trade tm_inflation l_tax_inc tm_gdp pol_risk unempl gov_exp i.period , re
est sto re_gls2


xtreg gini l_patent gov_exp FIA gov tm_gdp l_tax_inc l_trade, re
xttest0 
xtreg gini l_patent gov_exp FIA gov tm_gdp l_tax_inc l_trade , fe 
est sto fe
xtreg  gini l_patent gov_exp FIA gov tm_gdp l_tax_inc l_trade, re 
est sto re
hausman fe re 








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
* Source data is not included in this repository (see root README).
* Point these at your own local copy before running.
global sourcedata "./data"
global savedata "./output"
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
* Source data is not included in this repository (see root README).
* Point these at your own local copy before running.
global sourcedata "./data"
global savedata "./output"
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
* Source data is not included in this repository (see root README).
* Point these at your own local copy before running.
global sourcedata "./data"
global savedata "./output"
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

log close





