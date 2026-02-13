******* RAPPORT D'ECONOMETRIE 2024********
							
*I)The theme of our report is the effect of technological innovations on income inequality. We were tasked with writing an academic report in which we applied all the econometric methods we learned throughout the year 
	
clear all
capture log close
set more off


***** Creation of globals to indicate the source of data and backup ***** 
global sourcedata "C:\Users\bruel\Desktop\Econométrie 2024\data" 
global savedata "C:\Users\bruel\Desktop\Econométrie 2024\Résultats"

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













log close