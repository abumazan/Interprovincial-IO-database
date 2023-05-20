* Balancing Macro controls, sum of GRPs equals to national GDP


set col_headers /

          gdp

          va_pri,        va_sec,        va_ter
          va_agr,        va_ind,        va_con,        va_whr
          va_trp,        va_acc,        va_fin,        va_rst,        va_oth

          hsh_rural,     hsh_urban,    gov,   fixed_capital,    inventory, net_flow , net_provflow
          export_b,        import_b,        export_s,        import_d

          compensation,    net_tax,   depreciation,    surplus
          /;

set rg  regions/

          nation
          Beijing,         Tianjin,        Hebei,               Shanxi,          InnerMongolia
          Liaoning,        Jilin,          Heilongjiang,        Shanghai,        Jiangsu
          Zhejiang,        Anhui,          Fujian,              Jiangxi,         Shandong
          Henan,           Hubei,          Hunan,               Guangdong,       Guangxi
          Hainan,          Chongqing,      Sichuan,             Guizhou,         Yunnan
          Tibet,           Shaanxi,        Gansu,               Qinghai,         Ningxia
          Xinjiang/;
set rg_prov(rg) provinces/
          Beijing,         Tianjin,        Hebei,               Shanxi,          InnerMongolia
          Liaoning,        Jilin,          Heilongjiang,        Shanghai,        Jiangsu
          Zhejiang,        Anhui,          Fujian,              Jiangxi,         Shandong
          Henan,           Hubei,          Hunan,               Guangdong,       Guangxi
          Hainan,          Chongqing,      Sichuan,             Guizhou,         Yunnan
          Tibet,           Shaanxi,        Gansu,               Qinghai,         Ningxia
          Xinjiang/;

set income(col_headers)  /
          compensation,    net_tax,   depreciation,    surplus/;

set expenditure(col_headers)  /
          hsh_rural,     hsh_urban,    gov,   fixed_capital,    inventory, net_flow  , net_provflow
          export_b,        import_b,        export_s,        import_d /;

set expd(expenditure)/
          hsh_rural,     hsh_urban,    gov,   fixed_capital,    inventory, net_provflow
          export_s,        import_d /;

set expd_sub(expd)/
          hsh_rural,     hsh_urban,    gov,   fixed_capital,    inventory
          export_s,        import_d /;

set non_trade(expenditure) /
          hsh_rural,     hsh_urban,    gov,   fixed_capital,    inventory, net_flow /;

set trade(expenditure)  /
          net_flow , net_provflow
          export_b,        import_b,        export_s,        import_d /;

set production(col_headers) /
          va_pri,        va_sec,        va_ter
          va_agr,        va_ind,        va_con,        va_whr
          va_trp,        va_acc,        va_fin,        va_rst,        va_oth /;

set prodct_agg(production)/
          va_pri,        va_sec,        va_ter /;

set prodct_dtl(production)/
          va_agr,        va_ind,        va_con,        va_whr
          va_trp,        va_acc,        va_fin,        va_rst,        va_oth /;

set years  /
          yr1997, yr2002, yr2007,  yr2012,   yr2017/;

set years_sub(years) /
          yr1997, yr2002, yr2007,  yr2012,   yr2017/;

alias (income,incm);
alias (prodct_dtl,prodct_dtll);
alias (non_trade,Ntrade);
alias (rg_prov,rg_provv);
alias (expd,expdd);
alias (expd_sub,expd_subb);


* ========================= load initial data ============================
parameters

         iniData(rg,col_headers,years)    initial data_full tables

         grp(rg,years)     regional GDP
         grp_CAL(rg,years)  grp calibarated by national GDP
         ini_income(rg,income,years)    initial income
         ini_expenditure(rg,expenditure,years)    initial expenditure
         ini_production(rg,production,years)    initial production
         ;

execute_load 'initialMacrodata_97_17' iniData;

grp(rg,years) = iniData(rg,'gdp',years);
grp_CAL(rg_prov,years) = grp(rg_prov,years)/sum(rg_provv,grp(rg_provv,years))*grp('nation',years);

