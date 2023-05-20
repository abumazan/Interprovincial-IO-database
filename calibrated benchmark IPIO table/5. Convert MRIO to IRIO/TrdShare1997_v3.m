% Involve trade share, and rebalance inflow shares

%% trim initial data
load TrdShare.mat impshare1997
impshare = impshare1997;

sec_num = 40;

impshare_dt = impshare(1:end,1:3);
impshare_flag = impshare(1:end,4);
impshare_dt_3d = reshape(impshare_dt,sec_num,31,3);
impshare_flag_2d = reshape(impshare_flag,sec_num,31);
impshare_flag_logic = zeros(sec_num,31);
impshare_flag_logic(round(impshare_flag_2d) ~= 1) = 1;

%% rebalance

% calculate share of imports by categories
  % preprocess impshare_dt_3d
  
r_imp_treated = r_imp .* impshare_flag_logic; 
impshare_dt_3d(round(repmat(impshare_flag_2d,1,1,3)) ~= 1) = 0; % change sectors not covered in BEC data to '0'
imp_int = imp .* impshare_dt_3d(:,:,1);
imp_cons = imp .* impshare_dt_3d(:,:,2);
imp_cap = imp .* impshare_dt_3d(:,:,3);

alpha_int = imp_int ./ dmd_d_int;
alpha_cons = imp_cons ./ dmd_d_cons;
alpha_cap = imp_cap ./ dmd_d_cap;

alpha_int_agg = sum(imp_int) ./ sum(dmd_d_int); 
alpha_cons_agg = sum(imp_cons) ./ sum(dmd_d_cons);
alpha_cap_agg = sum(imp_cap) ./ sum(dmd_d_cap);

dmd_imp_inv = zeros(size(alpha_cap));
dmd_imp_inv(isinf(alpha_cap)) = imp_cap(isinf(alpha_cap)); 
dmd_imp_inv(isinf(alpha_cons)) = imp_cons(isinf(alpha_cons))+dmd_imp_inv(isinf(alpha_cons)); % imports used for inventory change
dmd_imp_inv(isinf(alpha_int)) = imp_int(isinf(alpha_int))+dmd_imp_inv(isinf(alpha_int));

imp_cap(isinf(alpha_cap)) = 0;
imp_cons(isinf(alpha_cons)) = 0;
imp_int(isinf(alpha_int)) = 0;

% allocate service sectors in dmd_imp_inv to cons and int
idx_serv_m = repmat(idx_serv,1,rg_num);
serv_over1 = dmd_imp_inv.*idx_serv_m;

dmd_imp_inv = dmd_imp_inv-serv_over1;

s_dmd_d_int = dmd_d_int./(dmd_d_int+dmd_d_cons+dmd_d_cap);
    s_dmd_d_int(isnan(s_dmd_d_int)) = 0;
    s_dmd_d_int(isinf(s_dmd_d_int)) = 0;
s_dmd_d_cons = dmd_d_cons./(dmd_d_int+dmd_d_cons+dmd_d_cap);
    s_dmd_d_cons(isnan(s_dmd_d_cons)) = 0;
    s_dmd_d_cons(isinf(s_dmd_d_cons)) = 0;
s_dmd_d_cap = dmd_d_cap./(dmd_d_int+dmd_d_cons+dmd_d_cap);
    s_dmd_d_cap(isnan(s_dmd_d_cap)) = 0;
    s_dmd_d_cap(isinf(s_dmd_d_cap)) = 0;

imp_int = imp_int+serv_over1.*s_dmd_d_int;
imp_cons = imp_cons+serv_over1.*s_dmd_d_cons;
imp_cap = imp_cap+serv_over1.*s_dmd_d_cap;

% recalculate shares of imports in total domestic demand
alpha_int = imp_int ./ dmd_d_int;
alpha_cons = imp_cons ./ dmd_d_cons;
alpha_cap = imp_cap ./ dmd_d_cap;

alpha_int(isnan(alpha_int)) = 0;
alpha_cons(isnan(alpha_cons)) = 0;
alpha_cap(isnan(alpha_cap)) = 0;

alpha_int = alpha_int+r_imp_treated; % Supplement for sectors without BEC data
alpha_cons = alpha_cons+r_imp_treated;
alpha_cap = alpha_cap+r_imp_treated;

imp_int = alpha_int.*dmd_d_int; % recalculate imp_int
imp_cons = alpha_cons.*dmd_d_cons;
imp_cap = alpha_cap.*dmd_d_cap;

% deal values over 1
dmd_imp_inv(alpha_int>1) = dmd_imp_inv(alpha_int>1)+(imp_int(alpha_int>1)-dmd_d_int(alpha_int>1));
dmd_imp_inv(alpha_cons>1) = dmd_imp_inv(alpha_cons>1)+(imp_cons(alpha_cons>1)-dmd_d_cons(alpha_cons>1));
dmd_imp_inv(alpha_cap>1) = dmd_imp_inv(alpha_cap>1)+(imp_cap(alpha_cap>1)-dmd_d_cap(alpha_cap>1));

