%Chih-Yuan Yang
%10/11/13
%For PP13a_PC14
function [feature, table_position_center] = F2_GenerateFeatureFromHRImage( img_hr_raw, sf, sigma)
    patch_to_vector_exclude_corner = [2:6 8:42 44:48];
    thd = 0.05;
    num_smoothgradient = 200;
    featurelength_lr = 45;

    patchsize = 7;
    patchsize_half = (patchsize-1)/2;
    img_lr = F19c_GenerateLRImage_GaussianKernel(img_hr_raw,sf,sigma);
    [h, w] = size(img_lr);
    grad_lr = F14c_Img2Grad_fast_suppressboundary(img_lr);
    idx = 0;
    num_patch_in_an_image = (h-patchsize+1)*(w-patchsize+1);
    feature = zeros(featurelength_lr,num_patch_in_an_image);
    table_position_center = zeros(2,num_patch_in_an_image);      %r,c
    for r=patchsize_half+1:h-patchsize_half
        for c=patchsize_half+1:w-patchsize_half
            patch_grad_lr = grad_lr(r-2:r+2,c-2:c+2,:);     %2 for detecting smooth region
            num_underthd = nnz(abs(patch_grad_lr) <= thd);
            %neglect smooth patch
            if num_underthd < num_smoothgradient
                idx = idx + 1;
                table_position_center(:,idx) = [r;c];
                patch_lr = img_lr(r-patchsize_half:r+patchsize_half,c-patchsize_half:c+patchsize_half);
                vector_lr_exclude_corner = patch_lr(patch_to_vector_exclude_corner);
                vector_mean = mean(vector_lr_exclude_corner);
                feature(:,idx) = vector_lr_exclude_corner - vector_mean;
            end
        end
    end
    feature = feature(:,1:idx);
    table_position_center = table_position_center(:,1:idx);
end

