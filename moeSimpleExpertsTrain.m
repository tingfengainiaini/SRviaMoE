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
        
        if (moeModel.Experts.UseTol == 0)%��ʹ��TolЭ�������
            WeightTarget = repmat(GatingPosterior(Index,:).^0.5,1,size(Target,2)).*Target(Index,:);
            %û���������ʵ��
              %hessianHidden = EInput'*EInput;
             %ExpertWeight = hessianHidden\(EInput'*WeightTarget);

            %����EInput'*EInputû�г��Է������
             hessianHidden = EInput'*EInput + lamda*eye(size(EInput,2));

            %�������w0
            %ExpertWeight = hessianHidden\(EInput'*WeightTarget +  0*moeModel.Experts.WInit);

            %���������w0������EInput'*WeightTargetû�г��Է������
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
        else%ʹ��TolЭ�������
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