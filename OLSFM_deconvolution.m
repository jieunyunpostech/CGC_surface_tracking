close all
clear all
clc
%%
addpath("D:\mbfm\miniMBFM\matlab\")
I = imread('image.tif');
I = im2double(I);

%%
psf_3 = double(imread(['psf.tif']));

%% Regular deconvolution
% nsr = 40;
% J = deconvwnr(I,psf_3,nsr);
% figure()
% imshow(imadjust(J))
% J_scaled = rescale(J, 0, 1);           
% PSF_ = uint16(J_scaled * 65535);       
% imwrite(PSF_, 'result.tif');
%% Blind deconvolution
iter = 8;
[J,psfr] = deconvblind(I,psf_3,iter);
W = uint16(J.*2^16);
imwrite(W, 'AIF_deconv.tif')