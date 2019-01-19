
/*====================================================================
project: Exposure to urban violence and prosocial behavior      
Author: Gómez, Camilo        
Dependencies:  Universidad Nacional de Colombia
----------------------------------------------------------------------
Creation Date: 07/dic/2018   
Modification Date: 19/01/2019  
Do-file version: 02
References:          
Output:          Tables & Graphs
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

clear all

* Main root: Main path, use locals
* Change the main root if this .do is open in other PC
loc root = "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis"

*Data folder
loc data = "`root'/Data"

*Output folders
*Graphs
loc graph_out = "`root'/Graphs"

*Tables
loc tables_out = "`root'/Tables"


/*====================================================================
                        1: Load data & merge
====================================================================*/
*the data base of the experiment is thesis master.dta
*this data base is anonymized and has n = 223

use "`data'/thesis master.dta", clear

*the data base to merge is controles_localidad.dta. This data base has
*variables of the homicide rate and variables from encuesta multiproposito.

merge m:1 localidad using "`data'/controles_localidad.dta"
drop _merge


/*====================================================================
                        2: rename & create variables
====================================================================*/
*generate treatment variables 
*(Negative Wealth Shock) nws = 1 if treatment is CI 
gen nws = 1 if thesis1playertreatment == "RV-CI"
replace nws = 0 if thesis1playertreatment == "RV-NCI"
replace nws = 0 if thesis1playertreatment == "NVR-NCI"
replace nws = 1 if thesis1playertreatment == "NRV-CI"

* primed = 1 if tratment is RV
gen primed = 1 if thesis1playertreatment == "RV-CI"
replace primed = 1 if thesis1playertreatment == "RV-NCI"
replace primed = 0 if thesis1playertreatment == "NVR-NCI"
replace primed = 0 if thesis1playertreatment == "NRV-CI"

* Variable condition with four levels. One for each condition
gen condition = 1 if (nws ==0 & primed == 0)
replace condition = 2 if (nws ==0 & primed == 1)
replace condition = 3 if (nws ==1 & primed == 0)
replace condition = 4 if (nws ==1 & primed == 1)

*Dummy variable for each condition
gen c1 = 0
replace c1 = 1 if condition == 1
gen c2 = 0
replace c2 = 1 if condition == 2
gen c3 = 0
replace c3 = 1 if condition == 3
gen c4 = 0
replace c4 = 1 if condition == 4

*rename age variable
rename thesis1playerage age

*generate female = 1 
gen female =0
replace female = 1 if thesis1playergender == "Femenino" 
label define female1 0 "Male" 1 "Female"
label values female female1

*generate civil_status variable
egen civil_status = group(thesis1playerestado)
label define civil_status1 1 "Married" 2 "Single" 3 "Free Union"
label values civil_status civil_status1

*rename socio-economic status variable (ses)
rename thesis1playerestrato ses

*rename belief future socio-economic status variable (ses_fut)
rename thesis1playerestrato_fut ses_fut

*rename quiz questions
rename thesis1playerq1 q1
rename thesis1playerq2 q2
rename thesis1playerq3 q3
rename thesis1playerq4 q4

*generate wrong quiz answers' variable
gen wrongq1 = 0
replace wrongq1 = 1 if q1 != 2
gen wrongq2 = 0
replace wrongq2 = 1 if q2 != 10
gen wrongq3 = 0
replace wrongq3 = 1 if q3 != 10
gen wrongq4 = 0
replace wrongq4 = 1 if q4 != 6
gen wrongq = wrongq1+wrongq2+wrongq3+wrongq4

*generate the mean cooperation variable per participant
gen meancoop = (thesis1playerp1 + thesis1playerp2 +thesis1playerp3 ///
+ thesis1playerp4 +thesis1playerp5+ thesis1playerp6+ thesis1playerp7 ///
+ thesis1playerp8+thesis1playerp9 +thesis1playerp10 +thesis1playerp11 ///
+thesis1playerp12+ thesis1playerp13+ thesis1playerp14+ thesis1playerp15 ///
+thesis1playerp16 +thesis1playerp17+ thesis1playerp18 +thesis1playerp19)/19

*rename belief elicitation variable
rename thesis1playerelicitation eli

*rename dontation variable
rename thesis1playerdic don
gen dic = don/4

*generate ong's variable
egen ong = group(thesis1playerong)
label define ong1 1 "Colombia Crece" 2 "Colombia con Memoria" 3 "Cruz Roja Bogotá" 4 "Econsueños" ///
5 "Médicos sin Frontera" 6 "No deseo donar" 7 "Un Techo para mi país"  
label values ong ong1