ini_income(rg,income,years) = iniData(rg,income,years);
ini_expenditure(rg,expenditure,years)  = iniData(rg,expenditure,years);
ini_production(rg,production,years)  = iniData(rg,production,years);

ini_expenditure(rg,'net_provflow',years) = ini_expenditure(rg,'net_flow',years) - (ini_expenditure(rg,'export_s',years)-ini_expenditure(rg,'import_d',years));
ini_expenditure(rg,'import_d',years) = - ini_expenditure(rg,'import_d',years);

* ============= balancing ==============================================================

* ------------- income-approach VA  ------------------
parameters colctrl_incm(income,years_sub)  column control of income-approach VA
           colsum_incm(income,years_sub)   column sum of income-approach VA
           reslt_incm(rg_prov,income,years_sub)   balanced income-approach VA
           ;

           colsum_incm(income,years_sub) = sum(rg_prov,ini_income(rg_prov,income,years_sub));
           colctrl_incm(income,years_sub) = colsum_incm(income,years_sub)/sum(incm,colsum_incm(incm,years_sub))*sum(rg_prov,grp_CAL(rg_prov,years_sub));

variables
          E1   cross entropy
          incm_var(rg_prov,income)   income-approach VA
         ;

parameters

          grpp(rg_prov)   gross regional(provincial) productions of the balancing year
          colctrl_incmm(income)  column control of income-approach VA of the balancing year
          ini_incm(rg_prov,income) initial value of income-approach VA of the balancing year
          ;

equations CAL_E1  calculation of cross entropy
          BAL_row1(rg_prov)  row balance
          BAL_col1(income)   column balance
          ;

CAL_E1..

     E1 =e= sum((rg_prov,income),sqr(incm_var(rg_prov,income)-ini_incm(rg_prov,income))/abs(ini_incm(rg_prov,income)));

BAL_row1(rg_prov)..
    sum(income,incm_var(rg_prov,income)) =e= grpp(rg_prov);

BAL_col1(income)..
    sum(rg_prov,incm_var(rg_prov,income)) =e= colctrl_incmm(income);


model md1 /
      CAL_E1
      BAL_row1
      BAL_col1
         /;

         OPTION ITERLIM = 50000;
         OPTION LIMROW = 150000, LIMCOL = 150000,   ResLim = 3000;
         OPTION SOLPRINT = ON;
         option NLP = CONOPT;

* .......... balance by year ..............
loop(years_sub,

         grpp(rg_prov)=grp_CAL(rg_prov,years_sub);
         colctrl_incmm(income) = colctrl_incm(income,years_sub);
         ini_incm(rg_prov,income)=ini_income(rg_prov,income,years_sub);

         solve md1 using nlp minimizing E1;
         reslt_incm(rg_prov,income,years_sub)=incm_var.l(rg_prov,income);

);


* ------------- production-approach VA ------------------
parameters colctrl_prod(prodct_dtl,years)   column control of production-approach VA
           colsum_prod(prodct_dtl,years)     column sum of production-approach VA
           reslt_prod(rg_prov,prodct_dtl,years)    balanced production-approach VA
           ;

           colsum_prod(prodct_dtl,years) = sum(rg_prov,ini_production(rg_prov,prodct_dtl,years));
           colctrl_prod(prodct_dtl,years) = colsum_prod(prodct_dtl,years)/sum(prodct_dtll,colsum_prod(prodct_dtll,years))*sum(rg_prov,grp_CAL(rg_prov,years));

variables E2    cross entropy
          prod_var(rg_prov,prodct_dtl)   production-approach VA
         ;

parameters

          grpp(rg_prov)   gross regional(provincial) productions of the balancing year
          colctrl_prodd(prodct_dtl)   column control of production-approach VA of the balancing year
          ini_prod(rg_prov,prodct_dtl)   initial value of production-approach VA of the balancing year
          ;

equations CAL_E2  calculation of cross entropy
          BAL_row2(rg_prov)    row balance
          BAL_col2(prodct_dtl) column balance
          ;

CAL_E2..
     E2 =e= sum((rg_prov,prodct_dtl),sqr(prod_var(rg_prov,prodct_dtl)-ini_prod(rg_prov,prodct_dtl))/abs(ini_prod(rg_prov,prodct_dtl)));

