function GatingsOutputs = moeGatingsOutputs( Input, moeModel )
%MOEGATINGSOUTPUTS Summary of this function goes here
%   Detailed explanation goes here
    GatingsOutputs = zeros(size(Input,1), size(moeModel.Gatings.Weights,2));
    if (strcmpi(moeModel.Gatings.Type,'linear'))
        GatingsOutputs = exp(Input*moeModel.Gatings.Weights);
    elseif (strcmpi(moeModel.Gatings.Type,'metric'))
        for i = 1:moeModel.NumExperts   
             if (moeModel.Gatings.UseMetric == 1)%若是使用了metric
                GatingsOutputs(:,i) =  exp(-moeModel.Gatings.Beta*sum(...
                    (Input-repmat(moeModel.Gatings.Weights(:,i),1,size(Input,1))')* moeModel.Gatings.Metric*...
                    (Input-repmat(moeModel.Gatings.Weights(:,i),1,size(Input,1))')',    2));
             else%没有使用metric
                GatingsOutputs(:,i) =  exp(-moeModel.Gatings.Beta*sum((Input-repmat(moeModel.Gatings.Weights(:,i),1,size(Input,1))').^2,2));
            end
        end
    else
         GatingsOutputs = exp(Input*moeModel.Gatings.Weights);
    end

end

