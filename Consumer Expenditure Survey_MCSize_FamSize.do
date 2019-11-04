
***************** Consumer Expenditure Survey (Rosa's Code Added)***************************

******************************** Procedure **************************************
 ** 1) Data Appending & Cleaning (Leaving only metro area - PSU)
 ** 2) Creating Middle Class Dummy Variable using Definition 2 (between 75% and 250% of the national median household income)
    ** Caution: If you are using different survey year, you have to use that year's national median household income
    ** 2- A) Use "fam_size" for the household size adjustment (Updated Feb, 2019) 
	** 2- B) Cost-of-living adjustment (Importing COLI-adjusted MC Size Statistics from Moody 2015, only Definition 2)
	** 2- C) See how many household classified differently
 ** 3) Descriptive statistics by metro or Census Region
 
 ** 4) Aggregating Consumption Categories
 ** 5) Getting Annual Expenditure & Calculating Proportion 
*********************************************************************************

  ** Setting up some global macro 
global inPath   = "C:\Users\bihon\Dropbox\Thesis Bank\Data\BLS\Consumer Expenditure Survey\PUMD_Public Use Micro Data\2015_Interview_STATA\intrvw15"  
/*Pathway for importing data.*/

global outPath  = "C:\Users\bihon\Dropbox\Thesis Bank\Essay 2\CES_Interview2015"  
/*Pathway for saving data.*/  

global replicates = "wtrep01-wtrep44"
global wtrepvar = "awtrep01_foodalc-awtrep44_cashco";   

#d ;
use "$inPath\fmli151x.dta" ; 
append using "$inPath\fmli152.dta" ;
append using "$inPath\fmli153.dta" ;
append using "$inPath\fmli154.dta" ;  
append using "$inPath\fmli161.dta" ;

/*The following steps create three groups for quarters. Since quarter 2, 3, and 
  4 are treated the same, we call them all quarter '3.' Quarter 1 and quarter 5
  have special rules for determining which observations are classified.*/
  
gen quarter = 3 ;

replace quarter = 1 if (qintrvmo == "01" | qintrvmo == "02" | qintrvmo == "03")
& qintrvyr == "2015" ;
replace quarter = 5 if (qintrvmo == "01" | qintrvmo == "02" | qintrvmo == "03")
& qintrvyr == "2016" ;

save "$outPath\Interview2015_FamSizeAdj"

br $replicates
br qintrvyr
br fam_size


  ** 1) Data Cleaning (Leaing only PSU)
br psu
count if psu == ""
count if psu != ""
drop if psu == ""  
sort psu

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

label var fincbtxm "Consumer Unit income before taxes in past 12 months"
sum fam_size, de
br fam_size fincbtxm
br fam_size fincbtxm if fam_size > 10
  // There are five households with more than 10 family member
count if fam_size > 8
  // 27 households

 save "$outPath\Interview2015_FamSizeAdj", replace
 
  ** 1-B) Household Income Adjusted according to its family size
      ** Weights for the Equivalance scale = 0.5 following literature **
 gen fincbtxm_adj = fincbtxm/(fam_size)^0.5
 br fam_size fincbtxm*
 
  ** 2) Middle Class Category for 2015 (before COLI adjusted)
   *** Middle Class Definition: between 75% and 250% of the national median household income ***
  scalar nmhi_2015 = 56516
  // nmhi = national median household income in 2015
  scalar lbmc2015_D2= 42387 
  //lower bound of the Middle Class according to Definition 2
  scalar ubmc2015_D2= 141290 
  //upper bound for Middle Class according to Definition 2
   
   ** 2- A) Middle Class Grouping, Before Household size adjustment, Before COLI-adjustment
  gen MC_D2 = 1
   replace MC_D2 = 2 if fincbtxm >= 42387 & fincbtxm < 141290
   replace MC_D2 = 3 if fincbtxm >= 141290
   label define Class 1 "Lower Class" 2 "Middle Class" 3 "Upper Class"
   label values MC_D2 Class

   ** 2- B) Middle Class Grouping, After Household size adjustment
  gen MC_D2_famsiz = 1
    replace MC_D2_famsiz = 2 if fincbtxm_adj >= 42387 & fincbtxm_adj < 141290
	replace MC_D2_famsiz = 3 if fincbtxm_adj >= 141290
	label values MC_D2_famsiz Class

   ** 2- C) Find out how many CUs changes its class status after adjusting Household size 
   br CBSATitle psu MC_D2 MC_D2_famsiz fam_size fincbtxm*
   sum
   count if MC_D2 != MC_D2_famsiz
   // 3113
   count if MC_D2 == 2 & MC_D2_famsiz == 1
   // 1894 households who were initially categorized as "middle class", now re-categorized as "lower class"
   count if MC_D2 == 3 & MC_D2_famsiz == 2
   // 1219 households who were initially categorized as "upper class", now re-categorized as "middle class"
   
   ** 2-D) Descriptive Statistics by each metro area
