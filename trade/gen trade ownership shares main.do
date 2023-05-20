
********* This do file is used to identify domestic and non-domestic trade shares based on customs data *****
********* The do file will generate province-level domestic and non-domestic trade shares over 42 IO sectors ***

cd "H:\New Data work\submission II"

local period 1 /* set the year period: 1.2002-2006;2.2007-2009;3.2009-2011;4.2012-2016;5.2017 */

******** trade is classified into 5 parts: 1 TOT from/to the whole world, 2 WLD from/to the rest of world, 3. HKG from/to Hongkong, 4. TWN from/to Taiwan; 5. Mac from/to Marco

foreach name in HKG TWN MAC WLD TOT{
if `period'==1{
import excel "trade data\provincefirmsh_0206.xlsx", sheet("STATEFIRMPKCSH") firstrow clear /*2002-2006*/
destring IO122,replace
drop if IO122==0
if "`name'"~="TOT"{
keep if ctr=="`name'"
}

}
if `period'==2{

import excel "trade data\provincefirmsh_0709.xlsx", sheet("STATEFIRMPKCSH") firstrow clear /*2007-2009*/
destring IO135,replace
drop if IO135==0
if "`name'"~="TOT"{
keep if ctr=="`name'"
}

}

if `period'==3{
import excel "trade data\provincefirmsh_0911.xlsx", sheet("STATEFIRMPKCSH") firstrow clear /*2009-2011*/
destring IO135,replace
drop if IO135==0
if "`name'"~="TOT"{
keep if ctr=="`name'"
}
}


if `period'==4{
import excel "trade data\provincefirmsh_1216.xlsx", sheet("STATEFIRMPKCSH") firstrow clear /*2012-2016*/
destring IO139,replace
drop if IO139==0

if "`name'"~="TOT"{
keep if ctr=="`name'"
}
}

if `period'==5{
import excel "trade data\provincefirmsh2017.xlsx", sheet("STATEFIRMPKCSH") firstrow clear /*2017 */

destring IO149,replace
drop if IO149==0
if "`name'"~="TOT"{
keep if ctr=="`name'"
}
}

******** identify the non-domestic shares  based on the ownership type of traders *****
***** JNE joint venture, OTE other, FIE foreign invested enterprises ********
gen type=cond(firm=="JNE"|firm=="OTE"|firm=="FIE",1,0)
label var type "non-domestic"
capture rename IMP imp
capture rename EXP exp
gen double M_INT=imp*INTMsh
gen double M_CONS=imp*CONSMsh
gen double M_CAP=imp*CAPMsh

label var M_INT "INT Import"
label var M_CONS "CONS Import"
label var M_CAP "CAP Import"

gen double X_INT=exp*INTEsh
gen double X_CONS=exp*CONSEsh
gen double X_CAP=exp*CAPEsh
label var X_INT "INT Export"
label var X_CONS "CONS Export"
label var X_CAP "CAP Export"

gcollapse(sum) imp exp M_INT-X_CAP,by(year province IO42 type)



sort year province IO42 type


order year- type exp X_* imp M_* 

reshape8 wide exp X_* imp M_*,i(year province IO42) j(type)
mvencode exp0- M_CAP1,mv(0) override

gen M_INT=M_INT1+M_INT0
label var M_INT "INT Import"
gen double s_M_INT0=M_INT0/M_INT
label var s_M_INT0 "Domestic share of INT Import"
gen double s_M_INT1=M_INT1/M_INT
label var s_M_INT1 "Non-domestic share of INT Import"

gen M_CONS=M_CONS0+M_CONS1
label var M_CONS "CONS Import"
gen double s_M_CONS0=M_CONS0/M_CONS
label var s_M_CONS0 "Domestic share of CONS Import"
gen double s_M_CONS1=M_CONS1/M_CONS
label var s_M_CONS1 "Non-domestic share of CONS Import"

gen M_CAP=M_CAP0+M_CAP1
label var M_CAP "CAP Import"
gen double s_M_CAP0=M_CAP0/M_CAP
label var s_M_CAP0 "Domestic share of CAP Import"
gen double s_M_CAP1=M_CAP1/M_CAP
label var s_M_CAP1 "Non-domestic share of CAP Import"

gen X_INT=X_INT0+X_INT1
label var X_INT "INT Export"
gen double s_X_INT0=X_INT0/X_INT
label var s_X_INT0 "Domestic share of INT Export"
gen double s_X_INT1=X_INT1/X_INT
label var s_X_INT1 "Non-domestic share of INT Export"

gen X_CONS=X_CONS0+X_CONS1
label var X_CONS "CONS Export"

gen double s_X_CONS0=X_CONS0/X_CONS
label var s_X_CONS0 "Domestic share of CONS Export"
gen double s_X_CONS1=X_CONS1/X_CONS
label var s_X_CONS1 "Non-domestic share of CONS Export"

gen X_CAP=X_CAP0+X_CAP1
label var X_CAP "CAP Export"
gen double s_X_CAP0=X_CAP0/X_CAP
label var s_X_CAP0 "Domestic share of CAP Export"
gen double s_X_CAP1=X_CAP1/X_CAP
label var s_X_CAP1 "Non-domestic share of CAP Export"

