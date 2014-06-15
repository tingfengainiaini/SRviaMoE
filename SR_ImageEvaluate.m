function SR_ImageEvaluate( folder_write, file_write,  folder_truth,  file_input, fn_write_result)
    %SR_IMAGEEVALUATE Summary of this function goes here
    %   Detailed explanation goes here

    %%Image quality assessment
    %mse¡¢psnr¡¢ssim¡¢qssim
    %------------------------------------------------------------------------
    fn_full_result = fullfile(folder_write,fn_write_result); 
    fid = fopen(fn_full_result,'a');
    fclose(fid);
    for img_idx_rows = 1 :size(file_input,1)
        file_input_truth = fullfile(folder_truth,file_input{img_idx_rows,1});
        if ~exist(file_input_truth,'file')
             fprintf('Truth file %s not exists !\n',file_input_truth);   
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
                fprintf('Result file %s not exist!', file_write_res);
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
            [mssim, ~] = ssim_index(img_input_truth , img_write_res );
            if size(img_input_truth_rgb,3) == 3
                [qmssim, ~] = qssim(img_input_truth_rgb , img_write_res_rgb );
            else
                qmssim = mssim;
            end
            bme_rmse = compute_rmse(img_input_truth, img_write_res);
            img_psnr = 20*log10(255/bme_rmse);

            disp([num2str((img_idx_rows-1)*size(file_write,2)+img_idx_cols),'file: ',file_write_res, '   mssim: ',num2str(mssim), '   qmssim: ',num2str(qmssim), '   rmse: ',num2str(bme_rmse), '   psnr: ',num2str(img_psnr)]);
            str_out = sprintf('%d file: %s\t mssim: %f\t qmssim: %f\t rmse: %f\t psnr: %f\t\r\n',((img_idx_rows-1)*size(file_write,2)+img_idx_cols), file_write_res, mssim, qmssim, bme_rmse, img_psnr);
            
            fid = fopen(fn_full_result,'a');
            fprintf(fid, '%s', str_out);
            fclose(fid);
        end
        fprintf('\n');
    end

end

