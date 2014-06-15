function SR_moeTrain_single()
    clc;
    clear all;
    folder_wang = pwd;
    kmeans_Num = 128;
    folder_mappingdata_wang = fullfile(folder_wang,sprintf('MappingData_%d',kmeans_Num));
    folder_moe_result_wang = fullfile(folder_wang,sprintf('moe_result_%d',kmeans_Num));
    
    idx_label_start = 1;
    idx_label_end = kmeans_Num;%这里需要改为4096，为了实验暂时设置为1
    cut_value = 100000;%set the value to be cutted 设置需要裁剪规模的阈值。可以稍微改的大一些。
    
    
    warning('off','MATLAB:rankDeficientMatrix');
    % fbme_arr = cell(num_files,1);
    badMoENum = 0;
    badmoeIndex = [];
    Input = [];
    Target = [];
    for idx_label = idx_label_start:idx_label_end%根据聚类的标签遍历处理
        fn_mapData = sprintf('MappingData_%d.mat',idx_label);
        fprintf('%s\n',fn_mapData);
        fn_full_mapData = fullfile(folder_mappingdata_wang,fn_mapData);
        if ~exist(fn_full_mapData,'file')
            fprintf('not exist file %s ! Please check!\n',fn_full_mapData);
            continue;
        end
        loaddata = load(fn_full_mapData);
        Input = [Input; loaddata.Input(1:20:size(loaddata.Input,1),:)];
        Target = [Target; loaddata.Target(1:20:size(loaddata.Input,1),:)];
        clear loaddata;
    end  
        %clear loaddata;
        %创建交叉验证的Test数据集,使用输入的一半
%         dim2 = size(Input,1); 
%         TestInput = Input(1:2:dim2,:);
%         TestTarget = Target(1:2:dim2,:); 
        fn_moe = 'moeRresult_single.mat';
        fn_full = fullfile(folder_moe_result_wang,fn_moe);
        
        TestInput = Input;
        TestTarget = Target;
        %fprintf('ExpertNum: %d, Input size %d, max: %f, min: %f\n', NumOfExperts, dim1, max(max(Input)), min(min(Input)));
        %% Create moe
       moe = moeSimpleCreate('NumExperts', 256 , 'MaxIt', 25, 'EType', 'linear', 'ENbf', 0.1, 'EKernel', 'linear', 'EKParam', 0.5, ...
    'GType', 'metric',  'GERelation', 'Compete', 'GNbf', 0.1, 'GBeta', 3, 'GKernel', 'linear', 'GKParam', 0.5);
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