%%  demo: Mixture of Experts for Pattern Classification
%   Mixture of Experts (ME) for multi-class Classification Problem.
%   We used MLP Algorithm with Back-propagation training rule as base classifiers (experts) in ME.

%   Written by Nima Hatami, 
%   Department of Electrical Engineering,
%   hatami@shahed.ac.ir

close all
clear all

%% Load Satimage data set from UC ML Repository
load('satimage_data.mat')

%% Set Parameters
Iteration=200;  % number of epoch for training
eta_e=0.071;
eta_g=0.071;
n1=size(P,1);n2=10;n3=size(T,1);n3_g=3;n2_g=10;
w12_1=-1+2*rand([n2,n1+1]);
w23_1=-1+2*rand([n3,n2+1]);
w12_2=-1+2*rand([n2,n1+1]);
w23_2=-1+2*rand([n3,n2+1]);
w12_3=-1+2*rand([n2,n1+1]);
w23_3=-1+2*rand([n3,n2+1]);
w12_g=-1+2*rand([n2_g,n1+1]);
w23_g=-1+2*rand([n3_g,n2_g+1]);

%% Training phase and updating weights for Multilayer Perceptron (MLP)
for k=1:Iteration
    %k
    eta_g=(1-k/Iteration);
    eta_e=(1-k/Iteration);
    for i=1:size(T,2)
       target=T(:,i);
       xin=ones(n1+1,1);
       xin(1:n1)=P(:,i);
       xin=xin';
       s2_1=w12_1(1:n2,1:n1+1)*xin';
       a2_1=1./(1+exp(-s2_1));
       a2_1=[a2_1;1.0];
       s3_1=w23_1*a2_1;
       a3_1=1./(1+exp(-s3_1));
       delta3_1=(target-a3_1).*(a3_1.*(1-a3_1));
       delta2_1=w23_1(1:n3,1:n2)'*delta3_1;
       delta2_1=delta2_1.*(a2_1(1:n2,1).*(1-a2_1(1:n2,1)));
   %%%%%%%%%%%%%%%%%%%%%%
       s2_2=w12_2(1:n2,1:n1+1)*xin';
       a2_2=1./(1+exp(-s2_2));
       a2_2=[a2_2;1.0];
       s3_2=w23_2*a2_2;
       a3_2=1./(1+exp(-s3_2));
       delta3_2=(target-a3_2).*(a3_2.*(1-a3_2));
       delta2_2=w23_2(1:n3,1:n2)'*delta3_2;
       delta2_2=delta2_2.*(a2_2(1:n2,1).*(1-a2_2(1:n2,1)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
       s2_3=w12_3(1:n2,1:n1+1)*xin';
       a2_3=1./(1+exp(-s2_3));
       a2_3=[a2_3;1.0];
       s3_3=w23_3*a2_3;
       a3_3=1./(1+exp(-s3_3));
       delta3_3=(target-a3_3).*(a3_3.*(1-a3_3));
       delta2_3=w23_3(1:n3,1:n2)'*delta3_3;
       delta2_3=delta2_3.*(a2_3(1:n2,1).*(1-a2_3(1:n2,1)));

    h(1,1)=exp(-0.5*(a3_1-T(:,i))'*(a3_1-T(:,i)))/(exp(-(a3_1-T(:,i))'*(a3_1-T(:,i)))+exp(-(a3_2-T(:,i))'*(a3_2-T(:,i)))+exp(-(a3_3-T(:,i))'*(a3_3-T(:,i))));
    h(2,1)=exp(-0.5*(a3_2-T(:,i))'*(a3_2-T(:,i)))/(exp(-(a3_1-T(:,i))'*(a3_1-T(:,i)))+exp(-(a3_2-T(:,i))'*(a3_2-T(:,i)))+exp(-(a3_3-T(:,i))'*(a3_3-T(:,i))));
    h(3,1)=exp(-0.5*(a3_3-T(:,i))'*(a3_3-T(:,i)))/(exp(-(a3_1-T(:,i))'*(a3_1-T(:,i)))+exp(-(a3_2-T(:,i))'*(a3_2-T(:,i)))+exp(-(a3_3-T(:,i))'*(a3_3-T(:,i))));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    s2_g=w12_g(1:n2_g,1:n1+1)*xin';
       a2_g=1./(1+exp(-s2_g));
       a2_g=[a2_g;1.0];
       s3_g=w23_g*a2_g;
       a3_g=1./(1+exp(-s3_g));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    g(1,1)=exp(a3_g(1,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
    g(2,1)=exp(a3_g(2,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
    g(3,1)=exp(a3_g(3,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
    delta3_g=(h-g).*(a3_g.*(1-a3_g));
       delta2_g=w23_g(1:n3_g,1:n2_g)'*delta3_g;
       delta2_g=delta2_g.*(a2_g(1:n2_g,1).*(1-a2_g(1:n2_g,1)));
       
%% Update weights
       w23_1=w23_1+eta_e*h(1,1)*(delta3_1*a2_1');
       w12_1=w12_1+eta_e*h(1,1)*(delta2_1*xin);
       w23_2=w23_2+eta_e*h(2,1)*(delta3_2*a2_2');
       w12_2=w12_2+eta_e*h(2,1)*(delta2_2*xin);
       w23_3=w23_3+eta_e*h(2,1)*(delta3_3*a2_3');
       w12_3=w12_3+eta_e*h(2,1)*(delta2_3*xin);
       w23_g=w23_g+eta_g*(delta3_g*a2_g');
       w12_g=w12_g+eta_g*(delta2_g*xin);
       end
%% Test phase

for i=1:size(Ttest,2)
       target=Ttest(:,i);
       xin=ones(n1+1,1);
       xin(1:n1,1)=Ptest(:,i);
       s2_1=w12_1*xin;
       a2_1=1./(1+exp(-s2_1));
       a2_1=[a2_1;1.0];
       s3_1=w23_1*a2_1;
       a3_1=1./(1+exp(-s3_1));
       a3_1_temp(:,i)=a3_1;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%
       s2_2=w12_2*xin;
       a2_2=1./(1+exp(-s2_2));
       a2_2=[a2_2;1.0];
       s3_2=w23_2*a2_2;
       a3_2=1./(1+exp(-s3_2));
       a3_2_temp(:,i)=a3_2;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%
       s2_3=w12_3*xin;
       a2_3=1./(1+exp(-s2_3));
       a2_3=[a2_3;1.0];
       s3_3=w23_3*a2_3;
       a3_3=1./(1+exp(-s3_3));
       a3_3_temp(:,i)=a3_3;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       s2_g=w12_g*xin;
       a2_g=1./(1+exp(-s2_g));
       a2_g=[a2_g;1.0];
       s3_g=w23_g*a2_g;
       a3_g=1./(1+exp(-s3_g));
       %%%%%%%%%%%%%%%%%%%%%%%%%%%
      g(1,1)=exp(a3_g(1,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
      g(2,1)=exp(a3_g(2,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
      g(3,1)=exp(a3_g(3,1))/(exp(a3_g(1,1))+exp(a3_g(2,1))+exp(a3_g(3,1)));
      
      outme(:,i)=g(1,1)*a3_1+g(2,1)*a3_2+g(3,1)*a3_3;
end
      realoutput=outme;
expertresult=[realoutput' Ttest'];
%% Percentage and Accuracy
desierdoutput=Ttest;
[mp,np]=size(realoutput);

sum1=0;
[d,f]=max(realoutput);
[dt,ft]=max(desierdoutput);
for i=1:size(Ttest,2)
    if f(1,i)==ft(1,i)
         sum1=sum1+1;
    else 
    end
end
Total_Accuracy=(sum1*100)/size(Ttest,2)
percentage(1,k)=Total_Accuracy;
%%%%%%%%%
sum1=0;
[d,f_1]=max(a3_1_temp);
[dt,ft]=max(desierdoutput);
for i=1:size(Ttest,2)
    if f_1(1,i)==ft(1,i)
         sum1=sum1+1;
    else 
    end
end
percent_expert_1=(sum1*100)/size(Ttest,2)
percentage_ex_1(1,k)=percent_expert_1;
%%%%%%%%%%%

sum1=0;
[d,f_2]=max(a3_2_temp);
[dt,ft]=max(desierdoutput);
for i=1:size(Ttest,2)
    if f_2(1,i)==ft(1,i)
         sum1=sum1+1;
    else 
    end
end
percent_expert_2=(sum1*100)/size(Ttest,2)
percentage_ex_2(1,k)=percent_expert_2;
%%%%%%%%%
sum1=0;
[d,f_3]=max(a3_3_temp);
[dt,ft]=max(desierdoutput);
for i=1:size(Ttest,2)
    if f_3(1,i)==ft(1,i)
         sum1=sum1+1;
    else 
    end
end
percent_expert_3=(sum1*100)/size(Ttest,2)
percentage_ex_3(1,k)=percent_expert_3;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