tab MC_D2_famsiz if strpos(CBSATitle, "New York")>0 
tab MC_D2_famsiz if strpos(CBSATitle, "Los Angeles")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Chicago")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Dallas")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Philadelphia")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Houston")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Washington")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Miami")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Atlanta")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Boston")>0
tab MC_D2_famsiz if strpos(CBSATitle, "San Francisco")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Detroit")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Seattle")>0
tab MC_D2_famsiz if strpos(CBSATitle, "St. Louis")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Denver")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Baltimore")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Honolulu")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Minneapolis")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Phoenix")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Riverside")>0
tab MC_D2_famsiz if strpos(CBSATitle, "San Diego")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Tampa")>0
tab MC_D2_famsiz if strpos(CBSATitle, "Anchorage")>0

  ** 3. Middle Class Category for 2015 (After COLI adjusted):how many households are affected by the COLI-adjusted definition?
    *** COLI index from Moody's Analytics. 
   ** ( Example: Chicago Areas COLI = 97.61 in 2015, and the median household income for Chicago is adjusted = nmhi*0.9761) 
   ** ( Then, each metro areas has its own middle class definition - between 75% and 250% of that adjusted nmhi) ** 
gen adjM_lbmc15_D2 = .
replace adjM_lbmc15_D2 = 48499.20 if psu == "S11A"
replace adjM_lbmc15_D2 = 49558.88 if psu == "S12A"
replace adjM_lbmc15_D2 = 44629.27 if psu == "S12B"
replace adjM_lbmc15_D2 = 41373.95 if psu == "S23A"
replace adjM_lbmc15_D2 = 39258.84 if psu == "S23B"
replace adjM_lbmc15_D2 = 42827.37 if psu == "S24A"
replace adjM_lbmc15_D2 = 40017.39 if psu == "S24B"
replace adjM_lbmc15_D2 = 51792.67 if psu == "S35A"
replace adjM_lbmc15_D2 = 47312.37 if psu == "S35B"
replace adjM_lbmc15_D2 = 43083.40 if psu == "S35C"
replace adjM_lbmc15_D2 = 43022.70 if psu == "S35D"
replace adjM_lbmc15_D2 = 44971.61 if psu == "S35E"
replace adjM_lbmc15_D2 = 44951.41 if psu == "S37A"
replace adjM_lbmc15_D2 = 45556.91 if psu == "S37B"
replace adjM_lbmc15_D2 = 44951.63 if psu == "S48A"
replace adjM_lbmc15_D2 = 46785.94 if psu == "S48B"
replace adjM_lbmc15_D2 = 57485.25 if psu == "S49A"
replace adjM_lbmc15_D2 = 66250.88 if psu == "S49B"
replace adjM_lbmc15_D2 = 46424.84 if psu == "S49C"
replace adjM_lbmc15_D2 = 49190.12 if psu == "S49D"
replace adjM_lbmc15_D2 = 54434.66 if psu == "S49E"
replace adjM_lbmc15_D2 = 60535.21 if psu == "S49F"
replace adjM_lbmc15_D2 = 48418.49 if psu == "S49G"

