function moeModel = moeSimpleExpertsTrain(Target, moeModel, i)
GatingPosterior = moeModel.Gatings.Posteriors(:,i);
MinPosterior = 0.01;
switch lower(moeModel.Experts.Type)
    case 'linear'
        %Reduce the computational load by reducing the GatingPosterior < MinPosterior
        Index = find(GatingPosterior > MinPosterior);
        EInput = ((GatingPosterior(Index,1).^0.5)*ones(1,size(moeModel.Experts.Input,2))) .* moeModel.Experts.Input(Index,:) ; 
        WeightTarget = repmat(GatingPosterior(Index,:).^0.5,1,size(Target,2)).*Target(Index,:);
        %没有正则化项的实现
          %hessianHidden = EInput'*EInput +  moeModel.Experts.Lamda*eye(size(EInput,2));
         %ExpertWeight = hessianHidden\(EInput'*WeightTarget);

        %这里EInput'*EInput没有乘以方差矩阵
         hessianHidden = EInput'*EInput + moeModel.Experts.Lamda*eye(size(EInput,2));
        
        %正则化项不加w0
          ExpertWeight = hessianHidden\(EInput'*WeightTarget + 0*moeModel.Experts.WInit);
        
        %正则化项加着w0，这里EInput'*WeightTarget没有乘以方差矩阵
        %ExpertWeight = hessianHidden\(EInput'*WeightTarget + moeModel.Experts.Lamda*moeModel.Experts.WInit);
        if size(Target,2) == 1
%             InitBeta = 1./BME.Experts.Variances(i);
%             hessianHidden = EInput'*EInput*InitBeta + moeModel.Experts.Lamda*eye(size(EInput,2));
%             ExpertWeight = hessianHidden\(EInput'*WeightTarget*InitBeta + moeModel.Experts.Lamda*moeModel.Experts.WInit);
            moeModel.Experts.Weights(:,i) = ExpertWeight;
        else
            moeModel.Experts.Weights(:,:,i) = ExpertWeight;
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
    case 'rvm'
        if strcmpi(moeModel.Experts.Kernel, 'linear')
            ED = size(moeModel.Experts.Input,2);
            EInput = ((GatingPosterior.^0.5)*ones(1,size(moeModel.Experts.Input,2))) .* moeModel.Experts.Input; 
            WeightTarget = (GatingPosterior.^0.5).*Target ;
            MaxIt = 200;
            InitAlpha = moeModel.Experts.Alpha;
            InitBeta = 1./moeModel.Experts.Variances(i);
            [ExpertWeight, Used, Beta] = RVMRegressor(EInput, WeightTarget, InitAlpha*ones(ED,1), InitBeta, MaxIt);
            moeModel.Experts.Weights(:,i) = ExpertWeight;
            moeModel.Experts.Used{i} = Used;
            moeModel.Experts.Beta(1,i) = Beta;
        else
            Threshold = 1/moeModel.NumExperts/3;
            Index = find(GatingPosterior > Threshold);
            Index = [1; Index+1];
            EInput = moeModel.Experts.Input(:,Index);
            EInput = ((GatingPosterior.^0.5)*ones(1,size(EInput,2))) .* EInput; 
            WeightTarget = (GatingPosterior.^0.5).*Target;
            MaxIt = 200;
            InitAlpha = moeModel.Experts.Alpha;
            InitBeta = 1./moeModel.Experts.Variances(i);
            [ExpertWeight, Used, Beta] = RVMRegressor(EInput, WeightTarget, InitAlpha*ones(length(Index),1), InitBeta, MaxIt);
            Used = Index(Used);
            moeModel.Experts.Weights(Index,i) = ExpertWeight;
            moeModel.Experts.Used{i} = Used;
            moeModel.Experts.Beta(1,i) = Beta;
        end
    otherwise
        disp('Unknown method.')
end