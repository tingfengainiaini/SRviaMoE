function SR_moeTrain_ENumFlexible(kmeans_Num,Gbeta, maxIt)
    folder_wang = pwd;
    if nargin < 1
        kmeans_Num = 128;
        beta = 3;
        maxIt = 50;
    end
    
    folder_mappingdata_wang = fullfile(folder_wang,sprintf('MappingData_%d',kmeans_Num));
    folder_moe_result_wang = fullfile(folder_wang,sprintf('moe_result_ENFlexible_k%d_beta%d',kmeans_Num, Gbeta));
    
    idx_label_start = 1;
    idx_label_end = kmeans_Num;%这里需要改为4096，为了实验暂时设置为1
    cut_value = 100000;%set the value to be cutted 设置需要裁剪规模的阈值。可以稍微改的大一些。
    
    
    warning('off','MATLAB:rankDeficientMatrix');
    % fbme_arr = cell(num_files,1);
    badMoENum = 1;
    while badMoENum > 0
        %----------------------------------while iterate---------------------------------------------------------------
        badMoENum = 0;
        badmoeIndex = [];
        for idx_label = idx_label_start:idx_label_end%根据聚类的标签遍历处理
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
                else
                    if isfield(moeTest.Experts, 'Weights')
                        fprintf('skip %s\n',fn_full);
                        continue;
                    else
                        fprintf('%d moe is bad,no weights--------total %d', idx_label, badMoENum);
                        badMoENum =badMoENum+1;
                        badmoeIndex = [badmoeIndex idx_label]
                    end
                end
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
            if idx_label == 2
                fprintf('training the 2 label\n');
            end
            %if the input size > 10000, we just use the half;
            dim1 = size(Input,1);
            if (dim1 >= cut_value)
                Input = Input(1:2:dim1,:);
                Target = Target(1:2:dim1,:);    
            end

            %clear loaddata;
            %创建交叉验证的Test数据集,使用输入的一半
    %         dim2 = size(Input,1); 
    %         TestInput = Input(1:2:dim2,:);
    %         TestTarget = Target(1:2:dim2,:); 
            NumOfExperts = 10;
            if size(Input,1) == 1
                Input = [Input;Input];
                Target = [Target; Target];
            end
            if size(Input,1)> 2000
                NumOfExperts = 25;
            elseif size(Input,1)> 1600
                NumOfExperts = 20;
            elseif size(Input,1)> 1200
                NumOfExperts = 15;
            elseif size(Input,1)> 1000
                NumOfExperts = 12;
            elseif size(Input,1)> 800
                NumOfExperts = 10;
            elseif size(Input,1)> 400
                NumOfExperts = 6;
            elseif size(Input,1) > 200
                NumOfExperts = 5;
            elseif size(Input,1) > 100
                NumOfExperts = 4;
            elseif size(Input,1) > 50
                NumOfExperts = 3;
            elseif size(Input,1) > 20
                NumOfExperts = 2;
            else
                NumOfExperts = 1;
            end;
            TestInput = Input;
            TestTarget = Target;
            fprintf('ExpertNum: %d, Input size %d, max: %f, min: %f\n', NumOfExperts, dim1, max(max(Input)), min(min(Input)));
            %% Create moe
           moe = moeSimpleCreate('NumExperts', NumOfExperts , 'MaxIt', maxIt, 'EType', 'linear', 'ENbf', 0.1, 'EKernel', 'linear', 'EKParam', 0.5, ...
        'GType', 'metric',  'GERelation', 'Compete',  'GNbf', 0.1,'GBeta',Gbeta, 'GLearningRate', 0.01, 'GKernel', 'linear', 'GKParam', 0.5);
            % Input = repmat(Input,[1 2]);
            % Target = repmat(Target,[1 2]);
        %     Input = A;
        %     Target = [Target Target];
           %% 初始化BME，使用Keans
            moe = moeSimpleInit(moe, Input, Target, Target, TestInput) ; 
            %% BME的训练
            moe = moeSimpleTrain(moe, Target, TestTarget,idx_label) ;  
            save(fn_full, 'moe');
        end
        fprintf('The bad moe num is %d\n',badMoENum);
        disp(badmoeIndex);
     %------------------------------------end while iterate------------------------------------------------------------
    end
end