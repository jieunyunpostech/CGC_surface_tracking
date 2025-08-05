close
clear all
clc


%%
addpath('C:\Users\owner\Desktop\oblsm\rabbit\fornix\')
img_classified = imread('6_rgb.tif');
[l,w,h] = size(img_classified);

%%

img_red = img_classified(:,:,1);
imshow(img_red);
%%
BW = imbinarize(img_red, 0.9);
imshow(BW)

%%
min_p=10; % default 10
image_binary=BW;
%% smoothing
windowSize=2;  % Decide as per your requirements
kernel=ones(windowSize)/windowSize^2;
result=conv2(single(image_binary),kernel,'same');
result=result>0.6;
image_binary(~result)=0; 
image_binary=imfill(image_binary,'hole');
figure(1), imshow(image_binary);
%% according to pixel size (cgc clusters -> watershed)
image_binary_gc=bwareafilt(image_binary,[min_p,300]);
image_binary_ws=bwareafilt(image_binary,[301,5000]);

%% cgc clusters seperation
BW=image_binary_ws;
BW_gc = bwpropfilt(BW,'Eccentricity',[0,0.4]);% defalt(0,0.4)
BW_ws = BW-BW_gc;
figure(10); imshow(BW_gc)
figure(20); imshow(BW_ws)

originalBW=BW_ws;
se = strel('disk',5); % defalt 5
erodedBW = imerode(originalBW,se);
figure(200);imshow(erodedBW)

ws_gc_1=ws(BW_gc,1);
ws_gc_2=ws(erodedBW,1);
figure(100);imshow(ws_gc_2);

%% small cgc + cgc cluster
seg_image=image_binary_gc+ws_gc_1+ws_gc_2;
seg_image=im2bw(seg_image,0.1);
seg_image2=bwareafilt(seg_image,[min_p,5000]);
seg_image=image_binary_gc+BW_gc+ws_gc_2;

seg_image2=seg_image ; 
%% cell count 
predict = seg_image2;
[B,L] = bwboundaries(seg_image2,'noholes');
    WL= bwlabel(seg_image2);
    
    stats2 = regionprops(L,'Circularity');

    threshold = 0.5;
    GCD_count=0;
    for k = 1:length(B) 
      boundary = B{k};
      circularity = stats2(k).Circularity;

      metric_string = sprintf('%2.2f',circularity);

      if circularity > threshold
        GCD_count=GCD_count+1;
      else
          predict(WL==k)=0;
      end
    end
      
     GCD=GCD_count;

%% save image
figure(300);imshow(seg_image2)
path='C:\Users\owner\Desktop\oblsm\rabbit\fornix\';


%%
name_raw='6';
ext='.tif';
I_input=imread([path,name_raw,'.tif']);
I_input=imadjust(imgaussfilt(I_input*0.8,2),[0,0.6]);
img=seg_image2;
BW_input=img;
image_back_input=zeros(size(BW_input));

%% divided cellcount overlay
imshow(I_input)
%%
    I=I_input;
    BW=BW_input;
    image_back=image_back_input;

    montage({I, BW, image_back})
%%
    s = regionprops(im2bw(BW,0.1),I(:,:,1),{'Centroid','WeightedCentroid'});
    imshow(I)
%%
    hold on
    numObj = numel(s);
        for k = 1 : numObj
               plot(s(k).Centroid(1), s(k).Centroid(2), 'k.',...
                'LineWidth',1,...
                'MarkerEdgeColor','m',...
                'MarkerFaceColor',[1,0,1])

        end
    ti=sprintf('%d',round(numObj/0.28));
    ti_scr=[ti,' cells/','mm^{2}'];
    title(ti_scr); 
    hold off


%% watershed
function ws_gc=ws(I_bw,open_size)
    bw = I_bw;
    L = watershed(bw);
    Lrgb = label2rgb(L);
    % imshow(Lrgb)
    bw2 = ~bwareaopen(~bw, open_size);
%     imshow(bw2)
    D = -bwdist(~bw);
%     imshow(D,[])

    Ld = watershed(D);
%     imshow(label2rgb(Ld))

    bw2 = bw;
    bw2(Ld == 0) = 0;
%     imshow(bw2)

    mask = imextendedmin(D,2);
    imshowpair(bw,mask,'blend');

    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw3 = bw;
    bw3(Ld2 == 0) = 0;
%     imshow(bw3)
    ws_gc=bw3;
end



%%
save_path = 'C:\Users\owner\Desktop\oblsm\rabbit\fornix\';  
auto_centroids = reshape([s.Centroid], 2, []).';  
save(fullfile(save_path, 'auto_centroids.mat'), 'auto_centroids');
