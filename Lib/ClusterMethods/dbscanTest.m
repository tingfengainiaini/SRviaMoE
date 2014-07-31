clc;
clear;
close all;
load SData;
%data = [2,1;2,2;2,3;3,2;4,4;10,3;10,7;12,4;11,5;11,3.4];
[Input, Target] = MoE_SyntheticData();
data = [Input Target];
[class,type] = dbscan(data,5);
for k = 1:length(data)
    if(type(k)==1)
       plot(data(k,1),data(k,2),'rs');hold on;
    elseif(type(k) ==0)
            plot(data(k,1),data(k,2),'go');hold on;
    else
            plot(data(k,1),data(k,2),'bx');hold on;
    end
    text(data(k,1),data(k,2),num2str(class(k)))
   
end