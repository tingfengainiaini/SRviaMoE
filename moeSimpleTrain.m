function moeModel = moeSimpleTrain(moeModel, Target, idx_label)

%% Train moeModel
 MinPosterior = 0.001;
 MinErrorCompete = inf; 
 MinErrorCoorper = inf;
 MinErrorLoc = 1;
ifbreak = 0;

count = 1;
while (count <= moeModel.MaxIt)
    moeModelTemp = moeModel;%record the moe with min error
    ifbreak = 0;
    
    %Train the gates and experts simultaneously
    for i = 1:moeModel.NumExperts    
        moeModel = moeSimpleExpertsTrain(Target, moeModel, i) ;
        moeModel = moeSimpleGatingsTrain(moeModel, i) ;

        %gatingsOutputs = zeros(size(moeModel.Gatings.Input,1),size(moeModel.Gatings.Weights,2));
        sum_squre_distance = zeros(size(moeModel.Gatings.Input,1),size(moeModel.Gatings.Weights,2));
        %To avoid the 0/0 problem, I use a method here.
        %In the process computing the gatingOutput, sub a min exp value
        if (strcmp(moeModel.Gatings.Type,'metric'))
            for i = 1:moeModel.NumExperts
                if (moeModel.Gatings.UseMetric == 1)%使用metric矩阵
                    sum_squre_distance(:,i) = sum((moeModel.Gatings.Input-repmat(moeModel.Gatings.Weights(:,i),1,size(moeModel.Gatings.Input,1))')*...
                        moeModel.Gatings.Metric*...
                        (moeModel.Gatings.Input-repmat(moeModel.Gatings.Weights(:,i),1,size(moeModel.Gatings.Input,1))')', 2);
                else%不使用metric矩阵
                    sum_squre_distance(:,i) = sum((moeModel.Gatings.Input-repmat(moeModel.Gatings.Weights(:,i),1,size(moeModel.Gatings.Input,1))').^2,2);
                end
            end
            %这里使用小技巧，gateoutput的分子分母同时除以一个最小值，这样不影响最终结果，但是防止了0/0的情况
            min_sum = min(sum_squre_distance,[],2)/2;
            gatingsOutputs = exp(-moeModel.Gatings.Beta*(sum_squre_distance-repmat(min_sum,1,moeModel.NumExperts)));
            moeModel.Gatings.Outputs  =  gatingsOutputs;
            %这里需不需要每一步都scale一下啊？
            %moeModel.Gatings.Outputs = moeModelGatingsOutputsNorm(moeModel);
        else
             moeModel.Gatings.Outputs = exp(moeModel.Gatings.Input*moeModel.Gatings.Weights);
        end
    end
    if (sum(sum(isnan(moeModel.Gatings.Outputs)))>0)
        %moeModel.Gatings.Posteriors  = moeModel.Gatings.Posteriors + MinPosterior;
        moeModel.Gatings.Outputs(isnan(moeModel.Gatings.Outputs)) = eps;
        if (sum(sum(isnan(moeModel.Gatings.Outputs)))>0)
            fprintf('%d iterate: %d break\n', idx_label,count);
            fprintf('%d iterate: %d isnan(moeModel.Gatings.Outputs), result in moeModel reduce\n', idx_label,count);
            moeModel = moeModelTemp;
            ifbreak = 1;
        end
    end
    
    moeModel.Experts.Means = moeExpertsMeans(moeModel.Experts.Input,moeModel);
    moeModel.Experts.Variances = moeExpertsVariances(Target, moeModel);
    moeModel.Gatings.Posteriors = moeModelGatingsPosterior(Target, moeModel);
    
    %if there exists nan in Gatings'posteriors, then add an eps to it.
    %If this problem persists, make the moe reduece to moeModelTemp.
    if (sum(sum(isnan(moeModel.Gatings.Posteriors)))>0)
        %moeModel.Gatings.Posteriors  = moeModel.Gatings.Posteriors + MinPosterior;
        moeModel.Gatings.Posteriors(isnan(moeModel.Gatings.Posteriors)) = eps;
        if (sum(sum(isnan(moeModel.Gatings.Posteriors)))>0)
            fprintf('%d iterate: %d break\n', idx_label,count);
            fprintf('%d iterate: %d isnan(moeModel.Gatings.Posteriors), result in moeModel reduce\n', idx_label,count);
            moeModel = moeModelTemp;
            ifbreak = 1;
        end
    end
    
    moeModel.LogLike(count,1) = moeLogLike(Target, moeModel);
    
    if (sum(sum(isnan(moeModel.LogLike(count))))>0) 
            fprintf('%d iterate: %d isnan(moeModel.LogLike), result in moeModel reduce\n', idx_label,count);
            ifbreak = 1;
    end
    
     if (sum(sum(isinf(moeModel.LogLike(count))))>0) 
            fprintf('%d iterate: %d isinf(moeModel.LogLike), result in moeModel reduce\n', idx_label,count);
            ifbreak = 1;
     end
    
    if count == 1
        LogLikeChange = 10*moeModel.MinLogLikeChange*moeModel.LogLike(count);
    else
        LogLikeChange = moeModel.LogLike(count) - moeModel.LogLike(count-1);
    end
    [moeModel.Test.TrainingMAE(count,:), moeModel.Test.TrainingPMAE(count,:), moeModel.Test.PredicteMAECompete(count), moeModel.Test.PredicteMAECoorper(count)] = moeTest(moeModel.Experts.Input, moeModel.Gatings.Input, Target, moeModel);
     disp(['Current label:               '  num2str(idx_label)]);
    disp(['Current Iteration:               '  num2str(count)]);
    disp(['Current log likelihood:          '  num2str(moeModel.LogLike(count))]);
    if count > 1
        disp(['Previous log likelihood:         '  num2str(moeModel.LogLike(count-1))]);
        disp(['Log Likelihood Change:           '  num2str(LogLikeChange)]);
    end
    disp(['Best Training Error:             ' num2str(moeModel.Test.TrainingMAE(count,:))]);
    disp(['Most Probable Training Error:    ' num2str(moeModel.Test.TrainingPMAE(count,:))]);
    disp(['Training Error-compete:          ' num2str(moeModel.Test.PredicteMAECompete(count))]);
    disp(['Training Error-coorperate:       ' num2str(moeModel.Test.PredicteMAECoorper(count))]);
    
    %Use the moe with least error.
    if count == 1
        MinErrorCompete = min(MinErrorCompete, moeModel.Test.PredicteMAECompete(count)); 
        MinErrorCoorper = min(MinErrorCoorper, moeModel.Test.PredicteMAECoorper(count)); 
    else
        if strcmpi(moeModel.Gatings.ERelation,'Compete')
            if (moeModel.Test.PredicteMAECompete(count) < MinErrorCompete)
                moeModelTemp = moeModel;
                MinErrorCompete = moeModel.Test.PredicteMAECompete(count);
                MinErrorLoc = count;
            end
        elseif strcmpi(moeModel.Gatings.ERelation,'Coorperate')
            if (moeModel.Test.PredicteMAECoorper(count) < MinErrorCoorper)
                moeModelTemp = moeModel;
                MinErrorCoorper = moeModel.Test.PredicteMAECoorper(count);
                MinErrorLoc = count;
            end
        end
    end
%     if nargin > 2
%         [moeModel.Test.TestMAE(count,:), moeModel.Test.TestPMAE(count,:), PredicteMAE] = moeTest(moeModel.Test.EInput,moeModel.Test.GInput, TestTarget, moeModel);
%         disp(['Best Test Error:                 ' num2str(moeModel.Test.TestMAE(count,:))]);
%         disp(['Most Probable Test Error:        ' num2str(moeModel.Test.TestPMAE(count,:))]);
%         disp(['Total Predict Test Error:    ' num2str(PredicteMAE)]);
%     end
    disp('--------------------------------------------------------------'); 
    
    %if Loglike may tends to be inf, then interupt the iteration.
    if (sum(sum(isinf(moeModel.LogLike)))>0)
        %use the moe with min error
        ifbreak = 1;
    end
    %PredicteMAE
    if ( abs(LogLikeChange) < moeModel.MinLogLikeChange*abs(moeModel.LogLike(count)))
        disp('abs(LogLikeChange) got min value\n'); 
        %use the moe with min error
        moeModel = moeModelTemp;
        ifbreak = 1;
    end
    count = count + 1;
    if count > moeModel.MaxIt
        moeModel = moeModelTemp;
        ifbreak = 1;
    end
    if ifbreak == 1
        if strcmpi(moeModel.Gatings.ERelation,'Compete')
            disp(['moeModel reduece to iter ' num2str(MinErrorLoc) ',Training Error:    ' num2str(moeModel.Test.PredicteMAECompete(MinErrorLoc))]);
        elseif strcmpi(moeModel.Gatings.ERelation,'Coorperate')
            disp(['moeModel reduece to iter ' num2str(MinErrorLoc) ',Training Error:    ' num2str(moeModel.Test.PredicteMAECoorper(MinErrorLoc))]);
        end
        moeModel = cleardata(moeModel, size(Target,2));
        break;
    end
end
moeModel = cleardata(moeModel,size(Target,2));
end

%clear the superfluous data
function moeModel = cleardata(moeModel,a)
    if a ~= 1
        if isfield(moeModel.Experts,'Means')
            moeModel.Experts = rmfield(moeModel.Experts,'Means');
        end
        if isfield(moeModel.Experts,'Variances')
            moeModel.Experts = rmfield(moeModel.Experts,'Variances');
        end
         if isfield(moeModel.Gatings,'Outputs')
            moeModel.Gatings = rmfield(moeModel.Gatings,'Outputs');
         end
         if isfield(moeModel.Gatings,'Posteriors')
            moeModel.Gatings = rmfield(moeModel.Gatings,'Posteriors');
         end   
    end
    if isfield(moeModel.Gatings,'InvH')
        moeModel.Gatings = rmfield(moeModel.Gatings,'InvH');
    end
    if isfield(moeModel.Gatings,'InvHH')
        moeModel.Gatings = rmfield(moeModel.Gatings,'InvHH');
    end
    if isfield(moeModel.Gatings,'Input')
        moeModel.Gatings = rmfield(moeModel.Gatings,'Input');
    end
    if isfield(moeModel.Experts,'Input')
        moeModel.Experts = rmfield(moeModel.Experts,'Input');
    end
    if isfield(moeModel,'Test')
        moeModel = rmfield(moeModel,'Test');
    end
end