gen adjM_ubmc15_D2 = .
replace adjM_ubmc15_D2 = 161664.02 if psu == "S11A"
replace adjM_ubmc15_D2 = 163967.05 if psu == "S12A"
replace adjM_ubmc15_D2 = 148764.23 if psu == "S12B"
replace adjM_ubmc15_D2 = 137913.17 if psu == "S23A"
replace adjM_ubmc15_D2 = 130862.80 if psu == "S23B"
replace adjM_ubmc15_D2 = 142757.89 if psu == "S24A"
replace adjM_ubmc15_D2 = 133391.31 if psu == "S24B"
replace adjM_ubmc15_D2 = 172642.25 if psu == "S35A"
replace adjM_ubmc15_D2 = 157707.89 if psu == "S35B"
replace adjM_ubmc15_D2 = 143611.33 if psu == "S35C"
replace adjM_ubmc15_D2 = 143408.97 if psu == "S35D"
replace adjM_ubmc15_D2 = 149905.38 if psu == "S35E"
replace adjM_ubmc15_D2 = 149838.05 if psu == "S37A"
replace adjM_ubmc15_D2 = 151856.38 if psu == "S37B"
replace adjM_ubmc15_D2 = 149838.77 if psu == "S48A"
replace adjM_ubmc15_D2 = 155953.14 if psu == "S48B"
replace adjM_ubmc15_D2 = 191617.5 if psu == "S49A"
replace adjM_ubmc15_D2 = 220836.27 if psu == "S49B"
replace adjM_ubmc15_D2 = 154749.47 if psu == "S49C"
replace adjM_ubmc15_D2 = 163967.05 if psu == "S49D"
replace adjM_ubmc15_D2 = 181448.88 if psu == "S49E"
replace adjM_ubmc15_D2 = 201784.03 if psu == "S49F"
replace adjM_ubmc15_D2 = 161394.97 if psu == "S49G"

save "$outPath\Interview2015_FamSizeAdj", replace

** 3- A) Middle Class Grouping, Before Household size adjustment, After COLI-adjustment
 gen adjM_MC_D2 = 1 if fincbtxm < adjM_lbmc15_D2
     replace adjM_MC_D2 = 2 if fincbtxm >= adjM_lbmc15_D2 & fincbtxm < adjM_ubmc15_D2
     replace adjM_MC_D2 = 3 if fincbtxm >= adjM_ubmc15_D2

 label define adjM_Class 1 "Adjusted Lower Class" 2 "Adjusted Middle Class" 3 "Adjusted Upper Class"
 label values adjM_MC_D2 adjM_Class

** 3- B) Middle Class Grouping, After Household size adjustment
  gen adjM_MC_D2_famsiz = 1 
      replace adjM_MC_D2_famsiz = 2 if fincbtxm_adj >= adjM_lbmc15_D2 & fincbtxm_adj < adjM_ubmc15_D2
	  replace adjM_MC_D2_famsiz = 3 if fincbtxm_adj >= adjM_ubmc15_D2
  label values adjM_MC_D2_famsiz adjM_Class
  
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "New York")>0 
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Los Angeles")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Chicago")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Dallas")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Philadelphia")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Houston")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Washington")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Miami")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Atlanta")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Boston")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "San Francisco")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Detroit")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Seattle")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "St. Louis")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Denver")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Baltimore")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Honolulu")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Minneapolis")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Phoenix")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Riverside")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "San Diego")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Tampa")>0
tab adjM_MC_D2_famsiz if strpos(CBSATitle, "Anchorage")>0
  
  /// Now, see the updated category. It is recommended to see household size adjusted class category. 
  br CBSATitle MC_D2 MC_D2_famsiz adjM_MC_D2 adjM_MC_D2_famsiz
  tab MC_D2
  tab adjM_MC_D2
  tab MC_D2_famsiz
  tab adjM_MC_D2_famsiz
  
