%function img_hr = F1_GenerateImageYang13(img_y, sf, clustercenter, coef_matrix)
    
%there is no matlabpool in R2013b?
%     if matlabpool('size') == 0
%         matlabpool open local 4
%     end

    patchsize_hr = 3*sf;
    num_predictedpixel = (patchsize_hr)^2;
    num_pixel_hr = num_predictedpixel;
    num_cluster = size(clustercenter,2);

    [h_lr, w_lr] = size(img_y);
    %predict the hr image by learned regressor
    patchsize = 7;
    halfpatchsize = (patchsize - 1) /2;
    %extend 3 pixels to pretend the ambiguity of the margin
    img_y_ext = wextend('2d','symw',img_y,halfpatchsize);       %3 pixels are extended
    arr_clusteridx = zeros(h_lr*w_lr,1);
    grad_img_y_ext = F14c_Img2Grad_fast_suppressboundary(img_y_ext);
    patchtovectorindexset = [2:6 8:42 44:48];
    
    arr_smoothpatch = false(h_lr*w_lr,1);
    %将低分辨图像扩大四倍
    img_y_ext_bb = imresize(img_y_ext,sf);
    [h_hr_ext, w_hr_ext] = size(img_y_ext_bb);
    img_hr_ext_sum = zeros(h_hr_ext,w_hr_ext);
    img_hr_ext_count = zeros(h_hr_ext,w_hr_ext);
    
    intensity_hr = zeros(num_pixel_hr,h_lr*w_lr);
    for idx=1:h_lr*w_lr         %this is prepare for parallel computing
    %parfor idx=1:h_lr*w_lr
        r = mod(idx-1,h_lr)+1;      %the (r,c) is the top-left of a patch
        c = ceil(idx/h_lr);
        r1 = r+patchsize-1;
        c1 = c+patchsize-1;
        %label the smooth region
        patch_lr_grad = grad_img_y_ext(r+1:r1-1,c+1:c1-1,:);  %this check can be further reduced
        smooth_grad = abs(patch_lr_grad) <= 0.05;       
        if sum(smooth_grad(:)) == 200
            arr_smoothpatch(idx) = true;
            %完全平滑，那么不进行处理，直接用插值的结果进行填充，减少计算量
            fprintf('%d --- %d,is smooth\n',idx,h_lr*w_lr);
        else
            patch_lr = img_y_ext(r:r1,c:c1);
            vector_lr = patch_lr(patchtovectorindexset);
            patch_lr_mean = mean(vector_lr);
            feature = vector_lr' - patch_lr_mean;   %use column vector
            %determine the cluster index
            diff = repmat(feature,[1 num_cluster]) - clustercenter;     %it takes time here, try to use ANN to reduce the computational load
            l2normsquare = sum((diff.^2));
            [~,clusteridx] = min(l2normsquare);
            fprintf('running the %d --- %d --- %d\n',idx,h_lr*w_lr, clusteridx);
