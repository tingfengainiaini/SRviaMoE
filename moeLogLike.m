function LogLike = moeLogLike(Target, moeModel, count)
%% Compute the loglikelihood

ExpertsMeans = moeModel.Experts.Means;
ExpertsVariances = moeModel.Experts.Variances;
GatingsOutputs = moeModelGatingsOutputsNorm(moeModel);

sumprob = 0.0;
if size(Target,2) == 1
    for i = 1:moeModel.NumExpertsg
        sumprob = sumprob + GatingsOutputs(:,i).*onedimgauss(ExpertsMeans(:,i) - Target, ExpertsVariances(i));
    end
else
    for i = 1:moeModel.NumExperts
        productprob = GatingsOutputs(:,i);
        for j = 1:size(Target,2)
            productprob = productprob.*onedimgauss(ExpertsMeans(:,j,i) - Target(:,j), ExpertsVariances(j,i));
        end
        sumprob = sumprob + productprob;
    end
end
LogLike = sum(log(sumprob));
