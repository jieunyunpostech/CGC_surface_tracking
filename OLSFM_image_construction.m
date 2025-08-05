close 
clear all
clc
%%
selpath = uigetdir;
originalpath = pwd;
cd(selpath);
imagefiles = dir('*image_*.tiff');
cd(originalpath)

% imagename = 'image_';
imagename = 'image_';
ext = '.tiff';
img_size = 2048;
pixel_size = 90; % [2mm/s 10exp: 18pix], [3mm/s 10exp: 27pix], [5mm/s 10exp: 45pix] [ 1mm/s 10 exp 9pixel, 1mm/s 20exp 18pixel]
t=1;  % more than 0 (how many frames will be excluded back and forward)
%%
% total_length = img_size + pixel_size*(length(imagefiles)-1)+2000;     % if no AF, 0 as the last factor is recommended. Else, the maximum absolute value of pixel_jump is recommended
total_length = img_size + pixel_size*(length(imagefiles)-1); % flat condition 
%%

frame_start = 1;
frame_end = length(imagefiles);
Z_position = csvread([selpath,'\','a_Zpositiondata.csv']);         % scale: mm
Z_intp =  interp1(0:length(Z_position)-1,Z_position,linspace(0,length(Z_position)-1,frame_end-frame_start+1))';
% Z_position = Z_position(1:length(Z_position));
Z_intp = 1000*(Z_intp-max(Z_intp));                                % scale: um


%%
test_cell = {};

for i=1:length(imagefiles)-1
% for i=1+t:length(imagefiles)-t
    clc
    fprintf('fill in cell : %f / %f', i, length(imagefiles));
    H1 = NaN(total_length, 2048);
%     H1 = NaN(10000, 2048);

    now_image = imread([selpath,'\',imagename,num2str(i,'%04d'),'A',ext]);

    if i <= length(imagefiles)
        theta = pi/4;             % radian
        pixel_jump = ceil(Z_intp(i)*(cos(theta))/0.8125);
        H1(pixel_size*(i-1)+img_size - pixel_jump:-1:pixel_size*(i-1)+1 - pixel_jump, 1:2048) = now_image;
        disp(pixel_jump)
    else
        H1(pixel_size*(i-1)+img_size:-1:pixel_size*(i-1)+1, 1:2048) = now_image;
    end
    
    H2 = uint16(H1);
%     imshow(imadjust(H2))
%     imwrite(imadjust(H2), [selpath,'\',num2str(i,'%04d'),ext])
    test_cell{i} = H1;
%     pause();
end

close
%% maximum intensity projection

% for i = 1:size(test_cell, 2)
%     clc
%     fprintf('cell to array : %f / %f', i, size(test_cell, 2));
%     plane(:, :, i) = test_cell{i};
% end
% 
% 
% for i = 1:size(plane, 1)
%     clc
%     fprintf('MIP : %f / %f', i, size(plane, 1));
%     
%     for j = 1: 2048
%         final_image(i,j) = max(plane(i,j,:));
%     end
% end
% 
% imshow(imadjust(final_image))
% imwrite(final_image, [selpath,'\',imagename,ext])

%% all in focus

% enface_A_allinfocus = fstack_JE(test_cell,...
%         'logsize',100,... % default 40
%         'logstd', 1,... % 7
%         'dilatesize', 31,... % 31
%         'blendsize', 31,... % 31
%         'blendstd', 5,... % 5
%         'logthreshold', 0); % 0
% enface_A_allinfocus = uint16(enface_A_allinfocus);
% figure;imshow(imadjust(enface_A_allinfocus));
% imwrite(enface_A_allinfocus,[selpath,'\','test.tiff']);


filtersize = 64;             %64        40
logstd = 10;                 %10             7
dilatesize = 31;             %61            31
blendsize = 31;              %61          31
blendstd = 5;               %11          5
logthreshold = 0;            %0

% make brightness of all images equal
% avg1 = mean2(test_cell{1});
% for ii = 2 : length(test_cell)
%     clc
%     fprintf('AIF-1. %f / %f', ii, length(test_cell));
%     avgcur = mean2(test_cell{ii});
%     test_cell{ii} = test_cell{ii} + avg1 - avgcur;
% end
%%
imgfiltered = cell(size(test_cell));
logfilter = fspecial('log', [filtersize filtersize], logstd);
se = strel('ball', dilatesize, dilatesize);

for ii = 1:length(test_cell)    
% for ii = 120:131    
    clc
    fprintf('AIF-1. filtering: %f / %f', ii, length(test_cell));
    imgfiltered{ii} = imfilter(single(test_cell{ii}), logfilter);
    % Note that LoG detects border with zero-crossing. It might be worth
    % playing with the following. 
    %from here
    imgfiltered{ii} = -imfilter(single(test_cell{ii}), logfilter);
    imgfiltered{ii} = abs(imgfiltered{ii});
    % to here
%     imgfiltered{ii} = imdilate(imgfiltered{ii}, se, 'same');
end

fmap = ones(size(test_cell{1}), 'single');
logresponse = zeros(size(test_cell{1}), 'single') + logthreshold;
%%
% Look for focal plane that has the largest LoG response (pixel in focus). 
for ii = 1:length(test_cell)
% for ii = 120:131    
    clc
    fprintf('AIF-2. choosing pixel in focus: %f / %f', ii, length(test_cell));
%     imgfiltered{ii}(imgfiltered{ii}<=0.2) = NaN;
    index = imgfiltered{ii} > logresponse;
    logresponse(index) = imgfiltered{ii}(index);
    fmap(index) = ii;
end

% Smooth focal plane image
fmap = imfilter(fmap,fspecial('gaussian', [blendsize blendsize], blendstd));
fmap(fmap < 1) = 1;
edofimg = test_cell{1};
%%
% Extract in-focus pixel from every image. 
for ii = 1:length(test_cell)
% for ii = 120:131  
    clc
    fprintf('AIF-3. extracting from every image: %f / %f', ii, length(test_cell));
    index = fmap == ii;
    edofimg(index) = test_cell{ii}(index);
end
%%
% Blend different focal planes
for ii = 1:length(test_cell)-1
% for ii = 120:131 
    clc
    fprintf('AIF-4. blending(almost done):  %f / %f', ii, length(test_cell)-1);
    index = fmap > ii & fmap < ii+1;
    edofimg(index) = (fmap(index) - ii).*single(test_cell{ii+1}(index)) + ...
       (ii+1-fmap(index)).*single(test_cell{ii}(index));
end
%%
final_image = uint16(edofimg);
imshow(imadjust(final_image))
imwrite(final_image, [selpath,'\','AIF_final_JE',ext])