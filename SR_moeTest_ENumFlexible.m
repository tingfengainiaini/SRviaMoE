function SR_moeTest_ENumFlexible(kmeans_Num, beta)
    %test code 
    %the pic used just as Yang
    %
    folder_test = 'Test1_1';
    str_appendix = date;
    str_method = 'wang14MoE';
    folder_yang13 = pwd;
    
    if (nargin < 1)
        kmeans_Num = 128;
        beta = 3;
    end

    % folder_code = fileparts(folder_yang13);
    %folder_project = fileparts(folder_code);
    folder_project = folder_yang13;
    folder_lib = fullfile(folder_project,'Lib');
    addpath(genpath(folder_lib));
    folder_dataset = fullfile(folder_project,'Dataset');
    folder_cluster_root =  fullfile(folder_yang13,'Cluster');

    folder_moe_result = fullfile(folder_yang13, sprintf('moe_result_ENFlexible_k%d_beta%d',kmeans_Num,beta));
    folder_mappingdata = fullfile(folder_yang13, sprintf('MappingData_%d',kmeans_Num));

    %load filelist
    folder_filenamelist = fullfile(folder_dataset,'FileList');

    arr_sf =    [4];
    arr_sigma = [1.6];
    num_dataset = 2;
    num_setting = length(arr_sf);
    num_sigma = length(arr_sigma);
    if num_setting ~= num_sigma
        error('num_sf should equal num_sigma');
    end

    %load the dictionary for all setting, but is this fair? If we know the
    %simga is different, the dicionary should be training differently, right?
    %Right, the dictionary matters.
    for idx_dataset = 2:num_dataset
        if idx_dataset == 1
            fn_filenamelist = 'BSD200.txt';
            subfolder_dataset = 'BSD200_Input';
            subfolder_groundTruth = 'BSD200_GroundTruth';
            file_input = {'barbara_gnd.bmp'; 'Child_gnd.bmp';'Lena_gnd.bmp'};
            name_dataset = 'BSD200';
        elseif idx_dataset == 2
            fn_filenamelist = 'Benchmark.txt';
            subfolder_dataset = 'Benchmark_Input';
            subfolder_groundTruth = 'Benchmark_GroundTruth';
            %Here, the file_input truth file is wrong infered.
            file_input = {'barbara_gnd.bmp'; 'Child_gnd.bmp';'Lena_gnd.bmp'};
            name_dataset = 'Benchmark';
        end
        list_filename = U5_ReadFileNameList(fullfile(folder_filenamelist,fn_filenamelist));
        num_file = length(list_filename);

        for idx_setting = 1:num_setting
            sf = arr_sf(idx_setting);
            foldername_sf = sprintf('sf%d',sf);
            sigma = arr_sigma(idx_setting);
            foldername_sigma = sprintf('sigma%0.1f',sigma);
            %load cluster center and coef_matrix
            %folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
            folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));

            fn_clustercenter = sprintf('ClusterCenter_sf%d_sigma%.1f_%dClusters.mat',sf,sigma,kmeans_Num);
            loaddata = load(fullfile(folder_cluster, fn_clustercenter),'clustercenter');
            clustercenter = loaddata.clustercenter';        %transpose, to make each feature as a column

            folder_truth = fullfile(folder_dataset,subfolder_groundTruth);
            folder_source = fullfile(folder_dataset,subfolder_dataset,foldername_sf,foldername_sigma);
            folder_write = fullfile(folder_test,name_dataset,foldername_sf,foldername_sigma);
            if ~exist(folder_write,'dir')
                U22_makeifnotexist(folder_write);
                fprintf('create %s\n', folder_write);
            end
            %write the evaluation results to a txt file.
            fn_write_result = sprintf('%s_%s_%s_moreExperts_beta%d_%d_moe.txt',name_dataset,str_method,str_appendix,beta, kmeans_Num);

            %fn_full_result = fullfile(folder_write,fn_write_result); 
    %         fid = fopen(fn_full_result,'a');
    %         fclose(fid);
            fn_write_list = cell(num_file,1);
            fn_write_num = 0;
            for idx_file = 1:num_file
                fn_name = list_filename{idx_file};
                fn_short = fn_name(1:end-4);
                %fn_write = sprintf('%s_%s%s.png',fn_short,str_method,str_appendix);
                fn_write = sprintf('%s_%s_%s_moreExperts_right_beta%d_%d_moe.png',fn_short,str_method,str_appendix,beta,kmeans_Num);
                fn_full = fullfile(folder_write,fn_write);


                if ~strcmpi(fn_short,'IC')
                    fn_write_num = fn_write_num+1;
                    fn_write_list{fn_write_num} = fn_write;
                end

                %fn_write_list{idx_file} = fn_write;
                if exist(fn_full,'file')
                    fprintf('skip %s\n', fn_full);
                    fid = fopen(fn_full,'a');
                    fclose(fid);
                    continue
                else
                    %create an empty file
                    fid = fopen(fn_full,'w+');
                    fclose(fid);

                    fn_read = fn_name;
                    fprintf('running %s\n',fn_full);
                    img_rgb = im2double(imread(fullfile(folder_source,fn_read)));
                    if size(img_rgb,3) == 3
                        img_yiq = RGB2YIQ(img_rgb);
                        img_y = img_yiq(:,:,1);
                        img_iq = img_yiq(:,:,2:3);
                        SR_moe_GenerateHRImage
                        img_yiq_hr = img_hr;
                        img_yiq_hr(:,:,2:3) = imresize(img_iq,sf);
                        img_rgb_hr = YIQ2RGB(img_yiq_hr);
                        imwrite(img_rgb_hr,fn_full);
                    else
                        img_y = img_rgb;
                        SR_moe_GenerateHRImage
                        imwrite(img_hr,fn_full);
                    end % if size(img_rgb,3) == 3
                end %if exist(fn_full,'file')

            end % for idx_file = 1:num_file   
            %evaluate the result images
            SR_ImageEvaluate(folder_write,fn_write_list,folder_truth,file_input,fn_write_result);
        end        
    end
end