BAL_row2(rg_prov)..
    sum(prodct_dtl,prod_var(rg_prov,prodct_dtl)) =e= grpp(rg_prov);

BAL_col2(prodct_dtl)..
     sum(rg_prov,prod_var(rg_prov,prodct_dtl)) =e= colctrl_prodd(prodct_dtl);

model md2 /
      CAL_E2
      BAL_row2
      BAL_col2
        /;

         OPTION ITERLIM = 50000;
         OPTION LIMROW = 150000, LIMCOL = 150000,   ResLim = 3000;
         OPTION SOLPRINT = ON;
         option NLP = CONOPT;

* .......... balance by year ..............
loop(years,

         grpp(rg_prov)=grp_CAL(rg_prov,years);
         colctrl_prodd(prodct_dtl) = colctrl_prod(prodct_dtl,years);
         ini_prod(rg_prov,prodct_dtl) = ini_production(rg_prov,prodct_dtl,years);

         solve md2 using nlp minimizing E2;
         reslt_prod(rg_prov,prodct_dtl,years)=prod_var.l(rg_prov,prodct_dtl);

);

* ------------- expenditure-approach VA ------------------

parameters colctrl_expd(expd,years_sub)         column control of expenditure-approach VA
           colsum_expd(expd,years_sub)           column sum of expenditure-approach VA
           reslt_expd(rg_prov,expd,years_sub)    balanced expenditure-approach VA
           ;

           colsum_expd(expd,years_sub) = sum(rg_prov,ini_expenditure(rg_prov,expd,years_sub));
* ************ note the national sum of new_provflow should be 0;
           colctrl_expd(expd_sub,years_sub) = colsum_expd(expd_sub,years_sub)/sum(expd_subb,colsum_expd(expd_subb,years_sub))*sum(rg_prov,grp_CAL(rg_prov,years_sub));
           colctrl_expd('net_provflow',years_sub) = 0;

variables E3  cross entropy
          expd_var(rg_prov,expd) expenditure-approach VA
         ;

parameters
          grpp(rg_prov)            gross regional(provincial) productions of the balancing year
          colctrl_expdd(expd)        column control of expenditure-approach VA of the balancing year
          ini_exp(rg_prov,expd)     initial value of expenditure-approach VA of the balancing year
          ;

equations CAL_E3               calculation of cross entropy
          BAL_row3(rg_prov)      row balance
          BAL_col3(expd)        column balance
          BAL_provTrd       interprovincial trade balance
          ;

CAL_E3..

      E3 =e= sum((rg_prov,expd),sqr(expd_var(rg_prov,expd)-ini_exp(rg_prov,expd))/abs(ini_exp(rg_prov,expd)))
             ;

BAL_row3(rg_prov)..
    sum(expd,expd_var(rg_prov,expd)) =e= grpp(rg_prov);

BAL_col3(expd)..
    sum(rg_prov,expd_var(rg_prov,expd)) =e= colctrl_expdd(expd);

BAL_provTrd..
    sum(rg_prov,expd_var(rg_prov,'net_provflow')) =e= 0;


model md3 /
      CAL_E3
      BAL_row3
      BAL_col3
      BAL_provTrd

      /;

         OPTION ITERLIM = 50000;
         OPTION LIMROW = 150000, LIMCOL = 150000,   ResLim = 3000;
         OPTION SOLPRINT = ON;
         option NLP = CONOPT;

* .......... balance by year ..............
loop(years_sub,

         expd_var.l(rg_prov,expd) = ini_expenditure(rg_prov,expd,years_sub);
         ini_exp(rg_prov,expd) = ini_expenditure(rg_prov,expd,years_sub);
         grpp(rg_prov)=grp_CAL(rg_prov,years_sub);
         colctrl_expdd(expd) = colctrl_expd(expd,years_sub);

         solve md3 using nlp minimizing E3;
         reslt_expd(rg_prov,expd,years_sub)=expd_var.l(rg_prov,expd);

);

execute_unload 'results_MacroCtrl_97_17'    reslt_expd ini_expenditure reslt_incm ini_income reslt_prod ini_production ;
