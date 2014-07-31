clc;
close all;
clear;
a = zeros(7, 7);%原图patch的大小
scalesize = 4;%放大倍数

start_tans_x = 9;%要截取的部分的patch开始的x
length_x = 12;%要截取的部分的patch的高
start_tans_y = 9;%要截取的部分的patch开始的y
length_y = 12;%要截取的部分的patch的宽
index2 = [2:6 8:42 44:48]';%要使用的部分
%index2 = [2:19 21:379 381:399]';%要使用的部分

w = zeros(size(a,1)*size(a,2)*scalesize*scalesize, size(a,1)*size(a,2));
for i=1:size(a,1)
    for j = 1:size(a,2)
        a = zeros(size(a,1),size(a,2));
        a(i,j) = 1;
        b = imresize(a,scalesize);
        index = find(b~=0);
        
        k = (i-1)*size(a,1)+j;
        disp(k);
        w(index,k) = b(index);
    end
end
im = im2double(imread('Barbara.bmp'));
%im = imread('Barbara.png');
startx = 11;
starty = 1;
x = im(startx:(size(a,1)+startx-1), starty:(size(a,2)+starty-1));

figure;
imshow(x);

y = imresize(x,4);
figure;
imshow(y);

xx = x';
z = reshape(w*xx(:),size(a,1)*scalesize,size(a,2)*scalesize);
figure;
imshow(z);

index = zeros(length_x*length_y,1);
for i=1:length_x
        index(((i-1)*length_y+1) : ((i-1)*length_y+length_y)) = ((start_tans_x+i-2)*size(a,1)*scalesize+start_tans_y):((start_tans_x+i-2)*size(a,1)*scalesize+start_tans_y+length_y-1);
end

ww = w(index,index2);
xx = x';
zz = reshape(ww*xx(index2),length_x,length_y);
figure;
imshow(zz);

www = [ww zeros(size(ww,1),1)]; %因为x最后加了一个1，那么ww最后加个0.
zzz = reshape([xx(index2);1]'*www',length_x,length_y);
figure;
imshow(zzz);
www = www';
save('w1.mat','www');

data = load('w0.mat');
wwww = data.www;
