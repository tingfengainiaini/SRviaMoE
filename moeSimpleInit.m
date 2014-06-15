function  moeModel = moeSimpleInit(moeModel, Input, Target, ClusterTarget, TestInput)
folder_project = pwd;
folder_lib = fullfile(folder_project,'Lib');
addpath(genpath(folder_lib));

moeModel.Test.NumExperts = moeModel.NumExperts;
N = size(Input,1);
if nargin > 4
    if strcmpi(moeModel.Experts.Kernel, 'linear')
        moeModel.Test.EInput = [ones(size(TestInput,1),1) TestInput];
    else
        K = kernelValue(TestInput, Input, moeModel.Experts.Kernel, moeModel.Experts.KParam);
        moeModel.Test.EInput = [ones(size(K,1),1) K];
        clear K;
    end
    if strcmpi(moeModel.Gatings.Kernel, 'linear')
        if strcmpi(moeModel.Gatings.Type, 'metric')
            moeModel.Test.GInput = TestInput;
        elseif strcmpi(moeModel.Gatings.Type, 'mlr')
            moeModel.Test.GInput = [ones(size(TestInput,1),1) TestInput];
        end  
    else
        K = kernelValue(TestInput, Input, moeModel.Gatings.Kernel, moeModel.Gatings.KParam);
        %moeModel.Test.GInput = [ones(size(K,1),1) K];
        moeModel.Test.GInput = K;
        clear K;
    end
end

[IDInput, Centers] = kMeansCluster(Input, ClusterTarget/10, moeModel.NumExperts) ;
Centers = [Centers(:,1:size(Input,2)),Centers(:,(size(Input,2)+1):(size(Input,2)+size(Target,2)))*10];
InputCenters = Centers(:,1:size(Input,2));
DataPointColors = {'r.','g.','b.','k.','m.','c.','y.'} ; 
LineColors = {'r-','g-','b-','k-','m-','c-','y-'} ; 



%% Initialize experts 
switch lower(moeModel.Experts.Type)
    case 'linear'%linear experts
        if strcmpi(moeModel.Experts.Kernel, 'linear')
            %Input already has one column that consists of all one, in the
            %colomn 46
            moeModel.Experts.Input = Input;
        else
            K = kernelValue(Input, Input, moeModel.Experts.Kernel, moeModel.Experts.KParam);
            moeModel.Experts.Input = [ones(N,1) K];
            clear K;
        end
        ED = size(moeModel.Experts.Input,2);
        moeModel.Experts.Alpha = 1e-4;
        
        if size(Target,2) == 1
            moeModel.Experts.Weights = zeros(ED,moeModel.NumExperts);
