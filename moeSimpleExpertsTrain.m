function moeModel = moeSimpleExpertsTrain(Target, moeModel, i)
GatingPosterior = moeModel.Gatings.Posteriors(:,i);
MinPosterior = 0.005;

switch lower(moeModel.Experts.Type)
    case 'linear'
        %Reduce the computational load by reducing the GatingPosterior <
        %MinPosterior*0.5
        Index = find(GatingPosterior >= MinPosterior/10);
        moeModel.Experts.lamdaSpecial(i) =  moeModel.Experts.lamda/log(size(Index,1));
        lamda = moeModel.Experts.lamdaSpecial(i);
        %Index = 1:size(GatingPosterior,1);
        EInput = ((GatingPosterior(Index,1).^0.5)*ones(1,size(moeModel.Experts.Input,2))) .* moeModel.Experts.Input(Index,:) ; 
        
        if (moeModel.Experts.UseTol == 0)%不使用Tol协方差矩阵
            WeightTarget = repmat(GatingPosterior(Index,:).^0.5,1,size(Target,2)).*Target(Index,:);
            %没有正则化项的实现
              %hessianHidden = EInput'*EInput;
             %ExpertWeight = hessianHidden\(EInput'*WeightTarget);

            %这里EInput'*EInput没有乘以方差矩阵
             hessianHidden = EInput'*EInput + lamda*eye(size(EInput,2));

            %正则化项不加w0
            %ExpertWeight = hessianHidden\(EInput'*WeightTarget +  0*moeModel.Experts.WInit);

            %正则化项加着w0，这里EInput'*WeightTarget没有乘以方差矩阵
            if det(hessianHidden) < 1e-100
                ExpertWeight = EInput\WeightTarget;
            else
                ExpertWeight = hessianHidden\(EInput'*WeightTarget + lamda*moeModel.Experts.UseW_0*moeModel.Experts.WInit);
            end
            
            if sum(sum(sum(isnan(ExpertWeight)))) > 0
                ExpertWeight = moeModel.Experts.WInit;
            end
            
            if size(Target,2) == 1
                moeModel.Experts.Weights(:,i) = ExpertWeight;
            else
                moeModel.Experts.Weights(:,:,i) = ExpertWeight;
            end
        else%使用Tol协方差矩阵
            if size(Target,2) == 1
                WeightTarget = (GatingPosterior(Index,:).^0.5).*Target(Index);
                InitBeta = 1./moeModel.Experts.Variances(i);
                hessianHidden = EInput'*EInput*InitBeta + lamda*eye(size(EInput,2));
                ExpertWeight = hessianHidden\(EInput'*WeightTarget*InitBeta + lamda*moeModel.Experts.UseW_0*moeModel.Experts.WInit);
                moeModel.Experts.Weights(:,i) = ExpertWeight;
            else
                for j = 1:size(Target,2)
                    WeightTarget = (GatingPosterior(Index,:).^0.5).*Target(Index,j);
                    InitBeta = 1./moeModel.Experts.Variances(j,i);
                    hessianHidden = EInput'*EInput*InitBeta + lamda*eye(size(EInput,2));
                    ExpertWeight = hessianHidden\(EInput'*WeightTarget*InitBeta + lamda*moeModel.Experts.UseW_0*moeModel.Experts.WInit(:,j)); 
                    moeModel.Experts.Weights(:,j,i) = ExpertWeight;
                end
            end
        end
    case 'rr'     
        EInput = ((GatingPosterior.^0.5)*ones(1,size(moeModel.Experts.Input,2))) .* moeModel.Experts.Input ; 
        WeightTarget = repmat(GatingPosterior.^0.5,1,size(Target,2)).*Target ;
        Hessian  = EInput'*EInput + moeModel.Experts.Alpha*eye(size(EInput,2));
        ExpertWeight = Hessian\(EInput'*WeightTarget);
        if size(Target,2) == 1
            moeModel.Experts.Weights(:,i) = ExpertWeight;
        else
            moeModel.Experts.Weights(:,:,i) = ExpertWeight;
        end 
    otherwise
        disp('Unknown method.')
end