*gen feedback variable
gen feedback = 1 if session <9
replace feedback = 0 if session >8

*generate interaction variables
gen diff = nws * primed

/*====================================================================
                        3: Self-reported exposure to 
						urban violence index (vs)
====================================================================*/
**Questions s1 to s13 are related to exposure to urban violence
rename thesis1players1 s1
rename thesis1players2 s2
rename thesis1players3 s3
rename thesis1players4 s4
rename thesis1players5 s5
rename thesis1players6 s6
rename thesis1players7 s7
rename thesis1players8 s8
rename thesis1players9 s9
rename thesis1players10 s10
rename thesis1players11 s11
rename thesis1players12 s12
rename thesis1players13 s13

**Questions s14 to s21 are related to preception of violence
rename thesis1players14 s14
rename thesis1players15 s15
rename thesis1players16 s16
rename thesis1players17 s17
rename thesis1players18 s18
rename thesis1players19 s19
rename thesis1players20 s20
rename thesis1players21 s21

*Self-reported exposure to urban violence index
*Create the index by principal component analysis
pca s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13
screeplot
loadingplot, maxlength(18)
*To create the index we use only the first component
predict violence_sub1, score
summarize violence_sub1

*Standarized the index between 0 - 1
egen minviolence_sub1 = min(violence_sub1)
gen vs1 =  violence_sub1 + (minviolence_sub1*(-1))
egen vs2 = max(vs1)
gen vs = vs1 / vs2
sum vs

/*====================================================================
                        3.1: Intesive margin variable for vs
====================================================================*/
cap: drop HETSV_int
cap: drop medianvs

* Create dummy variable High Exposure to Subjective Violence (HETSV_int)
* Is intensive because the split is by the median
egen medianvs=median(vs) 
gen HETSV_int=(vs>=medianvs) 

*generate interactions with HETSV_int
gen int_vs_int_p = HETSV_int*primed
gen int_vs_int_n = HETSV_int*nws

*Split the sample in four groups with primed dimension
gen group_vs_int_p = 1 if primed == 0 & HETSV_int == 0
replace group_vs_int_p = 2 if primed == 0 & HETSV_int == 1
replace group_vs_int_p = 3 if primed == 1 & HETSV_int == 0
replace group_vs_int_p = 4 if primed == 1 & HETSV_int == 1

*Split the sample in four groups with nws dimension
gen group_vs_int_n = 1 if nws == 0 & HETSV_int == 0
replace group_vs_int_n = 2 if nws == 0 & HETSV_int == 1
replace group_vs_int_n = 3 if nws == 1 & HETSV_int == 0
replace group_vs_int_n = 4 if nws == 1 & HETSV_int == 1

tab HETSV_int

/*====================================================================
                        3.2: Extensive margin variable for vs
====================================================================*/
cap: drop HETSV_ext

* Create dummy variable High Exposure to Subjective Violence (HETSV_ext)
* Is extensive because the split is = 1 if vs > 0.

gen HETSV_ext=(vs>0) 

*generate interactions with HETSV_ext
gen int_vs_ext_p = HETSV_ext*primed
gen int_vs_ext_n = HETSV_ext*nws

*Split the sample in four groups with primed dimension
gen group_vs_ext_p = 1 if primed == 0 & HETSV_ext == 0
replace group_vs_ext_p = 2 if primed == 0 & HETSV_ext == 1
replace group_vs_ext_p = 3 if primed == 1 & HETSV_ext == 0
replace group_vs_ext_p = 4 if primed == 1 & HETSV_ext == 1

*Split the sample in four groups with nws dimension
gen group_vs_ext_n = 1 if nws == 0 & HETSV_ext == 0
replace group_vs_ext_n = 2 if nws == 0 & HETSV_ext == 1
replace group_vs_ext_n = 3 if nws == 1 & HETSV_ext == 0
replace group_vs_ext_n = 4 if nws == 1 & HETSV_ext == 1

tab HETSV_ext

/*====================================================================
                        4: Objective exposure to 
						urban violence index (vo)
====================================================================*/

*Objective exposure to urban violence index
*Generate the mean of the variables 2017 - 2018
*gen homicide_two = (tasa_homicidio_2017+tasa_homicidio_2018)/2 
*gen theft_two = (tasa_hurtos_2017 + tasa_hurtos_2018)/2