%              h6 = figure('Name','init') ; 
%             hold on ;   
%              for i = 1:moeModel.NumExperts
%                 Indices = find(IDInput == i) ; 
%                 plot(Input(Indices),Target(Indices),DataPointColors{i});  
%              end
%             plot(Centers(:,1),Centers(:,size(Centers,2)),'r*');
            %use linear regression initialize the weights of experts
            if strcmpi(moeModel.Experts.Kernel, 'linear')
                for i = 1:moeModel.NumExperts
                    Indices = find(IDInput == i) ; 
                    %moeModel.Experts.Weights(:,i) = (moeModel.Experts.Input(Indices)'*moeModel.Experts.Input(Indices))\moeModel.Experts.Input(Indices)'*Target(Indices);
                    %plot(Input,moeModel.Experts.Input*moeModel.Experts.Weights(:,i),LineColors{i});
                    %
                    moeModel.Experts.Variances(i) = var(Target(Indices,:));
                end
                moeModel.Experts.Means = moeExpertsMeans(moeModel.Experts.Input,moeModel);
            end
        else
            moeModel.Experts.Weights = zeros(ED,size(Target,2),moeModel.NumExperts);
            %for i = 1:moeModel.NumExperts
                    %Indices = find(IDInput == i) ; 
                    %moeModel.Experts.Weights(:,i) = (moeModel.Experts.Input(Indices)'*moeModel.Experts.Input(Indices))\moeModel.Experts.Input(Indices)'*Target(Indices);
            %end   
            for j = 1:size(Target,2)
                for i = 1:moeModel.NumExperts
                        Indices = find(IDInput == i) ;
                        %moeModel.Experts.Weights(:,:,i) = LinearRegressor(Input(Indices,:),Target(Indices,:));
                        %moeModel.Experts.Weights(:,:,i) = Input(Indices,:)\Target(Indices,:);
                        moeModel.Experts.Variances(j,i) = var(Target(Indices,j));
                end
            end
            if strcmpi(moeModel.Experts.Kernel, 'linear')
                 moeModel.Experts.Means = moeExpertsMeans(moeModel.Experts.Input,moeModel);
            %moeModel.Experts.Variances = moeExpertMeans
            end
        end
    case 'rr'
        if strcmpi(moeModel.Experts.Kernel, 'linear')
            moeModel.Experts.Input = Input;
        else
            K = kernelValue(Input, Input, moeModel.Experts.Kernel, moeModel.Experts.KParam);
            moeModel.Experts.Input = [ones(N,1) K];
            clear K;
        end
        %ED = size(moeModel.Experts.Input,2);
        %DHessian = sum(moeModel.Experts.Input.^2,2);
        moeModel.Experts.Alpha = 1e-2;
    case 'rvm'
        if strcmpi(BME.Experts.Kernel, 'linear')
            BME.Experts.Input = [ones(N,1) Input];
        else
            K = EvalKernel(Input, Input, BME.Experts.Kernel, BME.Experts.KParam);
            BME.Experts.Input = [ones(N,1) K];
            clear K;
        end
        ED = size(BME.Experts.Input,2);
        BME.Experts.Alpha = 1e-5;
        BME.Experts.Weights = zeros(ED,BME.NumExperts);
        [IDInput, Centers] = kMeansCluster(Input, ClusterTarget/10, BME.NumExperts) ; 
        for i = 1:BME.NumExperts
            Indices = find(IDInput == i) ;
            BME.Experts.Beta(1,i) = 1/(var(Target(Indices,:)/10));
            BME.Experts.Variances(i) = var(Target(Indices,:))/10;
        end
    otherwise
        disp( ['Unknown method: ' lower(moeModel.Experts.Type)]);
end

%% Initialize the gatings
switch lower(moeModel.Gatings.Type)
    case 'metric'
        if strcmpi(moeModel.Gatings.Kernel, 'linear')
            %moeModel.Gatings.Input = [ones(N,1) Input];
            moeModel.Gatings.Input = Input;
        else
            K = kernelValue(Input, Input, moeModel.Gatings.Kernel, moeModel.Gatings.KParam);
            %moeModel.Gatings.Input = [ones(N,1) K];
            moeModel.Gatings.Input = K;
            clear K;
        end
        GD = size(moeModel.Gatings.Input,2);
        moeModel.Gatings.Alpha = 1e-2;     
        moeModel.Gatings.Weights = zeros(GD,moeModel.NumExperts);
        
        MinPosterior = 0.01;
        moeModel.Gatings.Posteriors = MinPosterior*ones(N,moeModel.NumExperts) ;
        for i = 1:moeModel.NumExperts
            Indices = find(IDInput == i) ;
            moeModel.Gatings.Posteriors(Indices,i) = 1 - (moeModel.NumExperts-1)*MinPosterior;
        end
        
        if strcmpi(moeModel.Gatings.Kernel, 'linear')
            %moeModel.Gatings.Weights = [ones(size(InputCenters,1),1) InputCenters]';
            moeModel.Gatings.Weights = InputCenters';
            for i = 1:moeModel.NumExperts
                moeModel.Gatings.Outputs(:,i) = exp(-moeModel.Gatings.Beta*sum((moeModel.Gatings.Input-repmat(moeModel.Gatings.Weights(:,i),1,N)').^2,2)); 
                %plot(Input, moeModel.Gatings.Outputs(:,i), LineColors{i});  
            end
            %moeModel.Gatings.Outputs = moeModelGatingsOutputsNorm(moeModel);
            %moeModel.Gatings.Posteriors = moeModelGatingsPosterior(Target, moeModel);
        end
        
        %GatingOutputNorm = moeModelGatingsOutputsNorm(moeModel);
        %Hessian = (moeModel.Gatings.Input)'*(moeModel.Gatings.Input);
        %moeModel.Gatings.InvH = inv(Hessian + moeModel.Gatings.Alpha*eye(GD));
        %moeModel.Gatings.InvHH = moeModel.Gatings.InvH*Hessian;
   case 'mlr'
        if strcmpi(moeModel.Gatings.Kernel, 'linear')
            moeModel.Gatings.Input = [ones(N,1) Input];
        else
            K = EvalKernel(Input, Input, moeModel.Gatings.Kernel, moeModel.Gatings.KParam);
            moeModel.Gatings.Input = [ones(N,1) K];
            clear K;
        end
        GD = size(moeModel.Gatings.Input,2);
        Hessian = moeModel.Gatings.Input'*moeModel.Gatings.Input;
        moeModel.Gatings.Alpha = 1e-2;     
        moeModel.Gatings.InvH = inv(Hessian + moeModel.Gatings.Alpha*eye(GD));
        moeModel.Gatings.InvHH = moeModel.Gatings.InvH*Hessian;
        moeModel.Gatings.Weights = zeros(GD,moeModel.NumExperts);
        moeModel.Gatings.Outputs = exp(moeModel.Gatings.Input*moeModel.Gatings.Weights);
        MinPosterior = 0.01;
        moeModel.Gatings.Posteriors = MinPosterior*ones(N,moeModel.NumExperts) ;
        for i = 1:moeModel.NumExperts
            Indices = find(IDInput == i) ;
            moeModel.Gatings.Posteriors(Indices,i) = 1 - (moeModel.NumExperts-1)*MinPosterior;
        end
    otherwise
        disp( ['Unknown method: ' lower(moeModel.Gatings.Type)]);
end
% hold off;
