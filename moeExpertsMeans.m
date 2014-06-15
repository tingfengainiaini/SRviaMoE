function ExpertsMeans = moeExpertsMeans(Input,moeModel)
%% Compute the mean of experts

if length(size(moeModel.Experts.Weights)) == 2
    ExpertsMeans = Input*moeModel.Experts.Weights;
else
    for i = 1:size(moeModel.Experts.Weights,3)
        ExpertsMeans(:,:,i) = Input*moeModel.Experts.Weights(:,:,i);
    end
end