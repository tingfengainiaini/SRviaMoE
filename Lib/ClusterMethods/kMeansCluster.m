%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Liefeng Bo, Cristian Sminchisescu                         %                                         
% Date: 01/12/2010                                                   %
%                                                                    % 
% Copyright (c) 2010  Liefeng Bo - All rights reserved               %
%                                                                    %
% This software is free for non-commercial usage only. It must       %
% not be distributed without prior permission of the author.         %
% The author is not responsible for implications from the            %
% use of this software. You can run it at your own risk.             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [index, centers] = kMeansCluster(Input, Target, k, UseMetric, metric, maxit)
%% kmeans algorithm

constant = 5*1e7;
if nargin < 6
    maxit = 500;
end

% random initialization
[n, d1] = size(Input);
[n, d2] = size(Target);

perm = randperm(n);              
centers = zeros(k, d1 + d2);
for i=1:k
    centers(i,:) = [Input(perm(i),:) Target(perm(i),:)];
end

count = 1;
tindex = zeros(n,1);

%save memory
aaa = 0.0; 
for i = 1:d1
    aaa = aaa + Input(:,i).^2;
end
for i = 1:d2
    aaa = aaa + Target(:,i).^2;
end
%aaa = aaa + sum(Target.^2,2);
dist2 = zeros(n,k);
while 1,
    if (UseMetric == 1)
        for i=1:k
            %这里写的是错误的，中间应该加上M，因为M这时一直是inf，暂时先删去。
            dist2(:,i) = sum(...
                ([Input Target] - repmat(centers(i,:),n,1))...
                *([Input Target]-repmat(centers(i,:),n,1))',  2);
        end
    else
        bbb = sum(centers.^2,2);
        dist2 = aaa*ones(1, k);
        dist2 = dist2 + ones(n,1)*bbb';
        %欧式距离，使用公式(a-b).^2 = a.^2 + b.^2 - 2a*b
        dist2 = sqrt(dist2  - 2*(Input*centers(:,1:d1)') - 2*(Target*centers(:,d1+1:end)'));
    end

    [z,index] = min(dist2,[],2);  % find group matrix g        
    if index == tindex | count > maxit            
        break;          % stop the iteration        
    else
        tindex = index;         % copy group matrix to temporary variable
    end
    for i = 1:k
        fff = find(tindex == i);
        if length(fff)   % only compute centroid if f is not empty               
            if length(fff)*d1 > constant % for large dataset, compute sum at each subblock in order to save memory
                NumBlock = 10;
                cellfff = partition(fff, NumBlock);
                centers(i,:)= [sum(Input(cellfff{1},:),1) sum(Target(cellfff{1},:),1)];
                for j = 2:NumBlock
                    centers(i,:) = centers(i,:) + [sum(Input(cellfff{j},:),1) sum(Target(cellfff{j},:),1)];
                end
                centers(i,:) = centers(i,:)./length(fff);
            else
                centers(i,:) = [mean(Input(fff,:),1) mean(Target(fff,:),1)];
            end
        end
    end
    count = count + 1;
end

%% partition block
function cellfff = partition(fff, num)

n = length(fff);
subn = floor(n/num);

for i = 1:num-1
    cellfff{i} = fff(1+(i-1)*subn : i*subn);
end
cellfff{num} = fff(1+(num-1)*subn:end);