*Create the index by principal component analysis
*pca homicide_two theft_two
*screeplot
*loadingplot, maxlength(18)
*To create the index we use only the first component
*predict violence_sub2, score
*summarize violence_sub2

*Standarized the index between 0 - 1
*egen minviolence_sub2 = min(violence_sub2)
*gen os1 =  violence_sub2 + (minviolence_sub2*(-1))
*egen os2 = max(os1)
*gen os = os1 / os2
*sum os

/*====================================================================
                        4.A: Objective exposure to 
						urban violence index (vo)
						Only 2018
====================================================================*/
*uncomment for only 2018
*Objective exposure to urban violence index
*Create the index by principal component analysis
pca tasa_homicidio_2018 tasa_hurtos_2018
screeplot
loadingplot, maxlength(18)
*To create the index we use only the first component
predict violence_sub2, score
summarize violence_sub2

*Standarized the index between 0 - 1
egen minviolence_sub2 = min(violence_sub2)
gen os1 =  violence_sub2 + (minviolence_sub2*(-1))
egen os2 = max(os1)
gen os = os1 / os2
sum os

/*====================================================================
                        4.1: Intesive margin variable for os
====================================================================*/
cap: drop HETV_int
cap: drop medianvs

* Create dummy variable High Exposure to Subjective Violence (HETSV_int)
* Is intensive because the split is by the median
egen medianos=median(os) 
gen HETV_int=(os>=medianos) 

*generate interactions with HETSV_int
gen int_os_int_p = HETV_int*primed
gen int_os_int_n = HETV_int*nws

*Split the sample in four groups with primed dimension
gen group_os_int_p = 1 if primed == 0 & HETV_int == 0
replace group_os_int_p = 2 if primed == 0 & HETV_int == 1
replace group_os_int_p = 3 if primed == 1 & HETV_int == 0
replace group_os_int_p = 4 if primed == 1 & HETV_int == 1

*Split the sample in four groups with nws dimension
gen group_os_int_n = 1 if nws == 0 & HETV_int == 0
replace group_os_int_n = 2 if nws == 0 & HETV_int == 1
replace group_os_int_n = 3 if nws == 1 & HETV_int == 0
replace group_os_int_n = 4 if nws == 1 & HETV_int == 1

tab HETV_int

/*====================================================================
                        4.2: Extensive margin variable for os
====================================================================*/
cap: drop HETV_ext

* Create dummy variable High Exposure to Subjective Violence (HETSV_ext)
* Is extensive because the split is = 1 if vs > 0.

gen HETV_ext=(os>0) 

*generate interactions with HETSV_ext
gen int_os_ext_p = HETV_ext*primed
gen int_os_ext_n = HETV_ext*nws

*Split the sample in four groups with primed dimension
gen group_vo_ext_p = 1 if primed == 0 & HETV_ext == 0
replace group_vo_ext_p = 2 if primed == 0 & HETV_ext == 1
replace group_vo_ext_p = 3 if primed == 1 & HETV_ext == 0
replace group_vo_ext_p = 4 if primed == 1 & HETV_ext == 1

*Split the sample in four groups with nws dimension
gen group_os_ext_n = 1 if nws == 0 & HETV_ext == 0
replace group_os_ext_n = 2 if nws == 0 & HETV_ext == 1
replace group_os_ext_n = 3 if nws == 1 & HETV_ext == 0
replace group_os_ext_n = 4 if nws == 1 & HETV_ext == 1

tab HETV_ext


