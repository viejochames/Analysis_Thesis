
/*====================================================================
project: Exposure to urban violence and prosocial behavior      
Author: Gómez, Camilo        
Dependencies:  Universidad Nacional de Colombia
----------------------------------------------------------------------
Creation Date: 16/ene/2018   
Modification Date: 16/01/2019  
Do-file version: 01
References:          
Output:          Data
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

clear all

*Cargar la Base E de la encuesta multipropósito E - Composición del Hogar y Demografía

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Composicion del hogar y demografia ( Capitulo E).dta", clear

*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de movilidad en localidades * P: ¿Vivía en otra localidad hace 5 años?
tab LOCALIDAD_TEX NPCEP16AA, r

tab LOCALIDAD_TEX NPCEP17, r

/*====================================================================
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

clear all

*Cargar la Base B de la encuesta multipropósito - Composición del Hogar y Demografía

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Datos de la vivenda y su entorno  ( Capitulo B).dta", clear
*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de estratos en localidades * P: ¿Estrato para tarifa de energía?
tab LOCALIDAD_TEX NVCBP11AA, r

tab LOCALIDAD_TEX NVCBP15C, r

/*====================================================================
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

clear all

*Cargar la Base M1 de la encuesta multipropósito - Gastos en alimentos y bebidas no alcoholicas de los hogares (capítulo M1)

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Gastos en alimentos y bebidas no alcoholicas de los hogares ( Capitulo M1).dta", clear

*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de estratos en localidades * P: Gasto del mercado 
*tab NHCMP2B
mean NHCMP2B, over(CODLOCALIDAD)


replace NHCMP2A = 0 if NHCMP2A == .
replace NHCMP5AA = 0 if NHCMP5AA == .
replace NHCMP5BA = 0 if NHCMP5BA == .
replace NHCMP5CA = 0 if NHCMP5CA == .
replace NHCMP5DA = 0 if NHCMP5DA == .
replace NHCMP5EA = 0 if NHCMP5EA == .
replace NHCMP5FA = 0 if NHCMP5FA == .
replace NHCMP5GA = 0 if NHCMP5GA == .

*NHCMP2A - GASTOS DEL HOGAR EN BEBIDAS Y ALIMENTOS
*NHCMP5AA - GASTOS EN BEBIDAS ALCOHOLICAS Y TABACO
*NHCMP5BA - TRANSPORTE
*NHCMP5CA - CORREO, FAX ENCOMIENDAS
*NHCMP5DA - COMBUSTIBLE Y PARQEUADERO
*NHCMP5EA - COMIDAS FUERA DEL HOGAR
*NHCMP5FA - APUESTAS Y LOTERIAS
*NHCMP5GA - CAFE INTERNET

gen gastos = NHCMP2A + NHCMP5AA + NHCMP5BA + NHCMP5CA + NHCMP5DA + NHCMP5EA + NHCMP5FA +NHCMP5GA 

mean gastos, over(CODLOCALIDAD)

/*====================================================================
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/
clear all

*Cargar la Base J de la encuesta multipropósito - Participacion en organizaciones y redes sociales (capítulo J)

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Participacion en organizaciones y redes sociales  (capitulo J).dta", clear

*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de estratos en localidades * P: Gasto del mercado 
replace NPCJP1I = 0 if NPCJP1I == .

tab LOCALIDAD_TEX NPCJP1I, r 
mean NHCMP2B, over(CODLOCALIDAD)

/*====================================================================
====================================================================*/

/*====================================================================
                        Educación
====================================================================*/
clear all

*Cargar la Base H de la encuesta multipropósito - Educación (capítulo H)

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Educacion (capitulo H).dta", clear

*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de estratos en localidades * P: Gasto del mercado 
tab NPCHP4

/*====================================================================
====================================================================*/

/*====================================================================
						Condiciones habitacionales
====================================================================*/
clear all

*Cargar la Base C de la encuesta multipropósito - Condiciones habitacionales del hogar (capítulo C)

use "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Condiciones habitacionales del hogar   (Capitulo C).dta", clear

*Unir la Base con la información base de la encuesta.

merge m:1 DIRECTORIO using "C:\Users\LENOVO IDEAPAD 510\Documents\Universidad Nacional\Tesis maestría\Experiment\Análisis\Analysis_Thesis\Data\Multipropósito\Identificacion ( Capitulo A).dta"

*Tabla de frecuencias de estratos en localidades * P: Gasto del mercado 
tab LOCALIDAD_TEX NHCCP1, r