gen double s_imp0=imp0/(imp0+imp1)
label var s_imp0 "domestic share of imp"
gen double s_imp1=imp1/(imp0+imp1)
label var s_imp1 "non-domestic share of imp"

gen double s_exp0=exp0/(exp0+exp1)
label var s_exp0 "domestic share of exp"
gen double s_exp1=exp1/(exp0+exp1)
label var s_exp1 "non-domestic share of exp"



gen double imp=imp0+imp1
label var imp "total import"


gen double exp=exp0+exp1
label var exp "total export"

order year province IO42 M_*T0  M_*T1 M_INT s_M_*T0 s_M_*T1  X_*T0  X_*T1 X_INT s_X_*T0 s_X_*T1 M_*S0  M_*S1 M_CONS s_M_*S0 s_M_*S1 X_*S0  X_*S1 X_CONS s_X_*S0 s_X_*S1  M_*P0  M_*P1 M_CAP s_M_*P0 s_M_*P1 X_*P0  X_*P1 X_CAP s_X_*P0 s_X_*P1 imp0 imp1 imp s_imp0 s_imp1 exp0 exp1 exp s_exp0 s_exp1

destring IO42,replace
sort year province IO42
drop if IO42==43


******* 2002-2006*****
if `period'==1{
save "workfile\trade data 0206 for merge `name'",replace
use "trade data\template trade.dta",clear
merge 1:1 year province IO42 using  "workfile\trade data 0206 for merge `name'"
keep if year>=2002&year<=2006
sort year
drop _merge
if "`name'"=="WLD"{
export excel using "results\trade shares over firmtypes 0206.xlsx",sheet(ROW,modify) keepcellfmt firstrow(varlabels)
}
if "`name'"=="TOT"{
export excel using "results\trade shares over firmtypes 0206.xlsx",sheet(TOT,modify) keepcellfmt firstrow(varlabels)
}
else {
export excel using "results\trade shares over firmtypes 0206.xlsx",sheet(`name',modify) keepcellfmt firstrow(varlabels)
}
}

******* 2007-2009 *****

if `period'==2{


save "workfile\trade data 0709 for merge `name'",replace
use "trade data\template trade.dta",clear
merge 1:1 year province IO42 using  "workfile\trade data 0709 for merge `name'"
keep if year==2007
sort year
drop _merge
if "`name'"=="WLD"{
export excel using "results\trade shares over firmtypes 07.xlsx",sheet(ROW,modify) keepcellfmt firstrow(varlabels)
}
if "`name'"=="TOT"{
export excel using "results\trade shares over firmtypes 07.xlsx",sheet(TOT,modify) keepcellfmt firstrow(varlabels)
}
else {
export excel using "results\trade shares over firmtypes 07.xlsx",sheet(`name',modify) keepcellfmt firstrow(varlabels)
}


}


******* 2009 - 2011 ***
if `period'==3{
save "workfile\trade data 0911 for merge `name'",replace
use "trade data\template trade.dta",clear
merge 1:1 year province IO42 using  "workfile\trade data 0911 for merge `name'"
keep if year>=2009&year<=2011
sort year
drop _merge
if "`name'"=="WLD"{
export excel using "results\trade shares over firmtypes 0911.xlsx",sheet(ROW,modify) keepcellfmt firstrow(varlabels)
}
if "`name'"=="TOT"{
export excel using "results\trade shares over firmtypes 0911.xlsx",sheet(TOT,modify) keepcellfmt firstrow(varlabels)
}
else {
export excel using "results\trade shares over firmtypes 0911.xlsx",sheet(`name',modify) keepcellfmt firstrow(varlabels)
}

}

**** 2012-2016 ********

if `period'==4{
save "workfile\trade data 1216 for merge `name'",replace
use "trade data\template trade.dta",clear
merge 1:1 year province IO42 using  "workfile\trade data 1216 for merge `name'"
keep if year==2012

sort year
drop _merge
if "`name'"=="WLD"{
export excel using "results\trade shares over firmtypes 2012.xlsx",sheet(ROW,modify) keepcellfmt firstrow(varlabels)
}
if "`name'"=="TOT"{
export excel using "results\trade shares over firmtypes 2012.xlsx",sheet(TOT,modify) keepcellfmt firstrow(varlabels)
}
else {
export excel using "results\trade shares over firmtypes 2012.xlsx",sheet(`name',modify) keepcellfmt firstrow(varlabels)
}
}

if `period'==5{
save "workfile\trade data 2017 for merge `name'",replace
use "trade data\template trade.dta",clear
merge 1:1 year province IO42 using  "workfile\trade data 2017 for merge `name'"
keep if year==2017
sort year
drop _merge
if "`name'"=="WLD"{
export excel using "results\trade shares over firmtypes 2017.xlsx",sheet(ROW,modify) keepcellfmt firstrow(varlabels)
}
if "`name'"=="TOT"{
export excel using "results\trade shares over firmtypes 2017.xlsx",sheet(TOT,modify) keepcellfmt firstrow(varlabels)
}
else {
export excel using "results\trade shares over firmtypes 2017.xlsx",sheet(`name',modify) keepcellfmt firstrow(varlabels)
}



}



}

