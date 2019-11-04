#d;
clear;
********************************************************************************
*     PROGRAM NAME:   STATA SAMPLE CODE FOR COMPUTING STANDARD ERRORS          *
*                     FROM THE PUMD FOR THE COLLECTION YEAR.                   *
*                                                                              *
*     WRITTEN BY:             Taylor J. Wilson - 15 November 2016              *
*     VERSION :               SE/15  (FOR STATA VERSION 11 OR HIGHER)          *
*	  EDITED:				  24 August 2017								   *
*                                                                              *
*     The results of this program are intended to outline the procedures       *
*     for computing PUMD Standard Errors. Any errors are mine alone.           *
*                                                                              *
********************************************************************************
********************************************************************************
#d ;
global inPath   = "C:\Users\bihon\Dropbox\Thesis Bank\Data\BLS\Consumer Expenditure Survey\PUMD_Public Use Micro Data\2015_Interview_STATA\intrvw15";  /*Pathway for importing data.*/

global outPath  = "C:\Users\bihon\Dropbox\Thesis Bank\Essay 2\CES_Interview2015";  /*Pathway for saving data.*/  

global outPath2 = "C:\Users\bihon\Dropbox\Thesis Bank\Essay 2\CES_Interview2015\KeyMetros" ;

global replicates = "wtrep01-wtrep44";

global wtrepvar = "awtrep01_foodalc-awtrep44_cashco";   


********************************************************************************

********************************************************************************
******************* Rosa's Question ********************************************
*** 1) I need to drop observation if psu == ""  (17,353 observation will be deleted)
****** Does this procedure affect the calculation of Standard Error?
*** 2) Then, I will divide the sample for three income group (lower/ middle/ upper class)
****** Does that mean I have to drop the CUs in other two categories when I want to calculate standard error?
****** Or is there anything like 'group_by' function similar to the one I did it for average expenditure?
*** 3) Then I need to do 10 different expenditure categories. 
*** 4) Getting standard error using replicate weight is complicted. Get confirm from BLS staff. 
********************************************************************************
********************************************************************************


/*These are the datasets we will need for 2016 collection year data.*/
// ** Rosa will change the below code for the 2015 Calander year data ** //

#d ;
use "$inPath\fmli151x.dta" ; 
append using "$inPath\fmli152.dta" ;
append using "$inPath\fmli153.dta" ;
append using "$inPath\fmli154.dta" ;  
append using "$inPath\fmli161.dta" ;

******* Rosa's Revision on 1) Drop 'non-psu' sample
br psu
count if psu == ""
count if psu != ""
drop if psu == ""

******* Calander Year Data Indication 
#d ;
gen quarter = 3 ;

replace quarter = 1 if (qintrvmo == "01" | qintrvmo == "02" | qintrvmo == "03")
& qintrvyr == "2015" ;
replace quarter = 5 if (qintrvmo == "01" | qintrvmo == "02" | qintrvmo == "03")
& qintrvyr == "2016" ;

save "$outPath\SE Calculation"

 ** 1-A) For the convinience, generate MSA Title
gen CBSATitle = "NA"
replace CBSATitle = "Boston-Cambridge-Newton, MA-NH" if psu == "S11A"
replace CBSATitle = "New York-Newark-Jersey City, NY-NJ-PA" if psu == "S12A"
replace CBSATitle = "Philadelphia-Camden-Wilmington, PA-NJ-DE-MD" if psu == "S12B"
replace CBSATitle = "Chicago-Naperville-Elgin, IL-IN-WI" if psu == "S23A"
replace CBSATitle = "Detroit-Warren-Dearborn, MI" if psu == "S23B"
replace CBSATitle = "Minneapolis-St. Paul-Bloomington, MN-WI" if psu == "S24A"
replace CBSATitle = "St. Louis, MO-IL" if psu == "S24B"
replace CBSATitle = "Washington-Arlington-Alexandria, DC-VA-MD-WV" if psu == "S35A"
replace CBSATitle = "Miami-Fort Lauderdale-West Palm Beach, FL" if psu == "S35B"
replace CBSATitle = "Atlanta-Sandy Springs-Roswell, GA" if psu == "S35C"
replace CBSATitle = "Tampa-St. Petersburg-Clearwater, FL" if psu == "S35D"
replace CBSATitle = "Baltimore-Columbia-Towson, MD" if psu == "S35E"
replace CBSATitle = "Dallas-Fort Worth-Arlington, TX" if psu == "S37A"
replace CBSATitle = "Houston-The Woodlands-Sugar Land, TX" if psu == "S37B"
replace CBSATitle = "Phoenix-Mesa-Scottsdale, AZ" if psu == "S48A"
replace CBSATitle = "Denver-Aurora-Lakewood, CO" if psu == "S48B"
replace CBSATitle = "Los Angeles-Long Beach-Anaheim, CA" if psu == "S49A"
replace CBSATitle = "San Francisco-Oakland-Hayward, CA" if psu == "S49B"
replace CBSATitle = "Riverside-San Bernardino-Ontario, CA" if psu == "S49C"
replace CBSATitle = "Seattle-Tacoma-Bellevue, WA" if psu == "S49D"
replace CBSATitle = "San Diego-Carlsbad, CA" if psu == "S49E"
replace CBSATitle = "Honolulu, HI" if psu == "S49F"
replace CBSATitle = "Anchorage, AK" if psu == "S49G"

order newid psu CBSATitle
label var fincbtxm "Consumer Unit income before taxes in past 12 months"

 ** 2) Middle Class Category for 2015 (before COLI adjusted)
