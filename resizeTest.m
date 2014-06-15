clc;
close all;
clear;
im = imread('Barbara.png');
im2 = imresize(im(1:7,1:7),4,'bilinear');
%imshow(im);
imshow(im2);