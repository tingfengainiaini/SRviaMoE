function moeModel = moeSimpleGatingsTrain(moeModel, i)
MinWeightChange = 1e-4;
MaxIt = 50;%inner iteration
MinPosterior = 0.01;
%learning rate
learningRate = moeModel.Gatings.LearningRate;
decay = 0.9;
GatingPosterior = moeModel.Gatings.Posteriors(:,i);
GatingWeight = moeModel.Gatings.Weights(:,i);
SumOtherGatingsOutputs = sum(moeModel.Gatings.Outputs,2) - moeModel.Gatings.Outputs(:,i)+eps;

if (moeModel.Gatings.UseMetric == 1)
    M = moeModel.Gatings.Metric;
end

switch lower(moeModel.Gatings.Type)
    case 'metric'
        % compute the most probable weights by bound optimization
        GD = size(moeModel.Gatings.Input,2);
        N = size(moeModel.Gatings.Input,1);
        count = 0;
        while (count < MaxIt)
            count = count + 1;
            if (moeModel.Gatings.UseMetric == 1)
                GatingOutput =  exp(-moeModel.Gatings.Beta*sum( ...
                    (moeModel.Gatings.Input-repmat(GatingWeight,1,N)') *M* ...
                    (moeModel.Gatings.Input-repmat(GatingWeight,1,N)')',    2));
            else
                GatingOutput =  exp(-moeModel.Gatings.Beta*sum(power(moeModel.Gatings.Input-repmat(GatingWeight,1,N)',2),2));
            end
            %GatingOutpurNorm = GatingOutput./(SumOtherGatingsOutputs + GatingOutput);
            SumOtherGatingsOutputs = SumOtherGatingsOutputs + MinPosterior;
            GatingOutput = GatingOutput + MinPosterior;
            %SumOtherGatingsOutputs = SumOtherGatingsOutputs./(SumOtherGatingsOutputs + GatingOutput);
            %GatingOutput = GatingOutput./(SumOtherGatingsOutputs + GatingOutput);
            Grad_hg = (GatingOutput./(SumOtherGatingsOutputs + GatingOutput) - GatingPosterior);
            if sum(isnan(Grad_hg)) >0
                Grad_hg = Grad_hg + eps;
                if sum(isnan(Grad_hg)) >0
                    fprintf('Grad_hg inludes nan\n');
                    break;
                end
            end
            
            if (moeModel.Gatings.UseMetric == 1)
                Grad = moeModel.Gatings.Beta*M*(moeModel.Gatings.Input-repmat(GatingWeight,1,N)')'*Grad_hg;
            else
                Grad = moeModel.Gatings.Beta*(moeModel.Gatings.Input-repmat(GatingWeight,1,N)')'*Grad_hg;
            end
            
            if (sum(sum(isnan(Grad)))>0)
                %moeModel.Gatings.Posteriors  = moeModel.Gatings.Posteriors + MinPosterior;
                Grad(isnan(Grad)) = eps;
                if (sum(sum(isnan(Grad)))>0)        
                    fprintf('Grad is nan.\n');
                end
            end
            %Grad = (moeModel.Gatings.Input-repmat(GatingWeight,1,N)')'*Grad;
            %hessian = (moeModel.Gatings.Input-repmat(GatingWeight,1,N)')'*(GatingOutpurNorm*(1-GatingOutpurNorm)')*(moeModel.Gatings.Input-repmat(GatingWeight,1,N)');
            %hessian = (moeModel.Gatings.Input-repmat(GatingWeight,1,N)')'*(moeModel.Gatings.Input-repmat(GatingWeight,1,N)')  + moeModel.Gatings.Alpha*eye(GD);
            NewGatingWeight = GatingWeight - 2*learningRate*Grad;
            %learningRate = learningRate*decay;
            %NewGatingWeight = GatingWeight -8* moeModel.Gatings.Alpha*hessian\Grad;
            changeRate = norm(NewGatingWeight - GatingWeight)/norm(NewGatingWeight);
            if (changeRate < MinWeightChange) | (count > MaxIt)
                %fprintf('changeRate < MinWeightChange, in GatingsTrain\n');
                GatingWeight = NewGatingWeight;
                break;
            end
            learningRate = learningRate*decay;   
            GatingWeight = NewGatingWeight;
        end %while 
        moeModel.Gatings.Weights(:,i) = GatingWeight;
        %if (moeModel.Gatings.UseMetric == 1)
            %moeModel.Gatings.Metric = 0;%更新metric，这里暂时不会。
        %end
        
    case 'mlr'
        % compute the most probable weights by bound optimization
        count = 0;
        while (count < MaxIt)
            count = count + 1;
            aaa = moeModel.Gatings.Input*GatingWeight;
            GatingOutput = exp(aaa);
%             obj(count,1) = sum(GatingPosterior.*aaa - log(GatingOutput + SumOtherGatingsOutputs))...
%                 - moeModel.Gatings.Alpha/8*GatingWeight'*GatingWeight;
            Grad = (GatingOutput./(SumOtherGatingsOutputs + GatingOutput) - GatingPosterior);
            Grad = moeModel.Gatings.Input'*Grad + moeModel.Gatings.Alpha/4*GatingWeight;
            NewGatingWeight = GatingWeight - 4*moeModel.Gatings.InvH*Grad;
            if (norm(NewGatingWeight - GatingWeight)/norm(NewGatingWeight) < MinWeightChange) | (count > MaxIt)
                GatingWeight = NewGatingWeight;
                break;
            end
            GatingWeight = NewGatingWeight;
        end
        moeModel.Gatings.Weights(:,i) = GatingWeight;
    otherwise
        disp('Unknown method.');
end