count if psu == "S11A" & adjM_MC_D2 == 3
count if psu == "S12A" & adjM_MC_D2 == 3
count if psu == "S12B" & adjM_MC_D2 == 3
count if psu == "S23A" & adjM_MC_D2 == 3
count if psu == "S23B" & adjM_MC_D2 == 3
count if psu == "S24A" & adjM_MC_D2 == 3
count if psu == "S24B" & adjM_MC_D2 == 3
count if psu == "S35A" & adjM_MC_D2 == 3
count if psu == "S35B" & adjM_MC_D2 == 3
count if psu == "S35C" & adjM_MC_D2 == 3
count if psu == "S35D" & adjM_MC_D2 == 3
count if psu == "S35E" & adjM_MC_D2 == 3
count if psu == "S37A" & adjM_MC_D2 == 3
count if psu == "S37B" & adjM_MC_D2 == 3
count if psu == "S48A" & adjM_MC_D2 == 3
count if psu == "S48B" & adjM_MC_D2 == 3
count if psu == "S49A" & adjM_MC_D2 == 3
count if psu == "S49B" & adjM_MC_D2 == 3
count if psu == "S49C" & adjM_MC_D2 == 3
count if psu == "S49E"  & adjM_MC_D2 == 3
count if psu == "S49F" & adjM_MC_D2 == 3
count if psu == "S49G" & adjM_MC_D2 == 3

br CBSATitle MC_D2 adjM_MC_D2 fincbtxm adjM_lbmc15_D2 adjM_ubmc15_D2 if MC_D2 != adjM_MC_D2
count if MC_D2 != adjM_MC_D2
/// 992 households (% of the households were changed their class category)
tab CBSATitle if MC_D2 != adjM_MC_D2

******* Fliped Category Household (Rosa's Dissertation - Essay 1 portion)*********
 *** A. Orignially Middle Class, but now lower class: 554 households
br if MC_D2 == 2 & adjM_MC_D2 == 1
tab CBSATitle if MC_D2 == 2 & adjM_MC_D2 == 1
count if MC_D2 == 2 & adjM_MC_D2 == 1 

 *** B. Orignially Middle Class, but now upper class: 28 (Mostly in Chicago, Detroit, St.Louis)
br if MC_D2 == 2 & adjM_MC_D2 == 3
count if MC_D2 == 2 & adjM_MC_D2 == 3

 *** C. Originally Upper Class, but now middle class: 391 households 
 br if MC_D2 == 3 & adjM_MC_D2 == 2
count if MC_D2 == 3 & adjM_MC_D2 == 2

 *** D. Orignially lower class, but now middle class: 19 (Chicago, Detroit, St. Louis)
 br if MC_D2 == 1 & adjM_MC_D2 == 2
 count if MC_D2 == 1 & adjM_MC_D2 == 2
 
 **********************************************************************************************
 ********************************* BLS Code ************************************
  
global cq_var  = "totexpcq"  
/*Current quarter half of variable of interest*/
global pq_var  = "totexppq"  
/*Previous quarter half of variable of interest*/
global inc_var = "fincbtxm"  
/*Income variable of interest."*/ 

#d ; 
gen cal_totexp = $cq_var*finlwt21 if quarter==1 ;
	replace cal_totexp = $pq_var*finlwt21 if quarter==5 ;
	replace cal_totexp = (($cq_var + $pq_var)*finlwt21) if quarter==3 ;

format cal_totexp %16.0f 

  ** d. Creating CPI-based Market Basket (May 5, 2018) (re-run on Feb 11, 2019)

   ** 1. Food and Beverages + Other Goods And Services (reading , personal care, tobacco Miscellaneous)
gen pq_foodalc = foodpq + alcbevpq 
gen cq_foodalc = foodcq + alcbevcq
 
gen pq_misc = perscapq + readpq + tobaccpq + miscpq
gen cq_misc = perscacq + readcq + tobacccq + misccq

foreach i in foodalc misc {
gen cal_`i' = cq_`i'*finlwt21 if quarter == 1
    replace cal_`i' = pq_`i'*finlwt21 if quarter == 5
	replace cal_`i' = ((cq_`i' + pq_`i')*finlwt21) if quarter == 3
	}

