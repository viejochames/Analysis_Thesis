
/*====================================================================
project: Exposure to urban violence and prosocial behavior      
Author: Gómez, Camilo        
Dependencies:  Universidad Nacional de Colombia
----------------------------------------------------------------------
Creation Date: 07/dic/2018   
Modification Date: 16/01/2019  
Do-file version: 02
References:          
Output:          Tables
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

education, income, heterogeneity (SES=1,2), Mobilidad, Vivienda propia


clear all
cd "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis"
use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\thesis master.dta", clear


**generate treatment variables 
gen cnr = 1 if thesis1playertreatment == "RV-CI"
replace cnr = 0 if thesis1playertreatment == "RV-NCI"
replace cnr = 0 if thesis1playertreatment == "NVR-NCI"
replace cnr = 1 if thesis1playertreatment == "NRV-CI"

gen primed = 1 if thesis1playertreatment == "RV-CI"
replace primed = 1 if thesis1playertreatment == "RV-NCI"
replace primed = 0 if thesis1playertreatment == "NVR-NCI"
replace primed = 0 if thesis1playertreatment == "NRV-CI"

gen condition = 1 if (cnr ==0 & primed == 0)
replace condition = 2 if (cnr ==0 & primed == 1)
replace condition = 3 if (cnr ==1 & primed == 0)
replace condition = 4 if (cnr ==1 & primed == 1)

gen c1 = 0
replace c1 = 1 if condition == 1
gen c2 = 0
replace c2 = 1 if condition == 2
gen c3 = 0
replace c3 = 1 if condition == 3
gen c4 = 0
replace c4 = 1 if condition == 4

**rename
rename thesis1playerage age
gen female =0
replace female = 1 if thesis1playergender == "Femenino" 
label define female1 0 "Male" 1 "Female"
label values female female1

egen civil_status = group(thesis1playerestado)
label define civil_status1 1 "Married" 2 "Single" 3 "Free Union"
label values civil_status civil_status1

rename thesis1playerestrato ses
rename thesis1playerestrato_fut ses_fut

rename thesis1playerq1 q1
rename thesis1playerq2 q2
rename thesis1playerq3 q3
rename thesis1playerq4 q4

gen wrongq1 = 0
replace wrongq1 = 1 if q1 != 2
gen wrongq2 = 0
replace wrongq2 = 1 if q2 != 10
gen wrongq3 = 0
replace wrongq3 = 1 if q3 != 10
gen wrongq4 = 0
replace wrongq4 = 1 if q4 != 6
gen wrongq = wrongq1+wrongq2+wrongq3+wrongq4

rename thesis1playerelicitation eli
rename thesis1playerdic don

egen ong = group(thesis1playerong)
label define ong1 1 "Colombia Crece" 2 "Colombia con Memoria" 3 "Cruz Roja Bogotá" 4 "Econsueños" ///
5 "Médicos sin Frontera" 6 "No deseo donar" 7 "Un Techo para mi país"  
label values ong ong1

****generate the mean cooperation variable per participant
gen meancoop = (thesis1playerp1 + thesis1playerp2 +thesis1playerp3 ///
+ thesis1playerp4 +thesis1playerp5+ thesis1playerp6+ thesis1playerp7 ///
+ thesis1playerp8+thesis1playerp9 +thesis1playerp10 +thesis1playerp11 ///
+thesis1playerp12+ thesis1playerp13+ thesis1playerp14+ thesis1playerp15 ///
+thesis1playerp16 +thesis1playerp17+ thesis1playerp18 +thesis1playerp19)/19

***generate interaction variables
gen int1 = cnr * primed


********índice compuesto de exposición a violencia
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

rename thesis1players14 s14
rename thesis1players15 s15
rename thesis1players16 s16
rename thesis1players17 s17
rename thesis1players18 s18
rename thesis1players19 s19
rename thesis1players20 s20
rename thesis1players21 s21

pca s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13
screeplot
loadingplot, maxlength(18)
predict violence_sub1, score
summarize violence_sub1


egen minviolence_sub1 = min(violence_sub1)
gen vs1 =  violence_sub1 + (minviolence_sub1*(-1))
egen vs2 = max(vs1)
gen vs = vs1 / vs2
sum vs


***Crear variable de High Exposure to Violence***
cap: drop HETV

egen medianviolence1=median(vs) 
gen HETV=(vs>=medianviolence1) 

gen interact = HETV*primed
gen interact2 = HETV*cnr

gen group = 1 if primed == 0 & HETV == 0
replace group = 2 if primed == 0 & HETV == 1
replace group = 3 if primed == 1 & HETV == 0
replace group = 4 if primed == 1 & HETV == 1

****Gráfica
cap: drop meanmeancoop
cap: drop sdmeancoop
cap: drop countmeancoop
cap: drop himeancoop
cap: drop lowmeancoop
egen meanmeancoop=mean(meancoop), by(group)
egen sdmeancoop=sd(meancoop) , by(group)
egen countmeancoop=count(meancoop), by(group)
generate himeancoop = meanmeancoop + invttail(countmeancoop-1,0.025)*(sdmeancoop / sqrt(countmeancoop))
generate lowmeancoop = meanmeancoop - invttail(countmeancoop-1,0.025)*(sdmeancoop / sqrt(countmeancoop))


graph twoway (bar meanmeancoop group , lcolor(black)  fintens(inten0) graphregion(lstyle(none) color(white))) ///
		 (rcap himeancoop lowmeancoop group, color(black)), /// 
		xlabel(1 "LV-NR" 2 "HV-NR" 3 "LV-VR" 4 "HV-VR", noticks labsize(large))   ///
		legend(off) xtitle("") ylabel(0 (0.1) 0.7, labsize(small)) text(0.8 1.5 "________________") ///
		text(0.45 2.5 "________________________________") text(0.35 3.5 "________________") text(0.76 1.5 "***") text(0.7 2.5 "***") ///
		text(0.36 3.5 "*")


reg outcome Primed HETSV in1 age female faestu bmi fathersedu tasadesplazadospor1000 pibpercapita estrato1 movilidad viviendapropia faestu if id <665, cluster(id)




***generate the instrument
gen instrument = 0
replace instrument = 1 if (vr==1 & primed==1)



reg meancoop cnr int1 primed, r
ivregress 2sls meancoop cnr int1 (primed=instrument), vce(r)