/*====================================================================
                        5: ANALYSIS
====================================================================*/
/*====================================================================
                        COOPERATION
====================================================================*/
/*====================================================================
					Subjective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin mean cooperation
reg meancoop primed nws HETSV_int int_vs_int_p int_vs_int_n, rob 
outreg2 using tabla5.doc, replace dec(2) ctitle(Cooperation) ///
title(Table 5. Dif-Dif estimation cooperation, treatments and exposure to violence - self-reported: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg meancoop primed nws HETSV_int int_vs_int_p int_vs_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla5.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg meancoop primed nws HETSV_int int_vs_int_p int_vs_int_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla5.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg meancoop primed nws HETSV_int int_vs_int_p int_vs_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla5.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg meancoop primed nws HETSV_ext int_vs_ext_p int_vs_ext_n, rob  
outreg2 using tabla6.doc, replace dec(2) ctitle(Cooperation) ///
title(Table 6. Dif-Dif estimation cooperation, treatments and exposure to violence - self-reported: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg meancoop primed nws HETSV_ext int_vs_ext_p int_vs_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla6.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg meancoop primed nws HETSV_ext int_vs_ext_p int_vs_ext_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla6.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg meancoop primed nws HETSV_ext int_vs_ext_p int_vs_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla6.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):


/*====================================================================
					Objective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin subjective index
reg meancoop primed nws HETV_int int_os_int_p int_os_int_n, rob  
outreg2 using tabla7.doc, replace dec(2) ctitle(Cooperation) ///
title(Table 7. Dif-Dif estimation cooperation, treatments and exposure to violence - objective: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg meancoop primed nws HETV_int int_os_int_p int_os_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla7.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg meancoop primed nws HETV_int int_os_int_p int_os_int_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob 
outreg2 using tabla7.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg meancoop primed nws HETV_int int_os_int_p int_os_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla7.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg meancoop primed nws HETV_ext int_os_ext_p int_os_ext_n, rob  
outreg2 using tabla8.doc, replace dec(2) ctitle(Cooperation) ///
title(Table 8. Dif-Dif estimation cooperation, treatments and exposure to violence - objective: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg meancoop primed nws HETV_ext int_os_ext_p int_os_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla8.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg meancoop primed nws HETV_ext int_os_ext_p int_os_ext_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla8.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg meancoop primed nws HETV_ext int_os_ext_p int_os_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla8.doc, append ctitle(Cooperation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):


/*====================================================================
                        ELICITATION
====================================================================*/
/*====================================================================
					Subjective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin mean cooperation
reg eli primed nws HETSV_int int_vs_int_p int_vs_int_n, rob 
outreg2 using tabla9.doc, replace dec(2) ctitle(Elicitation) ///
title(Table 9. Dif-Dif estimation elicitation, treatments and exposure to violence - self-reported: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg eli primed nws HETSV_int int_vs_int_p int_vs_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla9.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg eli primed nws HETSV_int int_vs_int_p int_vs_int_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla9.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg eli primed nws HETSV_int int_vs_int_p int_vs_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla9.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg eli primed nws HETSV_ext int_vs_ext_p int_vs_ext_n, rob  
outreg2 using tabla10.doc, replace dec(2) ctitle(Elicitation) ///
title(Table 10. Dif-Dif estimation elicitation, treatments and exposure to violence - self-reported: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg eli primed nws HETSV_ext int_vs_ext_p int_vs_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla10.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg eli primed nws HETSV_ext int_vs_ext_p int_vs_ext_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla10.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg eli primed nws HETSV_ext int_vs_ext_p int_vs_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla10.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):


/*====================================================================
					Objective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin subjective index
reg eli primed nws HETV_int int_os_int_p int_os_int_n, rob  
outreg2 using tabla11.doc, replace dec(2) ctitle(Elicitation) ///
title(Table 11. Dif-Dif estimation elicitation, treatments and exposure to violence - objective: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg eli primed nws HETV_int int_os_int_p int_os_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla11.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg eli primed nws HETV_int int_os_int_p int_os_int_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob 
outreg2 using tabla11.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg eli primed nws HETV_int int_os_int_p int_os_int_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla11.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg eli primed nws HETV_ext int_os_ext_p int_os_ext_n, rob  
outreg2 using tabla12.doc, replace dec(2) ctitle(Elicitation) ///
title(Table 12. Dif-Dif estimation elicitation, treatments and exposure to violence - objective: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg eli primed nws HETV_ext int_os_ext_p int_os_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla12.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg eli primed nws HETV_ext int_os_ext_p int_os_ext_n gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla12.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg eli primed nws HETV_ext int_os_ext_p int_os_ext_n age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla12.doc, append ctitle(Elicitation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):



/*====================================================================
                        ALTRUISM
====================================================================*/
/*====================================================================
					Subjective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin mean cooperation
reg dic primed nws HETSV_int int_vs_int_p int_vs_int_n feedback, rob 
outreg2 using tabla13.doc, replace dec(2) ctitle(Donation) ///
title(Table 13. Dif-Dif estimation donation, treatments and exposure to violence - self-reported: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg dic primed nws HETSV_int int_vs_int_p int_vs_int_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla13.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg dic primed nws HETSV_int int_vs_int_p int_vs_int_n feedback gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla13.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg dic primed nws HETSV_int int_vs_int_p int_vs_int_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla13.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg dic primed nws HETSV_ext int_vs_ext_p int_vs_ext_n feedback, rob  
outreg2 using tabla14.doc, replace dec(2) ctitle(Donation) ///
title(Table 14. Dif-Dif estimation donation, treatments and exposure to violence - self-reported: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg dic primed nws HETSV_ext int_vs_ext_p int_vs_ext_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla14.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg dic primed nws HETSV_ext int_vs_ext_p int_vs_ext_n feedback gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla14.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg dic primed nws HETSV_ext int_vs_ext_p int_vs_ext_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla14.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):


/*====================================================================
					Objective analysis
====================================================================*/
/*====================================================================
					Intesive margin 
====================================================================*/
**** regression intensive margin subjective index
reg dic primed nws HETV_int int_os_int_p int_os_int_n feedback, rob  
outreg2 using tabla15.doc, replace dec(2) ctitle(Donation) ///
title(Table 15. Dif-Dif estimation donation, treatments and exposure to violence - objective: intensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with individual controls
reg dic primed nws HETV_int int_os_int_p int_os_int_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla15.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with district controls
reg dic primed nws HETV_int int_os_int_p int_os_int_n feedback gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob 
outreg2 using tabla15.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression intensive margin subjective index with all controls
reg dic primed nws HETV_int int_os_int_p int_os_int_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla15.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):