scalar lbmc2015_D2= 42387 
//lower bound of the Middle Class according to Definition 2
scalar ubmc2015_D2= 141290 
//upper bound for Middle Class according to Definition 2

gen MC_D2 = 1
replace MC_D2 = 2 if fincbtxm >= 42387 & fincbtxm < 141290
replace MC_D2 = 3 if fincbtxm >= 141290
label define Class 1 "Lower Class" 2 "Middle Class" 3 "Upper Class"
label values MC_D2 Class

gen foodalcpq = foodpq + alcbevpq 
gen foodalccq = foodcq + alcbevcq
 
gen misc_pq = perscapq + readpq + tobaccpq + miscpq
gen misc_cq = perscacq + readcq + tobacccq + misccq

  /// These are the variable that I am interested: 10 different Consumption category ///
br foodalcpq foodalccq misc_pq misc_cq houspq houscq apparpq apparcq transpq transcq healthpq healthcq entertpq entertcq educapq educacq perinspq perinscq cashcopq cashcocq

******** Rosa Addition for calculating 'exp': Void since the below expenditure is for the calander year *********************
foreach i in foodalc misc_ hous appar trans health entert educa perins cashco {
gen exp_`i' = `i'pq + `i'cq 
}

#d ;
gen month = real(qintrvmo) ;

save "$outPath\SE Calculation", replace                                                     ///// Use this file (July 23, 2018)

********************************* Dividing three different file for loop ******************
use "$outPath\SE Calculation", clear

count if MC_D2 == 1 
// 4,805 obs
count if MC_D2 == 2 
// 5,863 obs
count if MC_D2 == 3 
// 1,979 obs

keep if MC_D2 == 1
save "$outPath\SE Calculation_LC"

use "$outPath\SE Calculation", clear
keep if MC_D2 == 2 
save "$outPath\SE Calculation_MC"

use "$outPath\SE Calculation", clear
keep if MC_D2 == 3 
save "$outPath\SE Calculation_UC"



****************************************************************************************
**** I divided the sample into three classes. Now, let's try calculating S.E. for Middle Class Consumption by category
///// Check the below code first ////
foreach k in LC MC UC 
use "$outPath\SE Calculation_`k'", clear

global cq_var  = "---cq";  /*Current quarter half of variable of interest*/     /// Put only one variable at a time

global pq_var  = "---pq";  /*Previous quarter half of variable of interest*/    /// or use loop
 ************************************************************************************************

************************************** <<  Middle Class First >> ************************************************
use "$outPath\SE Calculation_MC", clear
br finlwt21 totexppq totexpcq $replicates 

#d ;
gen month = real(qintrvmo) ;
 
#d ;
keep quarter qintrvmo month newid totexppq totexpcq foodalcpq foodalccq misc_pq misc_cq houspq houscq apparpq apparcq
     transpq transcq healthpq healthcq entertpq entertcq educapq educacq perinspq perinscq cashcopq cashcocq 
	 finlwt21 $replicates ;
	 
/*Generate the variable of interest.*/

/*Use the replicate weights and finlwt21 to weight the expenditure variable*/

******* 1. Weighted Expenditure for Months in Scope
foreach i in totexp foodalc misc_ hous appar trans health entert educa perins cashco {
gen wtexp_`i' = `i'cq*finlwt21 if quarter == 1
    replace wtexp_`i' = `i'pq*finlwt21 if quarter == 5
	replace wtexp_`i' = ((`i'cq + `i'pq)*finlwt21) if quarter == 3
	}

format wtexp_* %16.1gc
br wtexp_*

******* 2. Getting Population Weight for the Final weight 21
   **** Since right now I appended five different quarterly file, the final weights are 5 times bigger (Each final weights is for the entire USA population)
 #d ;
gen popwt = finlwt21*(((month-1)/3)/4) if quarter == 1 ;
	replace popwt = finlwt21*(((4-month)/3)/4) if quarter == 5 ;
	replace popwt = finlwt21/4 if quarter == 3 ;

******* 3. Getting Temporary Replicate for Months in Scope
	#d cr
foreach var of varlist $replicates {
     gen tmp_`var' = `var'*(((month-1)/3)/4) if quarter == 1 
	 replace tmp_`var' = `var'*(((4-month)/3)/4) if quarter == 5 
	 replace tmp_`var' = `var'/4 if quarter == 3
	}
 
 br wtrep01 tmp_wtrep01
       //// wtrep01 is Replicate Weight for the entire U.S for one quarter.
	   //// but I am using the calendar year, I appended the five quarterly data
	   //// Thus, I need to create Temporary Replicate for Months in Scope
 
 
********* 4.  Getting the Grand Mean: starting "Food & Alcohol" Category 
egen sumexp_foodalc = sum(wtexp_foodalc)
egen sumpopwt = sum(popwt)
gen GM_foodalc = sumexp_foodalc/sumpopwt
label var GM_foodalc "Grand Mean for Food & Alcohol Category in 2015"


********* 5. Getting the 44 Replicate Aggregate expenditure for food& Alc
   **** 5-1) Weighted Expenditure