br cal_*

   ** 2. Housing (houspq + houscq); Apparel (apparpq + apparcq);Transportation (transpq + transcq);
   **  Medical Care (healthpq + healthcq); Recreation (entertpq + entertcq); Education and Communication (educapq + educacq)
   ** Personal Insurance, Pension, Saving (perinspq + perinscq); Cash contribution (cashcopq + cashcocq) 
   
foreach i in hous appar trans health entert educa perins cashco {
gen cal_`i' = `i'cq*finlwt21 if quarter == 1
    replace cal_`i' = `i'pq*finlwt21 if quarter == 5
	replace cal_`i' = ((`i'cq + `i'pq)*finlwt21) if quarter == 3
	}

format cal_* %16.1gc 
    
 
 ///////////////////////////////////////////////////////////////////////////////
   ** Additional: Vacation and Trip (ttotalp + ttotalc) ----> Not a separte category
foreach i in ttotal {
gen cal_`i' = `i'c*finlwt21 if quarter == 1
    replace cal_`i' = `i'p*finlwt21 if quarter == 5
	replace cal_`i' = ((`i'c + `i'p)*finlwt21) if quarter == 3 
	}
	
format cal_ttotal %16.1gc
 
 /*Next the weights need to be adjusted for the calendar year estimates to 
  reflect the number of months of the reference period that the CU could report
  expenditures that occured in the calendar year.
  
  This changed the month variable from character to numeric.*/
tab qintrvmo
br qintrvyr qintrvmo

#d ;
gen month = real(qintrvmo) ;

/*This is called the "months in scope" adjustment. We are scaling the weight 
  applied to the expenditure by a factor depending on how many months in the 
  year of interest are in the scope of our calendar year. We divide everything 
  by four to account for the fact that the weight is designed to sum to the 
  national population in each quarter dataset. Since we are constructing a year
  of data, we need to scale the weight by the number of quarters in a year, or
  by four.*/
 
br qintrvyr quarter qintrvmo month 
br qintrvyr quarter qintrvmo month if quarter == 1
br qintrvyr quarter qintrvmo month if quarter == 5
 
 #d ;
gen cal_popweight = finlwt21*(((month-1)/3)/4) if quarter == 1 ;
	replace cal_popweight = finlwt21*(((4-month)/3)/4) if quarter == 5 ;
	replace cal_popweight = finlwt21/4 if quarter == 3 ;

/*Now we need to generate aggregate expenditure and population weight 
  variables by summing up all the observations for the variables of interest. 
  The count variable is added just to store the total number of CUs were in the
  original sample. Some researchers like to keep this information on hand.*/

br cal_totexp


#d ;
gen count = 1 ;
 

 
 save "$outPath\Interview2015_FamSizeAdj", replace
 
 *********************************** Updated Feb, 2019  ***********************************
 **** 1. < Possible Misclassification for the Lower-Class population > Do not use weighted variable **********
 gen cashco = cashcopq + cashcocq
 
br fincbtxm cashco if MC_D2 == 1
 **** Selection criteria: Lower Class, but whose cash contriution is above 95 percentile within the category in 2015 ****
  *** A. Middle Class Definition, Without family size & Cost-of-living adjustment
sum fincbtxm cashco if MC_D2 == 1, de
 /// obs = 4805, 95 percentile cash contribution = $980
    count if MC_D2 == 1 & cashco > 980
	tab incnonw1 if MC_D2 == 1 & cashco > 980
	sum age_ref cashco fincbtxm if MC_D2 == 1 & cashco > 980
	/// obs = 240 (about 4.9% of the CUs who were classified as lower class)
	/// Among those 240, 152 CUs are not working. Among those 152 CUs, 133 CUs (87.5) are retired. 
	/// Mean age of these 240 CUs was 64 
	    /// Among 4805 lower class CUs, 2.77% could be misclassified. 
 
  *** B.  Middle Class Definition, With family size adjustment, Without Cost-of-living adjustment
