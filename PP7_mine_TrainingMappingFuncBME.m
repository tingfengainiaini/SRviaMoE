function TrainingMappingFuncBME()
    clear
    close all
    clc

    arr_sf = [4];
    arr_sigma = [1.6];
    cut_value = 100000;%set the value to be cutted 设置需要裁剪规模的阈值。可以稍微改的大一些。
    
    kmeans_num = 1024;

    folder_yang13 = pwd;
    folder_code = fileparts(folder_yang13);
    folder_thisproject = fileparts(folder_code);
    folder_dataset = fullfile(folder_thisproject,'Dataset');
    folder_filelist = fullfile(folder_dataset,'FileList');
    folder_feature_root = fullfile(folder_yang13,'Feature');
    %double layer Yang, the first layer
    folder_mappingdata= fullfile(folder_yang13,sprintf('MappingData_%d',kmeans_num));
    folder_position_root = fullfile(folder_yang13,'Position');
    folder_label_root_wang =  fullfile(folder_yang13,sprintf('Label_wang_%d',kmeans_num));
    folder_image = fullfile(folder_dataset,'AllFive');
    arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,'AllFive.txt'));
    
    %此处图片太多，暂且读取50分之一
    num_files = length(arr_filelist);

    sf = arr_sf(1);
    sigma = arr_sigma(1);

    folder_position = fullfile(folder_position_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
    folder_label = fullfile(folder_label_root_wang,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
    %load all raw image into memory
    %fprintf('loading preload mat\n');
    %folder_preload = fullfile(folder_dataset, 'PreloadMat');
    %fn_preloadmat = 'arr_img_hr_ui8_AllFive.mat';
    %load(fullfile(folder_preload,fn_preloadmat),'arr_img_hr_ui8');
    arr_img_hr_ui8 = cell(num_files,1);
    for idx_image = 1:num_files
        fn_raw = arr_filelist{idx_image};
        fprintf('load image %d %s\n',idx_image,fn_raw);
        img_read = imread(fullfile(folder_image,fn_raw));
        arr_img_hr_ui8{idx_image} = rgb2gray(img_read);
    end
    clear img_read

    %It takes too much memory here when scaling factor is 2, 24G memory is
    %insufficient convert to LR generate the LR image when needed
    arr_img_lr = cell(num_files,1);
    num_pre_computed_lr_image = 2000;%这里为了进行调试，修改了值。原本2000
    %生成低分辨的图像
    %预生成2000个
    for idx_image = 1:num_pre_computed_lr_image
        fn_raw = arr_filelist{idx_image};
        fprintf('convert to lr image %d %s\n',idx_image,fn_raw);
        arr_img_lr{idx_image} = F19c_GenerateLRImage_GaussianKernel(arr_img_hr_ui8{idx_image},sf,sigma);
    end
    %加载标签
    %load label
    arr_labels = cell(num_files,1);
    for idx_image = 1:num_files
        fn_raw = arr_filelist{idx_image};
        fn_short = fn_raw(1:end-4);
        fn_label = sprintf('%s_label.mat',fn_short);
        fprintf('load label %d %s\n',idx_image,fn_label);
        loaddata = load(fullfile(folder_label,fn_label),'arr_label');
        arr_labels{idx_image} = uint16(loaddata.arr_label);      %to save space
    end

    %load position
    %加载position
    arr_position = cell(num_files,1);
    for idx_image = 1:num_files
        fn_raw = arr_filelist{idx_image};
        fn_short = fn_raw(1:end-4);
        fn_position = sprintf('%s_position.mat',fn_short);
        fprintf('load position %d %s\n',idx_image,fn_position);
        loaddata = load(fullfile(folder_position,fn_position),'table_position_center');
        arr_position{idx_image} = uint16(loaddata.table_position_center);     %to save sapce
    end

    ps = 7;     %patch size
    featurelength_lr = 45;
    featurelength_hr = (3*sf)^2;
    patchtovectorindexset = [2:6 8:42 44:48];
    patchsize_half = (ps-1)/2; 

    thd_sufficient = 1000;
    idx_label_start = 1;
    idx_label_end = 1024;

    warning('off','MATLAB:rankDeficientMatrix');
    % fbme_arr = cell(num_files,1);
%     for idx_label = idx_label_start:idx_label_end%根据聚类的标签遍历处理
    for idx_label = idx_label_start:idx_label_end%根据聚类的标签遍历处理
        %check, if a label is being worked by a thread, skip to the next
        %label
        fn_save_mappingdata = sprintf('MappingData_%d.mat', idx_label);
        fn_mapfile = fullfile(folder_mappingdata,fn_save_mappingdata);
%         if ~exist(fn_full,'file')
%             fid = fopen(fn_full,'w+');
%             fclose(fid);
%             fprintf('running %s\n',fn_full);
%         elseif fn_regressor ~= 'Regressor_1.mat'
%             fprintf('skip %s\n',fn_full);
%             continue
%         end
         if ~exist(fn_mapfile,'file')
            fid = fopen(fn_mapfile,'w+');
            fclose(fid);
            fprintf('running %s\n',fn_mapfile);
         else
            fprintf('skip %s\n',fn_save_mappingdata);
            continue;
        end
        feature_accu = [];
        targetvalue_accu = [];
       
        idx_inst = 0;
        for idx_image = 1:num_files
            arr_match = arr_labels{idx_image} == idx_label;
            if nnz( arr_match) > 0
                %extract the feature from raw image
                img_hr = im2double(arr_img_hr_ui8{idx_image});
                if idx_image <= num_pre_computed_lr_image
                    img_lr = arr_img_lr{idx_image};
                else
                    img_lr = F19c_GenerateLRImage_GaussianKernel(img_hr,sf,sigma);%先前生成了2000个相应的低分辨图形
                end
                [h_lr, w_lr] = size(img_lr);
                set_match = find(arr_match);
                img_lr_large = imresize(img_lr,4);%放大到HR大小
                num_set_inst = length(set_match);
                %find the r,c by set_match;
                for idx_set_inst = 1:num_set_inst
                    r = arr_position{idx_image}(1,set_match(idx_set_inst));
                    c = arr_position{idx_image}(2,set_match(idx_set_inst));
                    r1 = r-1;
                    r2 = r+1;
                    c1 = c-1;
                    c2 = c+1;
                    rh = (r1-1)*sf+1; 
                    rh1 = r2*sf;
                    rh2 = (r-patchsize_half-1)*sf+1;
                    rh21 = (r+patchsize_half)*sf;
                    ch = (c1-1)*sf+1;
                    ch1 = c2*sf;
                    ch2 = (c-patchsize_half-1)*sf+1;
                    ch21 = (c+patchsize_half)*sf;
                    patch_lr = img_lr(r-patchsize_half:r+patchsize_half,c-patchsize_half:c+patchsize_half);
                    vector_lr_excludeedge = patch_lr(patchtovectorindexset);
    %                 vector_lr_excludeedge = img_lr_large(rh2:rh21,ch2:ch21);
                    vector_lr_excludeedge = vector_lr_excludeedge(:)';
                    vector_mean = mean(vector_lr_excludeedge);
                    idx_inst = idx_inst + 1;
                    feature_accu(idx_inst,:) = vector_lr_excludeedge - vector_mean;
                    patch_hr = img_hr(rh:rh1,ch:ch1);
                    diff_hr = patch_hr - vector_mean;
                    targetvalue_accu(idx_inst,:) = reshape(diff_hr,[featurelength_hr,1]);
                end
            end
            if idx_inst >= thd_sufficient%对于某个聚类标签的patch数量已经足够使用了。则停止。
                break   %break the idx_image loop
            end
        end
        %train the regressor
    %     A = [feature_accu ones(idx_inst,1)];
        Input = [feature_accu ones(idx_inst,1)];
        if ~isempty(Input)
    %         for j=1:featurelength_hr
    %             B = targetvalue_accu(:,j);
    %             coef = A\B;                         %I need to control here
    %             coef_matrix{j} = coef;
    %         end
            Target = targetvalue_accu(:,:);
            dim1 = size(Input,1);
            if (dim1 > cut_value) && (dim1 < 2*cut_value)
                Input = Input(1:2:dim1,:);
                Target = Target(1:2:dim1,:);
            elseif dim1 >= 2*cut_value
                Input = Input(1:2:2*cut_value,:);
                Target = Target(1:2:2*cut_value,:);
            end
            save(fullfile(folder_mappingdata,fn_save_mappingdata), 'Input','Target');
            %此处也可以在此直接开始运算。我选择先将数据保存下来。
            %FBME_Train(Input, Target);

    %     else
    %         %it is possible that the k-mean method generates 4097 cluster centers
    %         for j=1:featurelength_hr
    %             coef_matrix{j} = zeros(featurelength_lr+1,1);
    %         end
        end
        %save this regressor
    %     num_inst = idx_inst;
    %     save(fullfile(folder_regressor,fn_regressor),'coef_matrix','num_inst');
    %     fn_save = sprintf('num_inst_%d.mat',idx_label);
    %     save(fullfile(folder_num_inst,fn_save),'num_inst');
    end
end

