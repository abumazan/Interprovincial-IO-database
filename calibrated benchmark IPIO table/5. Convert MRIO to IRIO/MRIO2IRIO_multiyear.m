% MRIO2IRIO_multiyear, make IRIO from MRIO for multi years, including
% information from trade in BEC classification

clear

% %%%%%%%%%%% add path for including gdx files %%%%%%%%%%
% do add file path of where the folder 'Benchmark IRIO_code and data' is
% located. For example, if the folder is located in 'D:\paper_review\',
% please assign 'D:\paper_review\' to the variable 'filepath' below.

filepath = '';

if isempty(filepath)
    error('Please add file path of where the folder ''Benchmark IRIO_code and data'' is located for reading gdx files. e.g., D:\GAMS\')

end

% %%%%%%%%%%% choose year %%%%%%%%%%%%
year = 1997; % choose from 1997, 2002, 2007, 2012, 2017
yr_idx = (year-1997)/5+1;

% %%%%%%%%%% load input data %%%%%%%%%%%%%%%%%
switch year

    case 1997
        rg_num = 31;
        sec_num = 40;

        idx_serv = zeros(sec_num,1);
        idx_serv([21 23:27 29 31:40]) = 1;

        eval(['load ProIOT_Totals total' num2str(year)])
        total = total1997;

        % get calibarted data from GDX files
        % calibrated IOTs
        reslt_cpiot = struct();
        reslt_cpiot.name = 'CPIOT_rslt_1997';
        reslt_cpiot.form = 'full';
        reslt_cpiot = rgdx([filepath 'Benchmark IRIO_code and data\3. Benchmark the Provincial IOT to the Calibrated National Account Data\1997\Calibrate_PMRIO1997_rslt.gdx'],reslt_cpiot);

        idx_sec = 1:sec_num;
        idx_va = 41:44;
        idx_fu = 45:53;
        idx_rg = 54:84;

        dttt = reslt_cpiot.val([idx_sec idx_va],[idx_sec idx_fu],[idx_rg]); 
        reslt_cpiot_dt = zeros(length([idx_sec idx_va]),length([idx_sec idx_fu])+1,length(idx_rg));
        reslt_cpiot_dt(:,1:(sec_num+5),:) = dttt(:,1:(sec_num+5),:);
        reslt_cpiot_dt(:,(sec_num+5+2):end,:) =  dttt(:,(sec_num+5+1):end,:);

        TIU_FU_Tr =  zeros(sec_num,11,rg_num);
        TIU_FU_Tr(:,2:end,:) = reslt_cpiot_dt(1:sec_num,(sec_num+1):end,:); 
        TIU_FU_Tr(:, 1,:)  = sum(reslt_cpiot_dt(1:sec_num,1:sec_num,:),2); 
        Z_VA_mat = reslt_cpiot_dt(1:sec_num+4,1:sec_num,:);

        % trade matrix
        reslt_trd = struct();
        reslt_trd.name = 'balancedTrd';
        reslt_trd.form = 'full';
        reslt_trd = rgdx([filepath 'Benchmark IRIO_code and data\4. Rebalance Inter-provincial Trade\1997\Calibrate_PMRIO1997_BTM_rslt.gdx'],reslt_trd);

        idx_sec = 1:sec_num;
        idx_rg = 57:87;

        balanced_Trd1 = reslt_trd.val(idx_sec,idx_rg,idx_rg);
        balanced_Trd = zeros(rg_num,rg_num,sec_num);
        for i = 1:rg_num % rg out
            balanced_Trd(i,:,:) = squeeze( balanced_Trd1(:,i,:))';
        end

    case 2002

        rg_num = 31;
        sec_num = 42;

        idx_serv = zeros(sec_num,1);
        idx_serv([22 23 25 26 28 29 31:42]) = 1;

        eval(['load ProIOT_Totals total' num2str(year)])
        total = total2002;

        % get calibarted data from GDX files
        % calibrated IOTs
        reslt_cpiot = struct();
        reslt_cpiot.name = 'CPIOT_rslt_2002';
        reslt_cpiot.form = 'full';
        reslt_cpiot = rgdx([filepath 'Benchmark IRIO_code and data\3. Benchmark the Provincial IOT to the Calibrated National Account Data\2002\Calibrate_PMRIO2002_rslt.gdx'],reslt_cpiot);

        idx_sec = 1:sec_num;
        idx_va = 43:46;
        idx_fu = 47:55;
        idx_rg = 56:86;

        dttt = reslt_cpiot.val([idx_sec idx_va],[idx_sec idx_fu],[idx_rg]); % v71及后续版本中，fu202neg实为0，恰机械化工作需保留此项，因而添加全零列
        reslt_cpiot_dt = zeros(length([idx_sec idx_va]),length([idx_sec idx_fu])+1,length(idx_rg));
        reslt_cpiot_dt(:,1:(sec_num+5),:) = dttt(:,1:(sec_num+5),:);
        reslt_cpiot_dt(:,(sec_num+5+2):end,:) =  dttt(:,(sec_num+5+1):end,:);

        TIU_FU_Tr =  zeros(sec_num,11,rg_num);
        TIU_FU_Tr(:,2:end,:) = reslt_cpiot_dt(1:sec_num,43:end,:);  % reslt_cpiot_dt中不含total
        TIU_FU_Tr(:, 1,:)  = sum(reslt_cpiot_dt(1:sec_num,1:sec_num,:),2); % TIU
        Z_VA_mat = reslt_cpiot_dt(1:sec_num+4,1:sec_num,:);

        % trade matrix
        reslt_trd = struct();
        reslt_trd.name = 'balancedTrd';
        reslt_trd.form = 'full';
        reslt_trd = rgdx([filepath 'Benchmark IRIO_code and data\4. Rebalance Inter-provincial Trade\2002\Calibrate_PMRIO2002_BTM_rslt.gdx'],reslt_trd);

        idx_sec = 1:sec_num;
        idx_rg = 59:89;

        balanced_Trd1 = reslt_trd.val(idx_sec,idx_rg,idx_rg);
        balanced_Trd = zeros(rg_num,rg_num,sec_num);
        for i = 1:rg_num %rg out
            balanced_Trd(i,:,:) = squeeze( balanced_Trd1(:,i,:))';
        end

    case 2007

        rg_num = 31;
        sec_num = 42;

        idx_serv = zeros(sec_num,1);
        idx_serv([22 23 25 26 28 29 31:42]) = 1;

        eval(['load ProIOT_Totals total' num2str(year)])
        total = total2007;

        % get calibarted data from GDX files
        % calibrated IOTs
        reslt_cpiot = struct();
        reslt_cpiot.name = 'CPIOT_rslt';
        reslt_cpiot.form = 'full';
        reslt_cpiot = rgdx([filepath 'Benchmark IRIO_code and data\3. Benchmark the Provincial IOT to the Calibrated National Account Data\2007\Calibrate_PMRIO2007_rslt.gdx'],reslt_cpiot);

        idx_sec = 1:sec_num;
        idx_va = 43:46;
        idx_fu = 47:55;
        idx_rg = 56:86;

        dttt = reslt_cpiot.val([idx_sec idx_va],[idx_sec idx_fu],[idx_rg]); % v71及后续版本中，fu202neg实为0，恰机械化工作需保留此项，因而添加全零列
        reslt_cpiot_dt = zeros(length([idx_sec idx_va]),length([idx_sec idx_fu])+1,length(idx_rg));
        reslt_cpiot_dt(:,1:(sec_num+5),:) = dttt(:,1:(sec_num+5),:);
        reslt_cpiot_dt(:,(sec_num+5+2):end,:) =  dttt(:,(sec_num+5+1):end,:);

        TIU_FU_Tr =  zeros(sec_num,11,rg_num);
        TIU_FU_Tr(:,2:end,:) = reslt_cpiot_dt(1:sec_num,43:end,:);  % reslt_cpiot_dt中不含total
        TIU_FU_Tr(:, 1,:)  = sum(reslt_cpiot_dt(1:sec_num,1:sec_num,:),2); % TIU
        Z_VA_mat = reslt_cpiot_dt(1:sec_num+4,1:sec_num,:);

        % trade matrix
        reslt_trd = struct();
        reslt_trd.name = 'balancedTrd';
        reslt_trd.form = 'full';
        reslt_trd = rgdx([filepath 'Benchmark IRIO_code and data\4. Rebalance Inter-provincial Trade\2007\Calibrate_PMRIO2007_BTM_rslt.gdx'],reslt_trd);

        idx_sec = 1:sec_num;
        idx_rg = 59:89;

        balanced_Trd1 = reslt_trd.val(idx_sec,idx_rg,idx_rg);
        balanced_Trd = zeros(rg_num,rg_num,sec_num);
        for i = 1:rg_num %rg out
            balanced_Trd(i,:,:) = squeeze( balanced_Trd1(:,i,:))';
        end

    case 2012

        rg_num = 31;
        sec_num = 42;

        idx_serv = zeros(sec_num,1);
        idx_serv([24 25 27 28 31:42]) = 1;

        eval(['load ProIOT_Totals total' num2str(year)])
        total = total2012;

        % get calibarted data from GDX files
        % calibrated IOTs
        reslt_cpiot = struct();
        reslt_cpiot.name = 'CPIOT_rslt';
        reslt_cpiot.form = 'full';
        reslt_cpiot = rgdx([filepath 'Benchmark IRIO_code and data\3. Benchmark the Provincial IOT to the Calibrated National Account Data\2012\Calibrate_PMRIO2012_rslt.gdx'],reslt_cpiot);

        idx_sec = 1:sec_num;
        idx_va = 43:46;
        idx_fu = 47:55;
        idx_rg = 56:86;

        dttt = reslt_cpiot.val([idx_sec idx_va],[idx_sec idx_fu],[idx_rg]); % v71及后续版本中，fu202neg实为0，恰机械化工作需保留此项，因而添加全零列
        reslt_cpiot_dt = zeros(length([idx_sec idx_va]),length([idx_sec idx_fu])+1,length(idx_rg));
        reslt_cpiot_dt(:,1:(sec_num+5),:) = dttt(:,1:(sec_num+5),:);
        reslt_cpiot_dt(:,(sec_num+5+2):end,:) =  dttt(:,(sec_num+5+1):end,:);

        TIU_FU_Tr =  zeros(sec_num,11,rg_num);
        TIU_FU_Tr(:,2:end,:) = reslt_cpiot_dt(1:sec_num,43:end,:);  % reslt_cpiot_dt中不含total
        TIU_FU_Tr(:, 1,:)  = sum(reslt_cpiot_dt(1:sec_num,1:sec_num,:),2); % TIU
        Z_VA_mat = reslt_cpiot_dt(1:sec_num+4,1:sec_num,:);

        % trade matrix
        reslt_trd = struct();
        reslt_trd.name = 'balancedTrd';
        reslt_trd.form = 'full';
        reslt_trd = rgdx([filepath 'Benchmark IRIO_code and data\4. Rebalance Inter-provincial Trade\2012\Calibrate_PMRIO2012_BTM_rslt.gdx'],reslt_trd);

        idx_sec = 1:sec_num;
        idx_rg = 59:89;

        balanced_Trd1 = reslt_trd.val(idx_sec,idx_rg,idx_rg);
        balanced_Trd = zeros(rg_num,rg_num,sec_num);
        for i = 1:rg_num %rg out
            balanced_Trd(i,:,:) = squeeze( balanced_Trd1(:,i,:))';
        end


    case 2017
        rg_num = 31;
        sec_num = 42;

        idx_serv = zeros(sec_num,1);
        idx_serv([23 24 27 30:42]) = 1;

        eval(['load ProIOT_Totals total' num2str(year)])
        total = total2017;

        % get calibarted data from GDX files
        % calibrated IOTs
        reslt_cpiot = struct();
        reslt_cpiot.name = 'CPIOT_rslt';
        reslt_cpiot.form = 'full';
        reslt_cpiot = rgdx([filepath 'Benchmark IRIO_code and data\3. Benchmark the Provincial IOT to the Calibrated National Account Data\2017\Calibrate_PMRIO2017_rslt.gdx'],reslt_cpiot);

        idx_sec = 1:sec_num;
        idx_va = 43:46;
        idx_fu = 47:55;
        idx_rg = 56:86;

        dttt = reslt_cpiot.val([idx_sec idx_va],[idx_sec idx_fu],[idx_rg]);
        reslt_cpiot_dt = zeros(length([idx_sec idx_va]),length([idx_sec idx_fu])+1,length(idx_rg));
        reslt_cpiot_dt(:,1:(sec_num+5),:) = dttt(:,1:(sec_num+5),:);
        reslt_cpiot_dt(:,(sec_num+5+2):end,:) =  dttt(:,(sec_num+5+1):end,:);

        TIU_FU_Tr =  zeros(sec_num,11,rg_num);
        TIU_FU_Tr(:,2:end,:) = reslt_cpiot_dt(1:sec_num,43:end,:);
        TIU_FU_Tr(:, 1,:)  = sum(reslt_cpiot_dt(1:sec_num,1:sec_num,:),2);
        Z_VA_mat = reslt_cpiot_dt(1:sec_num+4,1:sec_num,:);

        % trade mat
        reslt_trd = struct();
        reslt_trd.name = 'balancedTrd';
        reslt_trd.form = 'full';
        reslt_trd = rgdx([filepath 'Benchmark IRIO_code and data\4. Rebalance Inter-provincial Trade\2017\Calibrate_PMRIO2017_BTM_rslt.gdx'],reslt_trd);

        idx_sec = 1:sec_num;
        idx_rg = 59:89;

        balanced_Trd1 = reslt_trd.val(idx_sec,idx_rg,idx_rg);
        balanced_Trd = zeros(rg_num,rg_num,sec_num);
        for i = 1:rg_num %rg out
            balanced_Trd(i,:,:) = squeeze( balanced_Trd1(:,i,:))';
        end

end

%% %%%%%%%%%%%%%%%%%%%%%%%% Estimate IRIO %%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%% estimate ratios %%%%%%%%%%%%%%%%%%%%%
% ========= calculate initial ratios, and prepare for RAS =================
error = total-squeeze(sum(TIU_FU_Tr,2)-2*sum(TIU_FU_Tr(:,[7,10:11],:),2));
dmd_d = squeeze(sum(TIU_FU_Tr(:,1:6,:),2)-TIU_FU_Tr(:,7,:))+error;
inflow = squeeze(sum(TIU_FU_Tr(:,10:11,:),2));
dmd_d_int = squeeze(sum(TIU_FU_Tr(:,1,:),2));
dmd_d_cons = squeeze(sum(TIU_FU_Tr(:,2:4,:),2));
dmd_d_cap = squeeze(sum(TIU_FU_Tr(:,5,:),2));
dmd_d_inv = squeeze(sum(TIU_FU_Tr(:,6,:),2)-TIU_FU_Tr(:,7,:))+error;

% ----------- check ---------------
check = inflow>dmd_d;
check2 = inflow-dmd_d;
check3 = any(check2>10^(-10));
check4 = check2.*check;
check5 = max(max(check4),[],2);
% -----------------------------------
imp = squeeze(TIU_FU_Tr(:,10,:));
proin = squeeze(TIU_FU_Tr(:,11,:));
prod_d = total-squeeze(sum(TIU_FU_Tr(:,8:9,:),2));
r_imp0 = imp./(dmd_d_int+dmd_d_cons+dmd_d_cap);
r_imp = r_imp0;
r_imp(isnan(r_imp))=0;
r_proin = proin./(dmd_d-(imp-(dmd_d_int+dmd_d_cons+dmd_d_cap)));
r_proin(isnan(r_proin))=0;
r_d = 1-r_imp-r_proin;
r_d(r_d<0) = 0;

for i = 1:rg_num
    dt = squeeze(balanced_Trd(:,i,:))'./repmat(dmd_d(:,i)-dmd_d_inv(:,i),1,rg_num); % 假设：省际流入不用于存货变动
    dt(isnan(dt)) = 0;
    dt = repmat(r_proin(:,i),1,rg_num).*(dt./repmat(sum(dt,2),1,rg_num));
    dt(isnan(dt)) = 0;
    r_proinM{i} = dt;
end

% ------------------- repeat --------------------
for i = 1:rg_num
    r_impM{i} = repmat(r_imp(:,i),1,sec_num+5+1);
    for j = 1:rg_num
        r_proinMM{j,i} = repmat(r_proinM{i}(:,j),1,sec_num+5+1);
    end
end

for i = 1:rg_num
    r_proinMM{i,i} = repmat(r_d(:,i),1,sec_num+5+1);
end

% %%%%%%  rebalance r_imp, r_proin and r_d using RAS %%%%%%%%%%%%%
switch year

    case 1997
        run([filepath 'Benchmark IRIO_code and data 2023.2\5. Convert MRIO to IRIO\TrdShare1997_v3.m']);
    case 2002
        run([filepath 'Benchmark IRIO_code and data 2023.2\5. Convert MRIO to IRIO\TrdShare2002_v3.m']);
    case 2007
        run([filepath 'Benchmark IRIO_code and data 2023.2\5. Convert MRIO to IRIO\TrdShare2007_v3.m']);
    case 2012
        run([filepath 'Benchmark IRIO_code and data\5. Convert MRIO to IRIO\TrdShare2012_v3.m']);
    case 2017
        run([filepath 'Benchmark IRIO_code and data\5. Convert MRIO to IRIO\TrdShare2017_v3.m']);

end

% ===== replace shares with the estimated ones in 'TrdShare2017_v1' =====
for i = 1:rg_num
    matimp = [repmat(alpha_int(:,i),1,sec_num) repmat(alpha_cons(:,i),1,3) alpha_cap(:,i)];
    r_impM{i} = matimp;
    for j = 1:rg_num

        provincel = zeros(sec_num,3);
        for k = 1:sec_num
            provincel(k,:) = B_A{k,i}(j,:);

        end
        matprovin = [repmat(provincel(:,1),1,sec_num) repmat(provincel(:,2),1,3) provincel(:,3)];
        r_proinMM{j,i} = matprovin;
    end
end

% %%%%%%%%%%%% estimate IO variables %%%%%%%%%%%%%%%%%%%%
for i = 1:rg_num
    % import matrices
    M_mixed = [Z_VA_mat(1:sec_num,:,i) TIU_FU_Tr(:,2:5,i)]; % TIU_FU_Tr(:,6,i)-TIU_FU_Tr(:,7,i) error(:,i) % 中间使用、消费*3、资本形成、存货变动、误差/新方法不含存货变动
    impM{i} = r_impM{i}.*M_mixed;
    % interprovincial import matrices
    for j = 1:rg_num
        proM{j,i} = r_proinMM{j,i}.*M_mixed;
    end
end

% ===================  fix inventory change ========================

inve_d_trans = cell(rg_num,rg_num);
inve_provin_trans = cell(rg_num,rg_num);

for i = 1:rg_num
    for j = 1:rg_num
        dtt = zeros(sec_num,1);
        dtt2 = zeros(sec_num,1);

        for k =1:sec_num

            dtt(k) = inve_d{k,j}(i);
            dtt2(k) = -inve_provin{k,j}(i);

        end
        inve_d_trans{i,j} = dtt; % adde overloaded inventory changes to each provinces
        inve_provin_trans{i,j} = dtt2;

    end

end

% ----------- test --------------------
for j = 1:31
    sumdtt{j,1} = [sum(cell2mat(inve_d_trans(:,j))) sum(cell2mat(inve_provin_trans(:,j)))];

end

% ------------- interprovincial inventory change matrices ---------------
Inve_err = cell(rg_num,rg_num);
for i = 1:rg_num
    dtt = TIU_FU_Tr(:,6,i)-TIU_FU_Tr(:,7,i) + error(:,i); % merge inventory change and error
    dtt = dtt+sum(reshape(cell2mat(inve_d_trans(i,i)),sec_num,[]),2)-dmd_imp_inv(:,i);% inventory change provided locally
    Inve_err{i,i} = dtt;

    for j = 1:rg_num
        if j~=i
            Inve_err{i,j} = inve_provin_trans{i,j}; % inventory change provided by other provinces
        end
    end
end


% %%%%%%%%%%%%%%  test %%%%%%%%%%%%
checkM3 = zeros(1,rg_num);
for i = 1:rg_num
    M_mixed = [Z_VA_mat(1:sec_num,:,i) TIU_FU_Tr(:,2:5,i)]; % TIU_FU_Tr(:,6,i)-TIU_FU_Tr(:,7,i) error(:,i)
    MM = [proM(:,i);impM{i}];
    MM = reshape(MM,1,1,[]);
    MMm = cell2mat(MM);
    sumM = sum(MMm,3);
    checkM = M_mixed-sumM;
    checkM2 = any(checkM~=0);
    checkM3(i) = max(max(abs(checkM)),[],2);
end
checkM4 = any(checkM3>10^(-7));

% %%%%%%%%%%%%%%%%%%%%%%% get Z and Y %%%%%%%%%%%%%%%%%%%

for i = 1:rg_num
    mm = cell2mat([proM(:,i); impM{i}]);
    MM = [mm [cell2mat(Inve_err(:,i)); dmd_imp_inv(:,i)]];

    z{i} = MM(:,1:sec_num);
    y{i} = MM(:,sec_num+1:sec_num+5);

end

% %%%%%%%% get IRIO varibles %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z = cell2mat(z);
Z(isnan(Z)) = 0;
Y = cell2mat(y);
Y(isnan(Y)) = 0;

MRIO_Zd = Z(1:sec_num*rg_num,:);
MRIO_Zim = Z(sec_num*rg_num+1:end,:);
MRIO_Yd = Y(1:sec_num*rg_num,:);
MRIO_Yim = Y(sec_num*rg_num+1:end,:);
V = Z_VA_mat(sec_num+1:end,:,:);
MRIO_V = reshape(V,4,[],1);
MRIO_total = reshape(total,[],1);
EX = squeeze(TIU_FU_Tr(:,8,:));
MRIO_EX = reshape(EX,[],1);

err_after = MRIO_total-sum(MRIO_Zd,2)-sum(MRIO_Yd,2)-MRIO_EX;

err_max = max(abs(err_after)); % do check this value to see if it is small enough
disp(['The largest absolute value in err_max: ' num2str(err_max)])

err_after_diag = kron(eye(rg_num),[zeros(sec_num,4) ones(sec_num,1)]).*repmat(err_after,1,5*rg_num);
MRIO_Yd = MRIO_Yd+err_after_diag;

% there should not be non-zeros in inventory of most of the service sectors,
% add these tiny "inventory" to consumption and fixed capiatal proportionally.
% values are close to 0.
MRIO_Y = [MRIO_Yd;MRIO_Yim];

idx_getinveserv = kron(eye(rg_num),[zeros(4,5);ones(1,5)]);
pidx_serv = repmat(idx_serv,rg_num+1,rg_num*5);
inve_serv = MRIO_Y.*pidx_serv*idx_getinveserv;

idx_sumFU = kron(eye(rg_num),[ones(4,5);zeros(1,5)]);
idx_getFU = kron(ones(rg_num+1,rg_num),[ones(sec_num,4) zeros(sec_num,1)]);

Yd_part = MRIO_Y.*idx_getFU;
Yd_partsum = MRIO_Y*idx_sumFU;

Yd_share = Yd_part./Yd_partsum;
Yd_share(isnan(Yd_share)) = 0;
Yd_alloc = Yd_share.*inve_serv;
Yd_alloc_sum = Yd_alloc*idx_sumFU;
checkYdalloc = max(max(abs(Yd_alloc_sum-inve_serv),[],1),[],2); % get the largest gap, to see if it is small enough
disp(['The largest absolute value in checkYdalloc: ' num2str(checkYdalloc)])

ppidx_serv = repmat(idx_serv,rg_num+1,1);
MRIO_Y(logical(ppidx_serv),5:5:5*rg_num) = 0;
MRIO_Y = MRIO_Y+Yd_alloc;

MRIO_Yd = MRIO_Y(1:sec_num*rg_num,:);
MRIO_Yim = MRIO_Y(sec_num*rg_num+1:end,:);

% ========== structure the IRIO variables =========================
eval(['CalibMRIO' num2str(year) '.year = ''' num2str(year) ''';'])
eval(['CalibMRIO' num2str(year) '.unit = ''10^8 CNY'';'])
eval(['CalibMRIO' num2str(year) '.price = ''current producer price'';'])
eval(['CalibMRIO' num2str(year) '.Z_d = MRIO_Zd;'])
eval(['CalibMRIO' num2str(year) '.Z_im = MRIO_Zim;'])
eval(['CalibMRIO' num2str(year) '.Y_d = MRIO_Yd;'])
eval(['CalibMRIO' num2str(year) '.Y_im = MRIO_Yim;'])
eval(['CalibMRIO' num2str(year) '.EX = MRIO_EX;'])
eval(['CalibMRIO' num2str(year) '.V = MRIO_V;'])
eval(['CalibMRIO' num2str(year) '.total = MRIO_total;'])

eval(['save CalibMRIO' num2str(year) ' CalibMRIO*'])

