%%Image quality assessment
%mse¡¢psnr¡¢ssim¡¢qssim
%------------------------------------------------------------------------
clc
clear
close all
folder_test = 'Test1_1';
str_appendix = '1_1';
str_method = 'Wang13';
folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_project = fileparts(folder_code);
folder_dataset = fullfile(folder_project,'Dataset');
folder_cluster_root =  fullfile(folder_yang13,'Cluster');
folder_lib = fullfile(folder_project,'Lib');
addpath(genpath(folder_lib));
folder_coef_root =   fullfile(folder_yang13,'Coef');
folder_bme_result = fullfile(folder_yang13, 'BME_Result_64');
folder_bme_result_wang = fullfile(folder_yang13, 'BME_Result_wang');
folder_mappingdata = fullfile(folder_yang13, 'MappingData');
folder_mappingdata_wang = fullfile(folder_yang13, 'MappingData_64');

arr_sf =    [4];
arr_sigma = [1.6];
subfolder_dataset = 'Benchmark_Input';
subfolder_groundTruth = 'Benchmark_GroundTruth';
name_dataset = 'Benchmark';

sf = arr_sf(1);
foldername_sf = sprintf('sf%d',sf);
sigma = arr_sigma(1);
foldername_sigma = sprintf('sigma%0.1f',sigma);

folder_source = fullfile(folder_dataset,subfolder_dataset,foldername_sf,foldername_sigma);
folder_write = fullfile(folder_test,name_dataset,foldername_sf,foldername_sigma);
folder_truth = fullfile(folder_dataset,subfolder_groundTruth);

file_input = {'barbara_gnd.bmp'; 'Child_gnd.bmp';'Lena_gnd.bmp'};
file_write = {'Barbara_Wang131_1.png' 'Barbara_Wang131_1_32_nocut.png' 'Barbara_Wang131_1_64_nocut.png' 'Barbara_Wang131_1_64_nocut_right.png' 'Barbara_Wang131_1_256_nocut.png' 'Barbara_Wang131_1_128_nocut.png' 'Barbara_Wang131_1_128Cluster_secondTrain.png' 'Barbara_Wang131_1_Yang128Cluster.png' 'Barbara_Yang131_1.png';
     'Child_Wang131_1.png' 'Child_Wang131_1_32_nocut.png' 'Child_Wang131_1_64_nocut.png' 'Child_Wang131_1_64_nocut_right.png' 'Child_Wang131_1_256_nocut.png' 'Child_Wang131_1_128_nocut.png' 'Child_Wang131_1_128Cluster_secondTrain.png' 'Child_Wang131_1_Yang128Cluster.png' 'Child_Yang131_1.png';
     'Lena_Wang131_1.png' 'Lena_Wang131_1_32_nocut.png' 'Lena_Wang131_1_64_nocut.png' 'Lena_Wang131_1_64_nocut_right.png' 'Lena_Wang131_1_256_nocut.png' 'Lena_Wang131_1_128_nocut.png' 'Lena_Wang131_1_128Cluster_secondTrain.png' 'Lena_Wang131_1_Yang128Cluster.png' 'Lena_Yang131_1.png'};
 
ssim_value = zeros(size(file_write));
for img_idx_rows = 1 :size(file_write,1)
    file_input_truth = fullfile(folder_truth,file_input{img_idx_rows,1});
    if ~exist(file_input_truth,'file')
         fprintf('Input file %s not exists !',file_input_truth);   
         continue;
    end
    img_input_truth_rgb = imread(file_input_truth);
    if size(img_input_truth_rgb,3) == 3
%         img_yiq = RGB2YIQ(img_rgb);
%         img_y = img_yiq(:,:,1);
%         img_iq = img_yiq(:,:,2:3);
        img_input_truth = rgb2gray(img_input_truth_rgb);
    else
        img_input_truth = img_input_truth_rgb;
    end
    mssim = zeros();
    for img_idx_cols = 1:size(file_write, 2)
        file_write_res = fullfile(folder_write, file_write{img_idx_rows,img_idx_cols});
        if ~exist(file_write_res,'file')
            fprintf('Our result file %s not exist!', file_write_res);
            continue;
        end
        img_write_res_rgb = imread(file_write_res);
        if size(img_input_truth_rgb,3) == 3
    %         img_yiq = RGB2YIQ(img_rgb);
    %         img_y = img_yiq(:,:,1);
    %         img_iq = img_yiq(:,:,2:3);
            img_write_res = rgb2gray(img_write_res_rgb);
        else
            img_write_res = img_write_res_rgb;
            %img_input_truth_rgb
        end
        [mssim, ssim_map] = ssim_index(img_input_truth , img_write_res );
        if size(img_input_truth_rgb,3) == 3
            [qmssim, qssim_map] = qssim(img_input_truth_rgb , img_write_res_rgb );
        else
            qmssim = mssim;
        end
        bme_rmse = compute_rmse(img_input_truth, img_write_res);
        img_psnr = 20*log10(255/bme_rmse);
        
        disp([num2str((img_idx_rows-1)*size(file_write,2)+img_idx_cols),'file: ',file_write_res, '   mssim: ',num2str(mssim), '   qmssim: ',num2str(qmssim), '   rmse: ',num2str(bme_rmse), '   psnr: ',num2str(img_psnr)]);
    end
     fprintf('\n');
end