serv_over_int = zeros(sec_num,rg_num);
serv_over_int(alpha_int>1) = imp_int(alpha_int>1)-dmd_d_int(alpha_int>1);
serv_over_int = serv_over_int.*idx_serv_m;

serv_over_cons = zeros(sec_num,rg_num);
serv_over_cons(alpha_cons>1) = imp_cons(alpha_cons>1)-dmd_d_cons(alpha_cons>1);
serv_over_cons = serv_over_cons.*idx_serv_m;

serv_over_cap = zeros(sec_num,rg_num);
serv_over_cap(alpha_cap>1) = imp_cap(alpha_cap>1)-dmd_d_cap(alpha_cap>1);
serv_over_cap = serv_over_cap.*idx_serv_m;

imp_int(alpha_int>1) = imp_int(alpha_int>1)-(imp_int(alpha_int>1)-dmd_d_int(alpha_int>1));
imp_cons(alpha_cons>1) = imp_cons(alpha_cons>1)-(imp_cons(alpha_cons>1)-dmd_d_cons(alpha_cons>1));
imp_cap(alpha_cap>1) = imp_cap(alpha_cap>1)-(imp_cap(alpha_cap>1)-dmd_d_cap(alpha_cap>1));

% allocate service sectors in dmd_imp_inv to cons and int
serv_over2 = dmd_imp_inv.*idx_serv_m;
dmd_imp_inv = dmd_imp_inv-serv_over2;

% allocate int over cons and cap

ss_dmd_d_cons = s_dmd_d_cons./(s_dmd_d_cons+s_dmd_d_cap);
    ss_dmd_d_cons(isnan(ss_dmd_d_cons)) = 0;
ss_dmd_d_cap = s_dmd_d_cap./(s_dmd_d_cons+s_dmd_d_cap);
    ss_dmd_d_cap(isnan(ss_dmd_d_cap)) = 0;

imp_cons = imp_cons+serv_over_int.*ss_dmd_d_cons;
imp_cap = imp_cap+serv_over_int.*ss_dmd_d_cap;

% allocate cons over int and cap
ss_dmd_d_int = s_dmd_d_int./(s_dmd_d_int+s_dmd_d_cap);
    ss_dmd_d_int(isnan(ss_dmd_d_int)) = 0;
ss_dmd_d_cap = s_dmd_d_cap./(s_dmd_d_int+s_dmd_d_cap);
    ss_dmd_d_cap(isnan(ss_dmd_d_cap)) = 0;

imp_int = imp_int+serv_over_cons.*ss_dmd_d_int;
imp_cap = imp_cap+serv_over_cons.*ss_dmd_d_cap;

% allocate cap over int and cons

ss_dmd_d_int = s_dmd_d_int./(s_dmd_d_int+s_dmd_d_cons);
    ss_dmd_d_int(isnan(ss_dmd_d_int)) = 0;
ss_dmd_d_cons = s_dmd_d_cons./(s_dmd_d_int+s_dmd_d_cons);
    ss_dmd_d_cons(isnan(ss_dmd_d_cons)) = 0;

imp_int = imp_int+serv_over_cap.*ss_dmd_d_int;
imp_cons = imp_cons+serv_over_cap.*ss_dmd_d_cons;


% recalculate shares of imports in total domestic demand
alpha_int = imp_int ./ dmd_d_int;
alpha_cons = imp_cons ./ dmd_d_cons;
alpha_cap = imp_cap ./ dmd_d_cap;

alpha_int(isnan(alpha_int)) = 0;
alpha_cons(isnan(alpha_cons)) = 0;
alpha_cap(isnan(alpha_cap)) = 0;

% check if there are still infs or numbers larger than 1
checkalpha_int1 = summ(isinf(alpha_int));
checkalpha_int2 = summ(alpha_int>(1+10^(-10)));

checkalpha_cons1 = summ(isinf(alpha_cons));
checkalpha_cons2 = summ(alpha_cons>(1+10^(-10)));

checkalpha_cap1 = summ(isinf(alpha_cap));
checkalpha_cap2 = summ(alpha_cap>(1+10^(-10)));

if any([checkalpha_int1 checkalpha_int2 checkalpha_cons1 checkalpha_cons2 checkalpha_cap1 checkalpha_cap2]>0)
    warning('unsatisfactory value in alpha_*')
end

inve_test = prod_d-dmd_d_inv+dmd_imp_inv; 
dmd_imp_inv2 = squeeze(sum(balanced_Trd,1))'+inve_test.*(inve_test<0); 

% calculate sum of shares of interprovincial inflows
colctrl = zeros(sec_num,31,3);
colctrl(:,:,1) = ones(size(alpha_int))-alpha_int; 
colctrl(:,:,2) = ones(size(alpha_int))-alpha_cons; 
colctrl(:,:,3) = ones(size(alpha_int))-alpha_cap; 
colctrl(colctrl<0) = 0;