foreach var of varlist $replicates {
gen wtexp_foodalc_`var' = foodalccq*`var' if quarter == 1
    replace wtexp_foodalc_`var' = foodalcpq*`var' if quarter == 5
	replace wtexp_foodalc_`var' = ((foodalccq+foodalcpq)*`var') if quarter == 3
	}

	br wtexp_foodalc_*
    format wtexp_foodalc_* %16.1gc
	
   **** 5-2) Aggregation for Replicate 1 
 foreach var of varlist wtexp_foodalc_wtrep*{ 
 egen sumfoodalc_`var' = sum(`var')
 }
 
   **** 5-3) Population Aggregate for every Replicate 44
 foreach var of varlist tmp_wtrep*{
 egen sumpopwt_`var' = sum(`var')
 }
 
   **** 5-3) Getting Replicate Mean (M1, M2, .... M44)
 foreach n of numlist 1(1)9 {
gen M`n'_foodalc = sumfoodalc_wtexp_foodalc_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_foodalc = sumfoodalc_wtexp_foodalc_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }

  br GM_foodalc RM01_foodalc
  br GM_foodalc M*_foodalc
  
  foreach n of numlist 1(1)44 {
  gen diff_foodalc_`n' = (M`n'_foodalc - GM_foodalc)^2
  }
  
  br diff_food*
  egen sumdiff_foodalc = rowtotal(diff_foodalc_*)
  
  br sumdiff_foodalc
  
  gen se_foodalc = sqrt(sumdiff_foodalc/44)
  br se_foodalc
/*
foreach var of varlist $replicates{
		replace `var' = `var'/4
		}
		*/
                         ///// Should I do double looping in here??
						 
******************************************************************************************************
******************************************************************************************************
*********************** Same Process for all other Expenditure Category ******************************
br wtexp_*
egen sumpopwt = sum(popwt)

  **** 4. Getting the Aggregate Expenditure for each category & Grand Mean for each category
foreach i in totexp foodalc misc_ hous appar trans health entert educa perins cashco {
 egen sumexp_`i' = sum(wtexp_`i')
  }
  format sumexp_* %16.1gc
  br sumexp_*
  
foreach i in totexp foodalc misc_ hous appar trans health entert educa perins cashco {
gen GM_`i' = sumexp_`i'/sumpopwt
 }
 
  br GM_*
  
  **** 5. Getting Mean for each replicate 44
  **** 5-1) Weighted Expenditure
 foreach var of varlist $replicates {
    gen wtexp_totexp_`var' = totexpcq*`var' if quarter == 1
    replace wtexp_totexp_`var' = totexppq*`var' if quarter == 5
	replace wtexp_totexp_`var' = ((totexppq+totexpcq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_foodalc_`var' = foodalccq*`var' if quarter == 1
    replace wtexp_foodalc_`var' = foodalcpq*`var' if quarter == 5
	replace wtexp_foodalc_`var' = ((foodalccq+foodalcpq)*`var') if quarter == 3
	}
 
foreach var of varlist $replicates {
gen wtexp_misc_`var' = misc_cq*`var' if quarter == 1
    replace wtexp_misc_`var' = misc_pq*`var' if quarter == 5
	replace wtexp_misc_`var' = ((misc_pq+misc_cq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_hous_`var' = houscq*`var' if quarter == 1
    replace wtexp_hous_`var' = houspq*`var' if quarter == 5
	replace wtexp_hous_`var' = ((houspq+houscq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_appar_`var' = apparcq*`var' if quarter == 1
    replace wtexp_appar_`var' = apparpq*`var' if quarter == 5
	replace wtexp_appar_`var' = ((apparpq+apparcq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_trans_`var' = transcq*`var' if quarter == 1
    replace wtexp_trans_`var' = transpq*`var' if quarter == 5
	replace wtexp_trans_`var' = ((transpq+transcq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_health_`var' = healthcq*`var' if quarter == 1
    replace wtexp_health_`var' = healthpq*`var' if quarter == 5
	replace wtexp_health_`var' = ((healthpq+healthcq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_entert_`var' = entertcq*`var' if quarter == 1
    replace wtexp_entert_`var' = entertpq*`var' if quarter == 5
	replace wtexp_entert_`var' = ((entertpq+entertcq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_educa_`var' = educacq*`var' if quarter == 1
    replace wtexp_educa_`var' = educapq*`var' if quarter == 5
	replace wtexp_educa_`var' = ((educapq+educacq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_perins_`var' = perinscq*`var' if quarter == 1
    replace wtexp_perins_`var' = perinspq*`var' if quarter == 5
	replace wtexp_perins_`var' = ((perinspq+perinscq)*`var') if quarter == 3
	}
	
foreach var of varlist $replicates {
gen wtexp_cashco_`var' = cashcocq*`var' if quarter == 1
    replace wtexp_cashco_`var' = cashcopq*`var' if quarter == 5
	replace wtexp_cashco_`var' = ((cashcopq+cashcocq)*`var') if quarter == 3
	}

    format wtexp_* %16.1gc
	br wtexp_*
 
  **** 5-2) Aggregation for Replicate 1 
 foreach var of varlist wtexp_totexp_wtrep*{ 
 egen sumtotexp_`var' = sum(`var')
 } 
 