sum fincbtxm cashco if MC_D2_famsiz == 1, de
 /// obs = 6699, mean cash contribution = $243, 90% percentile = $549, 95% percentile = $1050
    count if MC_D2_famsiz == 1 & cashco > 1050
	tab incnonw1 if MC_D2_famsiz == 1 & cashco > 1050
	sum age_ref cashco fincbtxm if MC_D2_famsiz == 1 & cashco > 1050
	/// obs = 323 (about 4.6% of the CUs who were classified as lower class)
	/// Among those 323, 165 CUs are not working. Among those 165 CUs, 135 CUs (82%) are retired. 
	/// Mean age of these 323 CUs was 59
	    /// Among 6699 lower class CUs, 2.02% could be misclassified
	
  *** C. Middle Class Definition, Without family size adjustment, With Cost-of-living adjustment. 
sum fincbtxm cashco if adjM_MC_D2 == 1, de
 /// obs = 5340, 95 percentile cash contribution = $ 1000
    count if adjM_MC_D2 == 1 & cashco > 1000
	tab incnonw1 if adjM_MC_D2 == 1 & cashco > 1000
	sum age_ref cashco fincbtxm if adjM_MC_D2 == 1 & cashco > 1000
	/// obs = 256 (about 4.8% of the CUs who were classified as lower class)
	/// Among those 256, 154 CUs are not working. Among those 154 CUs, 134 CUs (87%) are retired. 
	/// Mean age of these 256 CUs was 62
	    /// Among 5340 lower class CUs, about 2.51% could be misclassified. 

  *** D. Middle Class Definition, With family size adjustment, With Cost-of-living adjustment.
sum fincbtxm cashco if adjM_MC_D2_famsiz == 1, de
 /// obs = 7443, 95 percentile cash contriution = $1196
    count if adjM_MC_D2_famsiz == 1 & cashco > 1196
	tab incnonw1 if adjM_MC_D2_famsiz == 1 & cashco > 1196
	sum age_ref cashco fincbtxm if adjM_MC_D2_famsiz == 1 & cashco > 1196
	/// obs = 372 (about 4.99% of the CUs who were classified as lower class)
	/// Among those 372, 179 CUs are not working. Among those 179 CUs, 142 (79%) are retired. 
	/// Mean age of these 372 was 57
	    /// Among 7443, 1.9% could be misclassified. 
 
   *** To sum (A,B,C,D cases), the range of missclassification 1.9% - 2.8%  

histogram age_ref if MC_D2 == 1 & cashco != 0.0, freq bin(10) fcolor(blue) lcolor(black) addlabel
histogram age_ref if MC_D2 == 1 & cashco != 0.0, start(15) width(5) freq fcolor(blue) lcolor(black) addlabel subtitle("Categorized lower class whose cash contribution is non-zero in 2015")

 **** 2. < Possible Misclassification for the Class population >  
    *** Population whose cash contribution is larger than their income
tab MC_D2 if cashco > fincbtxm & cashco > 0
    /// obs = 19
br age_ref cashco fincbtxm if cashco > fincbtxm & cashco > 0
sum age_ref cashco fincbtxm incnonw1 if cashco > fincbtxm & cashco > 0
    /// Mean age = 52, mean cash contribution for the last quarter $13,216

count if MC_D2 == 1 & cashco > fincbtxm & cashco > 0
    /// obs = 18
	
 *** 3. < Population categorized as upper class, but their number of earner are more than three >
br no_earnr MC_D2 fincbtxm if no_earnr > 3
tab MC_D2 if no_earnr > 3

gen percap_fincbtxm = fincbtxm/no_earnr
label var percap_fincbtxm "Annual income is divided by the number of earners in the CU"

  ** 3-A) Middle class but multiple earners (187 CUs)
count if MC_D2 == 2 & no_earnr > 3
br CBSATitle MC_D2 age_ref no_earnr fincbtxm percap_fincbtxm if MC_D2 == 2 & no_earnr > 3
sum percap_fincbtxm if MC_D2 == 2 & no_earnr > 3, de

  ** 3-B) Upper class but multiple earners (143 CUs)