%% rebalance using RAS by sector
B_A_ini = cell(sec_num,31); % results of b_a
GetOrNot = nan(sec_num,31);
inve_d = cell(sec_num,31);
inve_provin = cell(sec_num,31);
inve_imp_add = cell(sec_num,31);

prod_d(prod_d<0) = 0;
loc_r = prod_d./total;
loc_r(loc_r<0) = 0;
loc_r(isnan(loc_r)) = 0;
loc_r(isinf(loc_r)) = 0;

for i = 1:sec_num
    for j = 1:31
        a = r_proinM{j}(i,:); % r_proin
        a(j) = r_d(i,j);
        a = repmat(a',1,3);
        r_ctrl = squeeze(balanced_Trd(:,j,i));

        inve_gap = prod_d(i,j)-dmd_d_inv(i,j)+dmd_imp_inv(i,j); 
        inve_d{i,j} = zeros(sec_num,1);
        inve_provin{i,j} = zeros(rg_num,1);        
        
        if inve_gap<(prod_d(i,j)*loc_r(i,j)) 
            r_ctrl(j) = prod_d(i,j)*loc_r(i,j);
            inve_gap =  prod_d(i,j)*loc_r(i,j)-inve_gap;

            r_ctrl4s = r_ctrl;
            r_ctrl4s(j) = 0;
            if inve_gap>sum(r_ctrl4s)
                inve_gap2 = inve_gap-sum(r_ctrl4s);
                r_ctrl(j) = r_ctrl(j)-inve_gap2;
                inve_gap = sum(r_ctrl4s);
            end

            inve_d{i,j}(j) = -inve_gap;

            r_ctrl_shr = r_ctrl4s/sum(r_ctrl4s);
            neg_div = (-inve_gap)*r_ctrl_shr;
            r_ctrl = r_ctrl+neg_div; 
            r_ctrl(r_ctrl<0) = 0;
            if any(r_ctrl<0)
                negrctrl{i,j} = r_ctrl;
            end
            inve_provin{i,j} = neg_div;
        else
            r_ctrl(j) = inve_gap; 
        end

        rl{i,j} = r_ctrl;
               
        c_ctrl = squeeze(colctrl(i,j,:));
        c_ctrl = c_ctrl';
        if any(c_ctrl<0)
            warning('negtive c_ctrl!')
        end
        
        weight = [dmd_d_int(i,j) dmd_d_cons(i,j) dmd_d_cap(i,j)]'; 
        wgt{i,j} = weight;
               
        [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,0,'-deal');
        B_A_ini{i,j} = b_a;
        if GetOrNot(i,j)==0 % solution not found
            accu = 10^(-14);
            [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
            
            if GetOrNot(i,j)==0 % solution not found
                accu = 10^(-13);
                [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                if  GetOrNot(i,j)==0 % solution not found
                    accu = 10^(-12);
                    [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                    if  GetOrNot(i,j)==0 % solution not found
                        accu = 10^(-11);
                        [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                        if GetOrNot(i,j)==0 % solution not found
                            accu = 10^(-10);
                            [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                            if  GetOrNot(i,j)==0 % solution not found
                                accu = 10^(-9);
                                [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                if GetOrNot(i,j)==0 % solution not found
                                    accu = 10^(-8);
                                    [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                    if GetOrNot(i,j)==0 % solution not found
                                        accu = 10^(-7);
                                        [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                        if GetOrNot(i,j)==0 % solution not found
                                            warning('No solution when 10^(-7)')
                                            accu = 10^(-6);
                                            [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                            if GetOrNot(i,j)==0 % solution not found
                                                accu = 10^(-5);
                                                [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                                if GetOrNot(i,j)==0 % solution not found
                                                    accu = 10^(-4);
                                                    [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                                    if GetOrNot(i,j)==0 % solution not found
                                                    accu = 10^(-3);
                                                    [b_a,~,GetOrNot(i,j)] = wRAS1(a,r_ctrl,c_ctrl,weight,1000,accu,'-deal');
                                                    if GetOrNot(i,j)==0 % solution not found
                                                    warning('No solution when 10^(-3)')
                                                    end
                                                    end
                                                end
                                            else
                                                B_A_ini{i,j} = b_a;
                                            end
                                        else
                                            B_A_ini{i,j} = b_a;
                                        end
                                    else
                                        B_A_ini{i,j} = b_a;
                                    end
                                else
                                    B_A_ini{i,j} = b_a;
                                end
                            else
                                B_A_ini{i,j} = b_a;
                            end
                        else
                            B_A_ini{i,j} = b_a;
                        end
                    else
                        B_A_ini{i,j} = b_a;
                    end
                else
                    B_A_ini{i,j} = b_a;
                end
            else
                B_A_ini{i,j} = b_a;
            end
        else
            B_A_ini{i,j} = b_a;
        end
    end
end

B_A = B_A_ini;