foreach var of varlist wtexp_foodalc_wtrep*{ 
 egen sumfoodalc_`var' = sum(`var')
 }
  
 foreach var of varlist wtexp_misc_wtrep*{ 
 egen summisc_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_hous_wtrep*{ 
 egen sumhous_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_appar_wtrep*{ 
 egen sumappar_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_trans_wtrep*{ 
 egen sumtrans_`var' = sum(`var')
 }
 
  foreach var of varlist wtexp_health_wtrep*{ 
 egen sumhealth_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_entert_wtrep*{ 
 egen sumentert_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_educa_wtrep*{ 
 egen sumeduca_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_perins_wtrep*{ 
 egen sumperins_`var' = sum(`var')
 }
 
 foreach var of varlist wtexp_cashco_wtrep*{ 
 egen sumcashco_`var' = sum(`var')
 }
 
  ****** 5-3) Getting Replicate Mean (M1, M2, .... M44)
 foreach var of varlist tmp_wtrep*{
 egen sumpopwt_`var' = sum(`var')
 }
 
	*** 5-3-0) Total Expenditure
foreach n of numlist 1(1)9 {
gen M`n'_totexp = sumtotexp_wtexp_totexp_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_totexp = sumtotexp_wtexp_totexp_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_totexp_`n' = (M`n'_totexp - GM_totexp)^2
  }
   
  egen sumdiff_totexp = rowtotal(diff_totexp_*) 
  gen se_totexp = sqrt(sumdiff_totexp/44)
  br se_totexp
	
	**** 5-3-1) Food & Alcohol
foreach n of numlist 1(1)9 {
gen M`n'_foodalc = sumfoodalc_wtexp_foodalc_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_foodalc = sumfoodalc_wtexp_foodalc_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }

  foreach n of numlist 1(1)44 {
  gen diff_foodalc_`n' = (M`n'_foodalc - GM_foodalc)^2
  }
  
  egen sumdiff_foodalc = rowtotal(diff_foodalc_*)
  
  gen se_foodalc = sqrt(sumdiff_foodalc/44)
  br GM_foodalc se_foodalc
	
	*** 5-3-1) misc_ 
 foreach n of numlist 1(1)9 {
gen M`n'_misc = summisc_wtexp_misc_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_misc = summisc_wtexp_misc_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_misc_`n' = (M`n'_misc - GM_misc)^2
  }
   
  egen sumdiff_misc = rowtotal(diff_misc_*) 
  gen se_misc = sqrt(sumdiff_misc/44)
  
  br se_misc
  
  save "$outPath\SE Calculation_MC_Result"
  
    *** 5-3-2) hous 
 foreach n of numlist 1(1)9 {
gen M`n'_hous = sumhous_wtexp_hous_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_hous = sumhous_wtexp_hous_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_hous_`n' = (M`n'_hous - GM_hous)^2
  }
   
  egen sumdiff_hous = rowtotal(diff_hous_*) 
  gen se_hous = sqrt(sumdiff_hous/44)
  
  br se_hous
  
	*** 5-3-3) appar 
 foreach n of numlist 1(1)9 {
gen M`n'_appar = sumappar_wtexp_appar_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_appar = sumappar_wtexp_appar_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_appar_`n' = (M`n'_appar - GM_appar)^2
  }
   
  egen sumdiff_appar = rowtotal(diff_appar_*) 
  gen se_appar = sqrt(sumdiff_appar/44)
  br se_appar
	
	*** 5-3-4) trans
foreach n of numlist 1(1)9 {
gen M`n'_trans = sumtrans_wtexp_trans_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_trans = sumtrans_wtexp_trans_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_trans_`n' = (M`n'_trans - GM_trans)^2
  }
   
  egen sumdiff_trans = rowtotal(diff_trans_*) 
  gen se_trans = sqrt(sumdiff_trans/44)
  br se_trans
	
	*** 5-3-5) health 
foreach n of numlist 1(1)9 {
gen M`n'_health = sumhealth_wtexp_health_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_health = sumhealth_wtexp_health_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_health_`n' = (M`n'_health - GM_health)^2
  }
   
  egen sumdiff_health = rowtotal(diff_health_*) 
  gen se_health = sqrt(sumdiff_health/44)
  br se_health
  
	*** 5-3-6) entert
foreach n of numlist 1(1)9 {
gen M`n'_entert = sumentert_wtexp_entert_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_entert = sumentert_wtexp_entert_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_entert_`n' = (M`n'_entert - GM_entert)^2
  }
   
  egen sumdiff_entert = rowtotal(diff_entert_*) 
  gen se_entert = sqrt(sumdiff_entert/44)
  
  br se_entert
	
	*** 5-3-7) educa
foreach n of numlist 1(1)9 {
gen M`n'_educa = sumeduca_wtexp_educa_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_educa = sumeduca_wtexp_educa_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_educa_`n' = (M`n'_educa - GM_educa)^2
  }
   
  egen sumdiff_educa = rowtotal(diff_educa_*) 
  gen se_educa = sqrt(sumdiff_educa/44)
  
  br se_educa
	
	*** 5-3-8) perins 
foreach n of numlist 1(1)9 {
gen M`n'_perins = sumperins_wtexp_perins_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_perins = sumperins_wtexp_perins_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_perins_`n' = (M`n'_perins - GM_perins)^2
  }
   
  egen sumdiff_perins = rowtotal(diff_perins_*) 
  gen se_perins = sqrt(sumdiff_perins/44)
  
  br se_perins
	
	*** 5-3-9) cashco
foreach n of numlist 1(1)9 {
gen M`n'_cashco = sumcashco_wtexp_cashco_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_cashco = sumcashco_wtexp_cashco_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }
   
  foreach n of numlist 1(1)44 {
  gen diff_cashco_`n' = (M`n'_cashco - GM_cashco)^2
  }
   
  egen sumdiff_cashco = rowtotal(diff_cashco_*) 
  gen se_cashco = sqrt(sumdiff_cashco/44)
  
  br se_cashco
  
  br GM* se_*
  save "$outPath\SE Calculation_MC_Result", replace  
  ///// Fill in the Excel file first ///
  use "$outPath\SE Calculation_MC_Result", clear
  
 ********************************************************************************
 ******************* Data Fix: Forgot Total expenditure *************************
use "$outPath\SE Calculation_MC", clear
 
 #d ;
keep quarter qintrvmo month newid totexppq totexpcq finlwt21 $replicates ;