count if MC_D2 == 3 & no_earnr > 3
br CBSATitle MC_D2 age_ref no_earnr fincbtxm percap_fincbtxm if MC_D2 == 3 & no_earnr > 3
sum percap_fincbtxm if MC_D2 == 3 & no_earnr > 3, de

 
  save "$outPath\Interview2015_FamSizeAdj", replace
  
 **********************************************************************************************
 **************** Final Calculation: Caution! Collapse  (See the Collapse Function carefully!!) 
 
 ***** 1) Version 1: Total expenditure (Original code from BLS) 
 use "$outPath\Interview2015_FamSizeAdj", clear
 
#d ;
collapse (sum) 
agg_cal_wt = cal_popweight 
agg_cal_totexp = cal_totexp
agg_cal_ttotal = cal_ttotal 
count, by (MC_D2)
;

/*Lastly, generate calendar year means using the aggregate population weight and
  the aggregate weighted expenditure then review the results.*/ 
  
#d ; 
gen mean_cal_ttotal = agg_cal_ttotal / agg_cal_wt 
gen mean_cal_totexp = agg_cal_totexp/ agg_cal_wt
;

gen Prop_ttotal = mean_cal_ttotal/mean_cal_totexp

/*If you attempted an expenditure summary variable, you'll notice this 
  value differs slightly from the value on the tables, this occurs because the 
  tables are calculated with internal data which has not been topcoded or 
  suppressed for confidentiality concerns. 
 
  Save the resulting dataset.*/ 
save "$outPath\Interview2015_CollapsebyClass_VacationTime" 

*****  2) Version 2: Total expenditure by MC_D2 Class
 use "$outPath\Interview2015_FamSizeAdj", clear
 
 #d ;
collapse (sum) 
agg_cal_totexp = cal_totexp 
agg_cal_foodalc = cal_foodalc 
agg_cal_misc = cal_misc 
agg_cal_hous = cal_hous
agg_cal_appar = cal_appar
agg_cal_trans = cal_trans
agg_cal_health = cal_health
agg_cal_entert = cal_entert
agg_cal_educa = cal_educa
agg_cal_perins = cal_perins
agg_cal_cashco = cal_cashco 
agg_cal_wt = cal_popweight
count, by (MC_D2)
;
 save "$outPath\Interview2015_CollapsebyClass"
 
 foreach i in totexp foodalc misc hous appar trans health entert educa perins cashco {
 gen mean_cal_`i' = agg_cal_`i'/agg_cal_wt
 }
 
 foreach i in foodalc misc hous appar trans health entert educa perins cashco {
 gen Prop_`i' = mean_cal_`i'/ mean_cal_totexp
 }
 
 save "$outPath\Interview2015_CollapsebyClass", replace

  br MC_D2 count mean_* 
 br MC_D2 count Prop_* 
 
 graph bar Prop_foodalc Prop_hous Prop_appar, over(MC_D2)
 graph bar Prop_trans Prop_health Prop_entert, over(MC_D2)
 graph bar Prop_educa Prop_perins Prop_cashco, over(MC_D2)
 
 graph bar Prop_foodalc Prop_hous Prop_trans, over(MC_D2) 
 graph bar Prop_health Prop_perins Prop_cashco, over(MC_D2)
     //// Write some descriptive analysis on who spend more than their income
	 
  *****  3) Version 3: Total expenditure by metro area
   use "$outPath\Interview2015_FamSizeAdj", clear
   
   #d ;
