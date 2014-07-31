im  = imread('House_Of_Cards_2013_S02E01_0542_wanted_wang14MoE_22-Jul-2014_ENFixed_k1024_e4_beta3_lamda0.1_Coorperate_regular_usetol0_usew1_usem0_dataNum5000.png');
n1 = size(im,1); n2 = size(im,2);

if (n1/n2 > 2160/3840)
    im2 = imresize(im, [2160 n2*2160/n1]);
else
    im2 = imresize(im, [n1*3840/n2 3840]);
end
imwrite(im2,'im2.png')