gen wtexp_totexp = totexpcq*finlwt21 if quarter == 1
 replace wtexp_totexp = totexppq*finlwt21 if quarter == 5
 replace wtexp_totexp = ((totexpcq + totexppq)*finlwt21) if quarter == 3
 
 format wtexp_totexp %16.1gc
 
egen sumexp_totexp = sum(wtexp_totexp)
egen sumpopwt = sum(popwt)
gen GM_totexp = sumexp_totexp/sumpopwt

  **** 5-1) Weighted Expenditure for Total Expenditure
foreach var of varlist $replicates {
gen wtexp_totexp_`var' = totexpcq*`var' if quarter == 1
    replace wtexp_totexp_`var' = totexppq*`var' if quarter == 5
	replace wtexp_totexp_`var' = ((totexpcq+totexppq)*`var') if quarter == 3
	}

	br wtexp_totexp_*
    format wtexp_totexp_* %16.1gc
	
   **** 5-2) Aggregation for Replicate 1 
 foreach var of varlist wtexp_totexp_wtrep*{ 
 egen sumtotexp_`var' = sum(`var')
 }
 
   **** 5-3) Population Aggregate for every Replicate 44
 foreach var of varlist tmp_wtrep*{
 egen sumpopwt_`var' = sum(`var')
 }
 
   **** 5-3) Getting Replicate Mean (M1, M2, .... M44)
 foreach n of numlist 1(1)9 {
gen M`n'_totexp = sumtotexp_wtexp_totexp_wtrep0`n'/sumpopwt_tmp_wtrep0`n'
}

 foreach n of numlist 10(1)44 {
 gen M`n'_totexp = sumtotexp_wtexp_totexp_wtrep`n'/sumpopwt_tmp_wtrep`n'
 }

  br GM_foodalc RM01_foodalc
  br GM_totexp M*_totexp
  
  foreach n of numlist 1(1)44 {
  gen diff_totexp_`n' = (M`n'_totexp - GM_totexp)^2
  }
  
  br diff_totexp*
  egen sumdiff_totexp = rowtotal(diff_totexp_*)
  format sumdiff_totexp %16.1gc
  br sumdiff_totexp
  
  gen se_totexp = sqrt(sumdiff_totexp/44)
  br GM_totexp se_totexp
  **** How to interprete the result ***
  ** So, the S.E for Middle Class Total Expenditure = 666 & Mean = 62,155
  ** At the 90% confidence level, Middle Class expenditure level will be between 62,155 - 1.645*666 and 62,155 + 1.645*666
  ** At the 95% confidence level, Middle Class expenditure level will be between 62,155 - 1.96*666 and 62,155 + 1.96*666
  ** At the 99% confidence level, Middle Class expenditure level will be between 62,155 - 2.576*666 and 62,155 + 2.576*666
  
 save "$outPath\SE Calculation_MC_Result_totexp"
********************************************************************************
************* Repeat the above process for Lower Class ******************
 use "$outPath\SE Calculation_LC", clear
  /// Use the above command
    br GM* se_*
  
 save "$outPath\SE Calculation_LC_Result"
 
************* Repeat the above process for Upper Class ******************
  use "$outPath\SE Calculation_UC", clear
   br GM* se_*
  save "$outPath\SE Calculation_UC_Result"
 
 
 
 ************* Do I want to calculate the S.E for Metropolitan Samples? Yes! Code is there. 

 ***************************** Metro Areas *******************************************
use "$outPath\Interview2015", clear
br $replicates

 **** 1. Making a separate file for each metro
keep if strpos(CBSATitle, "New York")>0 
save  "$outPath\Interview2015_NewYork"