/*====================================================================
					Extensive margin 
====================================================================*/
**** regression extensive margin subjective index
reg dic primed nws HETV_ext int_os_ext_p int_os_ext_n feedback, rob  
outreg2 using tabla16.doc, replace dec(2) ctitle(Donation) ///
title(Table 16. Dif-Dif estimation donation, treatments and exposure to violence - objective: extensive analysis.) ///
 alpha(0.01, 0.05, 0.1) symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with individual controls
reg dic primed nws HETV_ext int_os_ext_p int_os_ext_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24, rob  
outreg2 using tabla16.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with district controls
reg dic primed nws HETV_ext int_os_ext_p int_os_ext_n feedback gasto_semanal ///
educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla16.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):
**** regression extensive margin subjective index with all controls
reg dic primed nws HETV_ext int_os_ext_p int_os_ext_n feedback age ses idipron ///
female wrongq thesis1playerun thesis1playerpolitical thesis1players25 ///
thesis1players24 gasto_semanal educacion estrato_1_y_2 movilidad vivienda_propia, rob  
outreg2 using tabla16.doc, append ctitle(Donation) dec(2) alpha(0.01, 0.05, 0.1) ///
symbol(***,**,*) addstat(F test, e(F)):



/*====================================================================
                        : Graphs
====================================================================*/

****Graph 1: Treatment effect cooperation
cap: drop meanmeancoop_t
cap: drop sdmeancoop_t
cap: drop countmeancoop_t
cap: drop himeancoop_t
cap: drop lowmeancoop_t

egen meanmeancoop_t = mean(meancoop), by(condition)
egen sdmeancoop_t = sd(meancoop), by(condition)
egen countmeancoop_t = count(meancoop), by(condition)
generate himeancoop_t = meanmeancoop_t + invttail(countmeancoop_t-1,0.025)*(sdmeancoop_t / sqrt(countmeancoop_t))
generate lowmeancoop_t = meanmeancoop_t - invttail(countmeancoop_t-1,0.025)*(sdmeancoop_t / sqrt(countmeancoop_t))


graph twoway (bar meanmeancoop_t condition , lcolor(black)  fintens(inten0) graphregion(lstyle(none) color(white))) ///
		 (rcap himeancoop_t lowmeancoop_t condition, color(black)), /// 
		xlabel(1 "NO_NWS-NVR" 2 "NO_NWS-VR" 3 "NWS-NVR" 4 "NWS-VR", noticks labsize(large))   ///
		legend(off) xtitle("") ylabel(0 (0.1) 0.7, labsize(small))

****Graph 2: Treatment effect elicitation
cap: drop meanelicitation_t
cap: drop sdelicitation_t
cap: drop countelicitation_t
cap: drop hielicitation_t
cap: drop lowelicitation_t

egen meanelicitation_t = mean(eli), by(condition)
egen sdelicitation_t = sd(eli), by(condition)
egen countelicitation_t = count(eli), by(condition)
generate hielicitation_t = meanelicitation_t + invttail(countelicitation_t-1,0.025)*(sdelicitation_t / sqrt(countelicitation_t))
generate lowelicitation_t = meanelicitation_t - invttail(countelicitation_t-1,0.025)*(sdelicitation_t / sqrt(countelicitation_t))