collapse (sum) 
agg_cal_totexp = cal_totexp 
agg_cal_foodalc = cal_foodalc 
agg_cal_misc = cal_misc 
agg_cal_hous = cal_hous
agg_cal_appar = cal_appar
agg_cal_trans = cal_trans
agg_cal_health = cal_health
agg_cal_entert = cal_entert
agg_cal_educa = cal_educa
agg_cal_perins = cal_perins
agg_cal_cashco = cal_cashco 
agg_cal_wt = cal_popweight
count, by (CBSATitle)
;

 save "$outPath\Interview2015_CollapsebyMetro"
  
 foreach i in totexp foodalc misc hous appar trans health entert educa perins cashco {
 gen mean_cal_`i' = agg_cal_`i'/agg_cal_wt
 }
 
 foreach i in foodalc misc hous appar trans health entert educa perins cashco {
 gen Prop_`i' = mean_cal_`i'/ mean_cal_totexp
 }
 
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "New York")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Chicago")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Washington")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Detroit")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Baltimore")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "San Francisco")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Seattle")> 0
 graph bar Prop_foodalc Prop_hous Prop_appar Prop_trans Prop_entert if strpos(CBSATitle, "Philadelphia")> 0
 
 
 save "$outPath\Interview2015_CollapsebyMetro", replace 
 
   **** 4) Version 4: Collapse by COLI-Adjusted Class
 use "$outPath\Interview2015_FamSizeAdj", clear
  #d ;
collapse (sum) 
agg_cal_totexp = cal_totexp 
agg_cal_foodalc = cal_foodalc 
agg_cal_misc = cal_misc 
agg_cal_hous = cal_hous
agg_cal_appar = cal_appar
agg_cal_trans = cal_trans
agg_cal_health = cal_health
agg_cal_entert = cal_entert
agg_cal_educa = cal_educa
agg_cal_perins = cal_perins
agg_cal_cashco = cal_cashco 
agg_cal_wt = cal_popweight
count, by (adjM_MC_D2)
;

foreach i in totexp foodalc misc hous appar trans health entert educa perins cashco {
 gen mean_cal_`i' = agg_cal_`i'/agg_cal_wt
 }
 
 foreach i in foodalc misc hous appar trans health entert educa perins cashco {
 gen Prop_`i' = mean_cal_`i'/ mean_cal_totexp
 }
 
 br adjM_MC_D2 Prop*
 
save "$outPath\Interview2015_Collapse_AdjustedClass"

  **** 5) Version 5: Collapse by Metro & Adjusted Class
   use "$outPath\Interview2015_FamSizeAdj", clear
   #d ;
collapse (sum) 
agg_cal_totexp = cal_totexp 
agg_cal_foodalc = cal_foodalc 
agg_cal_misc = cal_misc 
agg_cal_hous = cal_hous
agg_cal_appar = cal_appar
agg_cal_trans = cal_trans
agg_cal_health = cal_health
agg_cal_entert = cal_entert
agg_cal_educa = cal_educa
agg_cal_perins = cal_perins
agg_cal_cashco = cal_cashco 
agg_cal_wt = cal_popweight
count, by (adjM_MC_D2 CBSATitle)
;
 
 save "$outPath\Interview2015_CollapsebyMetro_COLIadj_MC_D2"
 
 foreach i in totexp foodalc misc hous appar trans health entert educa perins cashco {
 gen mean_cal_`i' = agg_cal_`i'/agg_cal_wt
 }
 
 foreach i in foodalc misc hous appar trans health entert educa perins cashco {
 gen Prop_`i' = mean_cal_`i'/ mean_cal_totexp
 }
  save "$outPath\Interview2015_CollapsebyMetro_COLIadj_MC_D2", replace
  
br CBSATitle adjM_MC_D2 Prop* if adjM_MC_D2 == 1
br CBSATitle adjM_MC_D2 Prop* if adjM_MC_D2 == 2
br CBSATitle adjM_MC_D2 Prop* if adjM_MC_D2 == 3
sum Prop_hous if adjM_MC_D2 == 1, de
sum Prop_hous if adjM_MC_D2 == 2, de
sum Prop_hous if adjM_MC_D2 == 3, de

sum Prop_perins if adjM_MC_D2 == 1, de
sum Prop_perins if adjM_MC_D2 == 2, de
sum Prop_perins if adjM_MC_D2 == 3, de

sum Prop_trans if adjM_MC_D2 == 1, de
sum Prop_trans if adjM_MC_D2 == 2, de
sum Prop_trans if adjM_MC_D2 == 3, de
  