foreach i in Boston Philadelphia Chicago Detroit Minneapolis Louis Washington Miami Atlanta Tampa Baltimore Dallas Houston Phoenix Denver Angeles Francisco Riverside Seattle Diego Honolulu Anchorage {
 use "$outPath\Interview2015", clear
 keep if strpos(CBSATitle, "`i'")>0
 save "$outPath\Interview2015_`i'"
 }
 
 ***************** Example 1: New York Metro Area **************************************
 use "$outPath2\Interview2015_NewYork", clear
 keep if MC_D2 == 1
 save "$outPath2\SE Calculation_NewYork_LC"

 use "$outPath2\Interview2015_NewYork", clear
 keep if MC_D2 == 2 
 save "$outPath2\SE Calculation_NewYork_MC"

 use "$outPath2\Interview2015_NewYork", clear
 keep if MC_D2 == 3 
 save "$outPath2\SE Calculation_NewYork_UC"
 
 **** Dividing MetroSample into Three Classes
 foreach i in Boston Philadelphia Chicago Detroit Minneapolis Louis Washington Miami Atlanta Tampa Baltimore Dallas Houston Phoenix Denver Angeles Francisco Riverside Seattle Diego Honolulu Anchorage {
 use "$outPath2\Interview2015_`i'", clear
 keep if MC_D2 == 1
 save "$outPath2\SE Calculation_`i'_LC"
 
 use "$outPath2\Interview2015_`i'", clear
 keep if MC_D2 == 2 
 save "$outPath2\SE Calculation_`i'_MC"
 
 use "$outPath2\Interview2015_`i'", clear
 keep if MC_D2 == 3 
 save "$outPath2\SE Calculation_`i'_UC"
 }
 
 **** For Individual File, repeat the above command
  ** 1) NewYork_LC
 use "$outPath2\SE Calculation_NewYork_LC", clear
 
  // Use Another Do file for Repeat the above process// 
  br GM* se_*
  keep newid finlwt21 qintrvmo GM* se_*
  
  foreach i in foodalc misc_ hous appar trans health entert educa perins cashco {
  gen `i'_pct = (GM_`i'/GM_totexp)*100
  }
  
  save "$outPath2\SE Calculation_NewYork_LC_Result", replace
 
 use "$outPath2\SE Calculation_NewYork_MC", clear
 save "$outPath2\SE Calculation_NewYork_MC_Result"
 
 use "$outPath2\SE Calculation_NewYork_UC", clear
 save "$outPath2\SE Calculation_NewYork_UC_Result"
 
  br GM* se* *_pct
 
  use "$outPath2\SE Calculation_NewYork_LC_Result", clear
  use "$outPath2\SE Calculation_NewYork_MC_Result", clear
  use "$outPath2\SE Calculation_NewYork_UC_Result", clear
 
 ** 2) Boston
  use "$outPath2\SE Calculation_Boston_LC", clear
  save "$outPath2\SE Calculation_Boston_LC_Result"
  
  use "$outPath2\SE Calculation_Boston_MC", clear 
  save "$outPath2\SE Calculation_Boston_MC_Result"
   
  use "$outPath2\SE Calculation_Boston_UC", clear
  save "$outPath2\SE Calculation_Boston_UC_Result"
  
   br GM* se* *_pct
	
  use "$outPath2\SE Calculation_Boston_LC_Result", clear
  use "$outPath2\SE Calculation_Boston_MC_Result", clear
  use "$outPath2\SE Calculation_Boston_UC_Result", clear
 
 ** 3) Philadelphia 
   use "$outPath2\SE Calculation_Philadelphia_LC", clear
  save "$outPath2\SE Calculation_Philadelphia_LC_Result"
  
  use "$outPath2\SE Calculation_Philadelphia_MC", clear 
  save "$outPath2\SE Calculation_Philadelphia_MC_Result"
   
  use "$outPath2\SE Calculation_Philadelphia_UC", clear
  save "$outPath2\SE Calculation_Philadelphia_UC_Result"
  
     br GM* se* *_pct
	 use "$outPath2\SE Calculation_Philadelphia_LC_Result", clear
	 use "$outPath2\SE Calculation_Philadelphia_MC_Result", clear
	 use "$outPath2\SE Calculation_Philadelphia_UC_Result", clear
 
 ** 4) Chicago 
   use "$outPath2\SE Calculation_Chicago_LC", clear
  save "$outPath2\SE Calculation_Chicago_LC_Result"
  
  use "$outPath2\SE Calculation_Chicago_MC", clear 
  save "$outPath2\SE Calculation_Chicago_MC_Result"
   
  use "$outPath2\SE Calculation_Chicago_UC", clear
  save "$outPath2\SE Calculation_Chicago_UC_Result"
  
       br GM* se* *_pct
	   use "$outPath2\SE Calculation_Chicago_LC_Result", clear
	   use "$outPath2\SE Calculation_Chicago_MC_Result", clear
	   use "$outPath2\SE Calculation_Chicago_UC_Result", clear
 
 ** 5) Detroit 
   use "$outPath2\SE Calculation_Detroit_LC", clear
  save "$outPath2\SE Calculation_Detroit_LC_Result"
  
  use "$outPath2\SE Calculation_Detroit_MC", clear 
  save "$outPath2\SE Calculation_Detroit_MC_Result"
   
  use "$outPath2\SE Calculation_Detroit_UC", clear
  save "$outPath2\SE Calculation_Detroit_UC_Result"
  
         br GM* se* *_pct
		 use "$outPath2\SE Calculation_Detroit_LC_Result", clear
		 use "$outPath2\SE Calculation_Detroit_MC_Result", clear
		 use "$outPath2\SE Calculation_Detroit_UC_Result", clear
 
 ** 6) Minneapolis 
  use "$outPath2\SE Calculation_Minneapolis_LC", clear
  save "$outPath2\SE Calculation_Minneapolis_LC_Result"
  
  use "$outPath2\SE Calculation_Minneapolis_MC", clear 
  save "$outPath2\SE Calculation_Minneapolis_MC_Result"
   
  use "$outPath2\SE Calculation_Minneapolis_UC", clear
  save "$outPath2\SE Calculation_Minneapolis_UC_Result"
  
         br GM* se* *_pct
		 use "$outPath2\SE Calculation_Minneapolis_LC_Result", clear
		 use "$outPath2\SE Calculation_Minneapolis_MC_Result", clear
		 use "$outPath2\SE Calculation_Minneapolis_UC_Result", clear
 
 ** 7) Louis 
   use "$outPath2\SE Calculation_Louis_LC", clear
  save "$outPath2\SE Calculation_Louis_LC_Result"
  
  use "$outPath2\SE Calculation_Louis_MC", clear 
  save "$outPath2\SE Calculation_Louis_MC_Result"
   
  use "$outPath2\SE Calculation_Louis_UC", clear
  save "$outPath2\SE Calculation_Louis_UC_Result"
  
   br GM* se* *_pct
   use "$outPath2\SE Calculation_Louis_LC_Result", clear
   use "$outPath2\SE Calculation_Louis_MC_Result", clear
   use "$outPath2\SE Calculation_Louis_UC_Result", clear
 
 ** 8) Washington 
  use "$outPath2\SE Calculation_Washington_LC", clear
  save "$outPath2\SE Calculation_Washington_LC_Result"
  
  use "$outPath2\SE Calculation_Washington_MC", clear 
  save "$outPath2\SE Calculation_Washington_MC_Result"
   
  use "$outPath2\SE Calculation_Washington_UC", clear
  save "$outPath2\SE Calculation_Washington_UC_Result"
  
     br GM* se* *_pct
	 use "$outPath2\SE Calculation_Washington_LC_Result", clear
	 use "$outPath2\SE Calculation_Washington_MC_Result", clear
	 use "$outPath2\SE Calculation_Washington_UC_Result", clear
 
 ** 9) Miami 
  use "$outPath2\SE Calculation_Miami_LC", clear
  save "$outPath2\SE Calculation_Miami_LC_Result"
  
  use "$outPath2\SE Calculation_Miami_MC", clear 
  save "$outPath2\SE Calculation_Miami_MC_Result"
   
  use "$outPath2\SE Calculation_Miami_UC", clear
  save "$outPath2\SE Calculation_Miami_UC_Result"
  
       br GM* se* *_pct
	   use "$outPath2\SE Calculation_Miami_LC_Result", clear
	   use "$outPath2\SE Calculation_Miami_MC_Result", clear
	   use "$outPath2\SE Calculation_Miami_UC_Result", clear
 
 ** 10) Atlanta 
  use "$outPath2\SE Calculation_Atlanta_LC", clear
  save "$outPath2\SE Calculation_Atlanta_LC_Result"
  
  use "$outPath2\SE Calculation_Atlanta_MC", clear 
  save "$outPath2\SE Calculation_Atlanta_MC_Result"
   
  use "$outPath2\SE Calculation_Atlanta_UC", clear
  save "$outPath2\SE Calculation_Atlanta_UC_Result"
  
         br GM* se* *_pct
		 use "$outPath2\SE Calculation_Atlanta_LC_Result", clear
		 use "$outPath2\SE Calculation_Atlanta_MC_Result", clear
		 use "$outPath2\SE Calculation_Atlanta_UC_Result", clear
 
 ** 11) Tampa 
   use "$outPath2\SE Calculation_Tampa_LC", clear
  save "$outPath2\SE Calculation_Tampa_LC_Result"
  
  use "$outPath2\SE Calculation_Tampa_MC", clear 
  save "$outPath2\SE Calculation_Tampa_MC_Result"
   
  use "$outPath2\SE Calculation_Tampa_UC", clear
  save "$outPath2\SE Calculation_Tampa_UC_Result"
  
           br GM* se* *_pct
		   use "$outPath2\SE Calculation_Tampa_LC_Result", clear
		   use "$outPath2\SE Calculation_Tampa_MC_Result", clear
		   use "$outPath2\SE Calculation_Tampa_UC_Result", clear
 
 ** 12) Baltimore 
  use "$outPath2\SE Calculation_Baltimore_LC", clear
  save "$outPath2\SE Calculation_Baltimore_LC_Result"
  
  use "$outPath2\SE Calculation_Baltimore_MC", clear 
  save "$outPath2\SE Calculation_Baltimore_MC_Result"
   
  use "$outPath2\SE Calculation_Baltimore_UC", clear
  save "$outPath2\SE Calculation_Baltimore_UC_Result"
  
             br GM* se* *_pct
			 use "$outPath2\SE Calculation_Baltimore_LC_Result", clear
			 use "$outPath2\SE Calculation_Baltimore_MC_Result", clear
			 use "$outPath2\SE Calculation_Baltimore_UC_Result", clear
 
 ** 13) Dallas 
  use "$outPath2\SE Calculation_Dallas_LC", clear
  save "$outPath2\SE Calculation_Dallas_LC_Result"
  
  use "$outPath2\SE Calculation_Dallas_MC", clear 
  save "$outPath2\SE Calculation_Dallas_MC_Result"
   
  use "$outPath2\SE Calculation_Dallas_UC", clear
  save "$outPath2\SE Calculation_Dallas_UC_Result"
  
             br GM* se* *_pct
             use "$outPath2\SE Calculation_Dallas_LC_Result", clear
			 use "$outPath2\SE Calculation_Dallas_MC_Result", clear
			 use "$outPath2\SE Calculation_Dallas_UC_Result", clear
 
 ** 14) Houston 
  use "$outPath2\SE Calculation_Houston_LC", clear
  save "$outPath2\SE Calculation_Houston_LC_Result"
  
  use "$outPath2\SE Calculation_Houston_MC", clear 
  save "$outPath2\SE Calculation_Houston_MC_Result"
   
  use "$outPath2\SE Calculation_Houston_UC", clear
  save "$outPath2\SE Calculation_Houston_UC_Result"
  
               br GM* se* *_pct
			   use "$outPath2\SE Calculation_Houston_LC_Result", clear
			   use "$outPath2\SE Calculation_Houston_MC_Result", clear
			   use "$outPath2\SE Calculation_Houston_UC_Result", clear
 
 ** 15) Phoenix 
  use "$outPath2\SE Calculation_Phoenix_LC", clear
  save "$outPath2\SE Calculation_Phoenix_LC_Result"
  
  use "$outPath2\SE Calculation_Phoenix_MC", clear 
  save "$outPath2\SE Calculation_Phoenix_MC_Result"
   
  use "$outPath2\SE Calculation_Phoenix_UC", clear
  save "$outPath2\SE Calculation_Phoenix_UC_Result"
  
             br GM* se* *_pct
			 use "$outPath2\SE Calculation_Phoenix_LC_Result", clear
			 use "$outPath2\SE Calculation_Phoenix_MC_Result", clear
			 use "$outPath2\SE Calculation_Phoenix_UC_Result", clear
 
 ** 16) Denver 
  use "$outPath2\SE Calculation_Denver_LC", clear
  save "$outPath2\SE Calculation_Denver_LC_Result"
  
  use "$outPath2\SE Calculation_Denver_MC", clear 
  save "$outPath2\SE Calculation_Denver_MC_Result"
   
  use "$outPath2\SE Calculation_Denver_UC", clear
  save "$outPath2\SE Calculation_Denver_UC_Result"
  
               br GM* se* *_pct
               use "$outPath2\SE Calculation_Denver_LC_Result", clear
			   use "$outPath2\SE Calculation_Denver_MC_Result", clear
			   use "$outPath2\SE Calculation_Denver_UC_Result", clear
 
 ** 17) Angeles 
  use "$outPath2\SE Calculation_Angeles_LC", clear
  save "$outPath2\SE Calculation_Angeles_LC_Result"
  
  use "$outPath2\SE Calculation_Angeles_MC", clear 
  save "$outPath2\SE Calculation_Angeles_MC_Result"
   
  use "$outPath2\SE Calculation_Angeles_UC", clear
  save "$outPath2\SE Calculation_Angeles_UC_Result"
  
                 br GM* se* *_pct
				 use "$outPath2\SE Calculation_Angeles_LC_Result", clear
				 use "$outPath2\SE Calculation_Angeles_MC_Result", clear
				 use "$outPath2\SE Calculation_Angeles_UC_Result", clear
 
 ** 18) Francisco 
   use "$outPath2\SE Calculation_Francisco_LC", clear
  save "$outPath2\SE Calculation_Francisco_LC_Result"
  
  use "$outPath2\SE Calculation_Francisco_MC", clear 
  save "$outPath2\SE Calculation_Francisco_MC_Result"
   
  use "$outPath2\SE Calculation_Francisco_UC", clear
  save "$outPath2\SE Calculation_Francisco_UC_Result"
  
                   br GM* se* *_pct
				   use "$outPath2\SE Calculation_Francisco_LC_Result", clear
				   use "$outPath2\SE Calculation_Francisco_MC_Result", clear
				   use "$outPath2\SE Calculation_Francisco_UC_Result", clear
 
 ** 19) Riverside 
  use "$outPath2\SE Calculation_Riverside_LC", clear
  save "$outPath2\SE Calculation_Riverside_LC_Result"
  
  use "$outPath2\SE Calculation_Riverside_MC", clear 
  save "$outPath2\SE Calculation_Riverside_MC_Result"
   
  use "$outPath2\SE Calculation_Riverside_UC", clear
  save "$outPath2\SE Calculation_Riverside_UC_Result"
  
                    br GM* se* *_pct
					use "$outPath2\SE Calculation_Riverside_LC_Result", clear
					use "$outPath2\SE Calculation_Riverside_MC_Result", clear
					use "$outPath2\SE Calculation_Riverside_UC_Result", clear
 
 ** 20) Seattle 
  use "$outPath2\SE Calculation_Seattle_LC", clear
  save "$outPath2\SE Calculation_Seattle_LC_Result"
  
  use "$outPath2\SE Calculation_Seattle_MC", clear 
  save "$outPath2\SE Calculation_Seattle_MC_Result"
   
  use "$outPath2\SE Calculation_Seattle_UC", clear
  save "$outPath2\SE Calculation_Seattle_UC_Result"
  
                      br GM* se* *_pct
					  use "$outPath2\SE Calculation_Seattle_LC_Result", clear
					  use "$outPath2\SE Calculation_Seattle_MC_Result", clear
					  use "$outPath2\SE Calculation_Seattle_UC_Result", clear
 
 ** 21) Diego
  use "$outPath2\SE Calculation_Diego_LC", clear
  save "$outPath2\SE Calculation_Diego_LC_Result"
  
  use "$outPath2\SE Calculation_Diego_MC", clear 
  save "$outPath2\SE Calculation_Diego_MC_Result"
   
  use "$outPath2\SE Calculation_Diego_UC", clear
  save "$outPath2\SE Calculation_Diego_UC_Result"
  
                      br GM* se* *_pct
					  use "$outPath2\SE Calculation_Diego_LC_Result", clear
					  use "$outPath2\SE Calculation_Diego_MC_Result", clear
					  use "$outPath2\SE Calculation_Diego_UC_Result", clear
 
 ** 22) Honolulu 
   use "$outPath2\SE Calculation_Honolulu_LC", clear
  save "$outPath2\SE Calculation_Honolulu_LC_Result"
  
  use "$outPath2\SE Calculation_Honolulu_MC", clear 
  save "$outPath2\SE Calculation_Honolulu_MC_Result"
   
  use "$outPath2\SE Calculation_Honolulu_UC", clear
  save "$outPath2\SE Calculation_Honolulu_UC_Result"
  
                        br GM* se* *_pct
						use "$outPath2\SE Calculation_Honolulu_LC_Result", clear
						use "$outPath2\SE Calculation_Honolulu_MC_Result", clear
						use "$outPath2\SE Calculation_Honolulu_UC_Result", clear
 
 ** 23) Anchorage
  use "$outPath2\SE Calculation_Anchorage_LC", clear
  save "$outPath2\SE Calculation_Anchorage_LC_Result"
  
  use "$outPath2\SE Calculation_Anchorage_MC", clear 
  save "$outPath2\SE Calculation_Anchorage_MC_Result"
   
  use "$outPath2\SE Calculation_Anchorage_UC", clear
  save "$outPath2\SE Calculation_Anchorage_UC_Result"
 
                        br GM* se* *_pct
						use "$outPath2\SE Calculation_Anchorage_LC_Result", clear
						use "$outPath2\SE Calculation_Anchorage_MC_Result", clear
						use "$outPath2\SE Calculation_Anchorage_UC_Result", clear
 
 
 
 
 
 
 