graph twoway (bar meanelicitation_t condition , lcolor(black)  fintens(inten0) graphregion(lstyle(none) color(white))) ///
		 (rcap hielicitation_t lowelicitation_t condition, color(black)), /// 
		xlabel(1 "NO_NWS-NVR" 2 "NO_NWS-VR" 3 "NWS-NVR" 4 "NWS-VR", noticks labsize(large))   ///
		legend(off) xtitle("") ylabel(0 (0.1) 0.7, labsize(small))
		
****Graph 3: Treatment effect altruism
cap: drop meanaltruism_t
cap: drop sdaltruism_t
cap: drop countaltruism_t
cap: drop hialtruism_t
cap: drop lowaltruism_t

egen meanaltruism_t = mean(eli), by(condition)
egen sdaltruism_t = sd(eli), by(condition)
egen countaltruism_t = count(eli), by(condition)
generate hialtruism_t = meanaltruism_t + invttail(countaltruism_t-1,0.025)*(sdaltruism_t / sqrt(countaltruism_t))
generate lowaltruism_t = meanaltruism_t - invttail(countaltruism_t-1,0.025)*(sdaltruism_t / sqrt(countaltruism_t))


graph twoway (bar meanaltruism_t condition , lcolor(black)  fintens(inten0) graphregion(lstyle(none) color(white))) ///
		 (rcap hialtruism_t lowaltruism_t condition, color(black)), /// 
		xlabel(1 "NO_NWS-NVR" 2 "NO_NWS-VR" 3 "NWS-NVR" 4 "NWS-VR", noticks labsize(large))   ///
		legend(off) xtitle("") ylabel(0 (0.1) 0.7, labsize(small))
		
		
		
		
		
		
		

		
		
		
		
		
		
		
		
/*====================================================================
                        : Graphs
****Graph 1: 
cap: drop meanmeancoop_p
cap: drop sdmeancoop_p
cap: drop countmeancoop_p
cap: drop himeancoop_p
cap: drop lowmeancoop_p
egen meanmeancoop_p=mean(meancoop), by(group_vs_int_p)
egen sdmeancoop_p=sd(meancoop), by(group_vs_int_p)
egen countmeancoop_p=count(meancoop), by(group_vs_int_p)
generate himeancoop_p = meanmeancoop_p + invttail(countmeancoop_p-1,0.025)*(sdmeancoop_p / sqrt(countmeancoop_p))
generate lowmeancoop_p = meanmeancoop_p - invttail(countmeancoop_p-1,0.025)*(sdmeancoop_p / sqrt(countmeancoop_p))


graph twoway (bar meanmeancoop_p group_vs_int_p , lcolor(black)  fintens(inten0) graphregion(lstyle(none) color(white))) ///
		 (rcap himeancoop lowmeancoop group_vs_int_p, color(black)), /// 
		xlabel(1 "LV-NR" 2 "HV-NR" 3 "LV-VR" 4 "HV-VR", noticks labsize(large))   ///
		legend(off) xtitle("") ylabel(0 (0.1) 0.7, labsize(small)) text(0.63 1.5 "_______________") text(0.63 1.5 "*") ///
		text(0.7 2.5 "______________________________") text(0.7 2.5 "") text(0.63 3.5 "________________")   ///
		text(0.63 3.5 "")


reg outcome Primed HETSV in1 age female faestu bmi fathersedu tasadesplazadospor1000 pibpercapita estrato1 movilidad viviendapropia faestu if id <665, cluster(id)


*Split the sample in four groups with primed dimension
gen group_vs_int_p = 1 if primed == 0 & HETSV_int == 0
replace group_vs_int_p = 2 if primed == 0 & HETSV_int == 1
replace group_vs_int_p = 3 if primed == 1 & HETSV_int == 0
replace group_vs_int_p = 4 if primed == 1 & HETSV_int == 1

*Split the sample in four groups with nws dimension
gen group_vs_int_n = 1 if nws == 0 & HETSV_int == 0
replace group_vs_int_n = 2 if nws == 0 & HETSV_int == 1
replace group_vs_int_n = 3 if nws == 1 & HETSV_int == 0
replace group_vs_int_n = 4 if nws == 1 & HETSV_int == 1

***generate the instrument
gen instrument = 0
replace instrument = 1 if (vr==1 & primed==1)



reg meancoop cnr int1 primed, r
ivregress 2sls meancoop cnr int1 (primed=instrument), vce(r)
====================================================================*/