%             if ~exist(fullfile(folder_bme_result,sprintf('BmeReslut_%d.mat',clusteridx)),'file')
%                 arr_smoothpatch(idx) = true;
%                 continue;
%             else
%                 d = dir(strcat(folder_bme_result,'\',sprintf('BmeReslut_%d.mat',clusteridx)));
%                 while d.bytes/1024 < 9200
%                     fprintf('----the %d is bad\n',clusteridx);
%                     clusteridx = clusteridx +1;
%                     d = dir(strcat(folder_bme_result,'\',sprintf('BmeReslut_%d.mat',clusteridx)));
%                 end
%             end

            arr_clusteridx(idx) = clusteridx;
            Input = [feature;1]';
            
            %%Get the hr image use the moe
            fn_save_mappingdata = sprintf('MappingData_%d.mat', clusteridx);
            %file_mapfile = fullfile(folder_mappingdata,fn_save_mappingdata);
            file_mapfile = fullfile(folder_mappingdata,fn_save_mappingdata);
            fn_moe = sprintf('moeRresult_%d.mat',clusteridx);
            %file_bmeResult = fullfile(folder_bme_result,fn_bme);
            file_moeResult = fullfile(folder_moe_result,fn_moe);
            
            if (~exist(file_moeResult,'file'))
                fprintf('When %d, file missed ! Check !!!-----%s\n',idx, file_moeResult);
                pause;
            else
                
                loaddata = load(file_moeResult);
                moe = loaddata.moe;
                clear loaddata
                
                if ~isfield(moe.Experts,'Weights')
                    fprintf('When %d, moe %s weights not exists!',clusteridx, file_moeResult);
                    pause;
                end
                %If there exists kernel 
                if ( (~strcmpi(moe.Experts.Kernel , 'linear')) || (~strcmpi(moe.Gatings.Kernel , 'linear')) )
                    if (~exist(file_mapfile,'file'))
                        fprintf('When %d, file missed ! Check !!!-----%s\n',idx, file_mapfile);
                        pause;
                    else
                        loaddata = load(file_mapfile);
                        moeInput = loaddata.Input;
                        moeTarget = loaddata.Target;
                        clear loaddata
                    end
                end
                
                if strcmpi(moe.Experts.Kernel, 'linear')
                    %EInput = [ones(size(Input,1),1) Input];
                    EInput = Input;
                else
                    K = kernelValue(Input, moeInput, moe.Experts.Kernel, moe.Experts.KParam);
                    EInput = [ones(size(K,1),1) K];
                    clear K;
                end
                
                if strcmpi(moe.Gatings.Kernel, 'linear')
                    %GInput = [ones(size(Input,1),1) Input];
                   if strcmpi(moe.Gatings.Type, 'metric')
                        GInput = Input;
                   elseif strcmpi(moe.Gatings.Type, 'mlr')
                        GInput = [ones(size(Input,1),1) Input];
                   end  
                else
                    K = kernelValue(Input, moeInput, moe.Gatings.Kernel, moe.Gatings.KParam);
                    GInput = [ones(size(K,1),1) K];
                    clear K;
                end
                
                if size(EInput,2) ~= size(moe.Experts.Weights,1)
                     arr_smoothpatch(idx) = true;
                     fprintf('size(EInput,2) not equal to moe.Experts.Weights,1\n');
                     pause;
                     break;
                end
                ExpertsMeans = moeExpertsMeans(EInput, moe);
                
                GatingsOutputs = zeros(size(GInput,1),size(moe.Gatings.Weights,2));
                if (strcmpi(moe.Gatings.Type,'metric'))
                    for i = 1:moe.NumExperts 
                        if (moe.Gatings.UseMetric == 1)
                             GatingsOutputs(:,i) = exp(-moe.Gatings.Beta*sum(...
                                 (GInput-repmat(moe.Gatings.Weights(:,i),1,size(GInput,1))')*moe.Gatings.Metric...
                                 *(GInput-repmat(moe.Gatings.Weights(:,i),1,size(GInput,1))')'  ,2));
                        else
                            GatingsOutputs(:,i) = exp(-moe.Gatings.Beta*sum((GInput-repmat(moe.Gatings.Weights(:,i),1,size(GInput,1))').^2,2));
                        end
                         %GatingsOutputs(:,i) = exp(-moe.Gatings.Beta*sum((GInput-repmat(moe.Gatings.Weights(:,i),1,size(GInput,1))').^2,2));
                    end
                else
                    GatingsOutputs = exp(GInput*moe.Gatings.Weights);
                end
                
                %GatingsOutputs = exp(GInput * moe.Gatings.Weights);
                
                SumGatingsOutput = sum(GatingsOutputs, 2);
                GatingsOutputsNorm = GatingsOutputs./repmat(SumGatingsOutput, 1, size(GatingsOutputs, 2));
%                 if length(size(moe.Experts.Weights)) ~= 2
%                      GatingsOutputsNorm = repmat(GatingsOutputsNorm, size(moe.Experts.Weights,2), 1);
%                      GatingsOutputsNorm2 = zeros(1, size(GatingsOutputsNorm,1), size(GatingsOutputsNorm,2)); 
%                      OutputsTargetTemp = ExpertsMeans.*GatingsOutputsNorm2;
%                 else
%                      OutputsTargetTemp = ExpertsMeans.*GatingsOutputNorm;
%                 end
                
                %figure the best experts output
                [values, index] = sort(GatingsOutputsNorm, 2, 'descend');
                feature_hr = zeros(size(ExpertsMeans,1),size(ExpertsMeans,2));
                
                %Judge the Gatings.ERelation
                %feature_hr = ExpertsMeans(:,:,index(1,1));
                if strcmpi(ERelation,'Compete')
                    feature_hr = ExpertsMeans(:,:,index(1,1));
                elseif strcmpi(ERelation,'Coorperate')
                      feature_hr = reshape(ExpertsMeans(:,:,:),size(ExpertsMeans,2),size(ExpertsMeans,3))*GatingsOutputsNorm';
                end
                intensity_hr_this = feature_hr' + patch_lr_mean;
                intensity_hr(:,idx) = intensity_hr_this;
            end
        end
    end
    intensity_hr(intensity_hr>1) = 1;
    intensity_hr(intensity_hr<0) = 0;
    
    %reconstruct hr image from predicted image
    dist = 2 * sf;      %the algorithm only recover the central (3*sf) *(3*sf) in HR, so there is a dist in HR
    for idx=1:h_lr*w_lr
        r = mod(idx-1,h_lr)+1;      %the (r,c) is the top-left of a patch
        c = ceil(idx/h_lr);

        ch = (c-1)*sf +1 + dist;
        ch1 = ch + patchsize_hr -1;
        rh = (r-1)*sf+1 + dist;
        rh1 = rh+patchsize_hr-1;
        if arr_smoothpatch(idx)
            img_hr_ext_sum(rh:rh1,ch:ch1) = img_hr_ext_sum(rh:rh1,ch:ch1) + img_y_ext_bb(rh:rh1,ch:ch1);
        else
            img_hr_ext_sum(rh:rh1,ch:ch1) = img_hr_ext_sum(rh:rh1,ch:ch1) + reshape(intensity_hr(:,idx),[patchsize_hr, patchsize_hr]);
        end
        img_hr_ext_count(rh:rh1,ch:ch1) = img_hr_ext_count(rh:rh1,ch:ch1) + 1;
    end
    
    img_hr_ext_avg = img_hr_ext_sum ./ img_hr_ext_count;
    extended_boundary_hr = halfpatchsize * sf;
    img_hr = img_hr_ext_avg(extended_boundary_hr+1:end-extended_boundary_hr,extended_boundary_hr+1:end-extended_boundary_hr);
%end