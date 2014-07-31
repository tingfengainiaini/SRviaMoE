function SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, lamda, ERelation, EUseTol, EUseW_0, GUseMetric, dataNum)
    folder_wang = pwd;
    if nargin < 1
        kmeans_Num = 128;
        beta = 3;
        maxIt = 100;
        LearningRate = 0.001;
    end
    
    folder_mappingdata_wang = fullfile(folder_wang,sprintf('MappingData_%d_full_%d',kmeans_Num, dataNum));
    folder_moe_result_wang = fullfile(folder_wang,sprintf('moe_result_ENFixed_k%d_e%d_beta%d_lamda%g_%s_regular_usetol%d_usew%d_usem%d_%d',kmeans_Num, ExpertNum, Gbeta,lamda,ERelation, EUseTol,EUseW_0,GUseMetric,dataNum));
    
    if ~exist(folder_moe_result_wang,'dir')
            mkdir(folder_moe_result_wang);
    end
        
    idx_label_start = 1;
    idx_label_end = kmeans_Num;%Parameter
    cut_value = 1000000;%set the value to be cutted 设置需要裁剪规模的阈值。可以稍微改的大一些。
    
    
    warning('off','MATLAB:rankDeficientMatrix');
    % fbme_arr = cell(num_files,1);
    badMoENum = 1;
    iter_total = 1;
    LearningRateTemp = LearningRate;
    while badMoENum > 0 && iter_total < 10
        %----------------------------------while iterate---------------------------------------------------------------
        badMoENum = 0;
        badmoeIndex = [];
        for idx_label = idx_label_start:idx_label_end%根据聚类的标签遍历处理
            LearningRate = LearningRateTemp;
        %for idx_label  = [1212 1546 4001]%根据聚类的标签遍历处理
            fn_moe = sprintf('moeRresult_%d.mat',idx_label);
            fn_full = fullfile(folder_moe_result_wang,fn_moe);
             if ~exist(fn_full,'file')
                fprintf('running %s\n',fn_full);
                %continue;
             else
                loadDataTest = load(fn_full);
                moeTest = loadDataTest.moe;
                if sum(isinf(moeTest.LogLike))>0
                    fprintf('%d moe is bad, loglike - inf--------total %d', idx_label, badMoENum);
                    badMoENum =badMoENum+1;
                    badmoeIndex = [badmoeIndex idx_label]
                    LearningRate = LearningRate*power(0.2,iter_total);
                    continue;
                else
                    if isfield(moeTest.Experts, 'Weights')
                        fprintf('skip %s\n',fn_full);
                        continue;
                    else
                        fprintf('%d moe is bad,no weights--------total %d', idx_label, badMoENum);
                        badMoENum =badMoENum+1;
                        badmoeIndex = [badmoeIndex idx_label]
                        LearningRate = LearningRate*power(0.2,iter_total);
                    end
                end
                clear loadDataTest;
                %continue;
             end
            fn_mapData = sprintf('MappingData_%d.mat',idx_label);
            fn_full_mapData = fullfile(folder_mappingdata_wang,fn_mapData);
            if ~exist(fn_full_mapData,'file')
                fprintf('not exist file %s ! Please check!\n',fn_full_mapData);
                continue;
            end
            loaddata = load(fn_full_mapData);
            Input = loaddata.Input;
            Target = loaddata.Target;

            
            %if the input size > 10000, we just use the half;
            dim1 = size(Input,1);
            if (dim1 >= cut_value)
                Input = Input(1:2:dim1,:);
                Target = Target(1:2:dim1,:);    
            end
            
            NumOfExperts = ExpertNum;
            clear loaddata;
            
            %Initialize the w0 by the regressor resulted from the data
            %If set the Input\Target, just use the information that the data have. 
            %If set the w gotten from , just use the information that the data have.
            %w_0 = Input\Target;
            load_w0 = load('w0.mat','www');
            w_0 = load_w0.www;
            
            clear load_w0;
            %Initialize the lamda by the computation lamda/logn
            
            fprintf('ExpertNum: %d, Input size %d, max: %f, min: %f\n', NumOfExperts, dim1, max(max(Input)), min(min(Input)));
            %% Create moe
           moe = moeSimpleCreate('NumExperts', NumOfExperts , 'MaxIt', maxIt, 'EType', 'linear', 'Elamda',lamda, 'ENbf', 0.1,'EUseTol',EUseTol,'EUseW_0',EUseW_0, 'EWInit', w_0, 'EKernel', 'linear', 'EKParam', 0.5, ...
        'GType', 'metric',  'GERelation', ERelation,  'GNbf', 0.1,'GBeta',Gbeta,'GUseMetric',GUseMetric, 'GLearningRate', LearningRate, 'GKernel', 'linear', 'GKParam', 0.5);
            % Input = repmat(Input,[1 2]);
            % Target = repmat(Target,[1 2]);
        %     Input = A;
        %     Target = [Target Target];
           %% 初始化BME，使用Keans
            moe = moeSimpleInit(moe, Input, Target) ; 
            %% BME的训练
            moe = moeSimpleTrain(moe, Target, idx_label) ;  
            save(fn_full, 'moe');
            clear moe;
        end
        fprintf('The bad moe num is %d\n',badMoENum);
        disp(badmoeIndex);
     %------------------------------------end while iterate------------------------------------------------------------
     iter_total = iter_total+1;
    end %end while 
end