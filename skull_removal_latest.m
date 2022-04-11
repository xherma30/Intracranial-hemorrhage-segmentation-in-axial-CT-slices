clc;clear all;close all
%% Loading the data
cd('...\hemo_subset')
images = dir('*.dcm');

filename = [];
for idx = 1:size(images,1)
    filename = images(idx).name;
    im = dicomread(filename);
    scans.nazev{idx} = {filename};
    scans.im{idx} = {im};
    scans.im{idx} = scans.im{1,idx}{1,1};
end
%% Skull removal
scans.skullFreeIm = cellfun(@skull_removal,scans.im,'UniformOutput',false);
 
for x = 1:size(scans.im,2)    
scans.adjusted{1,x} = imadjust(scans.skullFreeIm{1,x}); %im_adj = imadjust(skullFreeImage);
end

%16,17,20,24
% for idx = 1:size(scans.im,2)
%     figure(idx)
%     subplot(221);
%     imshow(scans.im{1,idx}, []);
%     title('Original grayscale image');
%     subplot(222);
%     imshow(scans.binary{1,idx}, []);
%     title('Skull in binary');
%     subplot(223);
%     imshow(scans.skullFreeOut{1,idx}, []);
%     title('Skull');
%     subplot(224);
%     imshow(scans.skullFreeIm{1,idx}, []);
%     title('Original scan without a skull');
% end

%% Loading the masks
cd('...\Masks_subset')
masks_subset = dir('*.dcm');

filename = [];
for idx = 1:size(masks_subset,1)
    filename = masks_subset(idx).name;
    mask = dicomread(filename);
    masks.nazev{idx} = {filename};
    masks.mask{idx} = {mask};
    masks.mask{idx} = masks.mask{1,idx}{1,1};
    masks.mask{idx} = imbinarize(masks.mask{idx});
end
%% Hemorrhage detection
cd('...\hemo_subset')

for idx = 1:size(scans.adjusted,2)
    figure;
    imshow(masks.mask{idx}, [])
    figure(idx)
    imshow(scans.skullFreeIm{1,idx}, [])
    polyg = impoly;
    mask = createMask(polyg);
    scans.adjusted1{1,idx} = scans.adjusted{1,idx};
    scans.adjusted2{1,idx} = scans.adjusted{1,idx};
    scans.adjusted1{1,idx}(~mask) = 0;
    max_intensity = max(max(scans.adjusted1{1,idx}));
    max_int_10 = (max_intensity/100)*20;
    intensity = max_intensity - max_int_10;
    for y = 1:size(scans.adjusted{1,x},2)
        for z = 1:size(scans.adjusted{1,x},1)
            scans.bi{1,idx}(y,z) = intensity < scans.adjusted1{1,idx}(y,z) ;
        end
    end
    scans.bi{1,idx} = bwareafilt(scans.bi{1,idx},1);
    se2 = strel('disk',5);    
    scans.bi{1,idx} = imclose(scans.bi{1,idx},se2);
    scans.bi{1,idx} = imfill(scans.bi{1,idx},'holes');
    promptMessage = sprintf('Would you like to mark another hemorrhage?');
    titleBarCaption = 'Mark the hemorrhage';
    buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
    if strcmpi(buttonText, 'No')
        %imshow(scans.bi{1,idx}, [])
%         scans.bi2{1,idx} = 0;
%         scans.adjusted2{1,idx} = 0;
        scans.final{1,idx} = scans.bi{1,idx};
    else
    polyg2 = impoly;
    mask2 = createMask(polyg2);
    scans.adjusted2{1,idx}(~mask2) = 0;
    max_intensity = max(max(scans.adjusted2{1,idx}));
    max_int_10 = (max_intensity/100)*20;
    intensity = max_intensity - max_int_10;
        for y = 1:size(scans.adjusted{1,x},2)
            for z = 1:size(scans.adjusted{1,x},1)
                scans.bi2{1,idx}(y,z) = intensity < scans.adjusted2{1,idx}(y,z) ;
            end
        end
    scans.bi2{1,idx} = (max_intensity - max_int_10  ) < scans.adjusted2{1,idx} ;
    scans.bi2{1,idx} = bwareafilt(scans.bi2{1,idx}, 1);
    scans.final{1,idx} = scans.bi{1,idx} | scans.bi2{1,idx};
    end
end


%% Comparsion
for idx = 1:size(scans.final,2)
    figure(idx)
    subplot(211)
    imshow(masks.mask{1,idx},[])
    title('Real hemorrhage')
    subplot(212)
    imshow(scans.final{1,idx},[])
    title('Our output')
end
%% Validation

num_of_pixels = size(scans.final{1,1},2)^2;

for idx = 1:size(scans.final,2)
    for y = 1:size(scans.final{1,idx},1)
        for z = 1:size(scans.final{1,idx},2)
            scans_white_pixels(y,z) = scans.final{1,idx}(y,z) == 1;
            masks_white_pixels(y,z) =  masks.mask{1,idx}(y,z) == 1;
%             scans.agreement{1,idx}(y,z)
            %scans.agreement{1,idx}(y,z) = scans.final{1,idx}(y,z) == masks.mask{1,idx}(y,z);
        end
    end
    num_of_agreement = 0;
    for y = 1:size(scans.final{1,idx},1)
        for z = 1:size(scans.final{1,idx},2)
            if scans_white_pixels(y,z) == 1 & masks_white_pixels(y,z)==1
                num_of_agreement = num_of_agreement  + 1;
            end
        end
    end
    num_of_all_white_mask = sum(sum(masks.mask{1,idx}==1));
    agreement_p(idx) = (num_of_agreement/num_of_all_white_mask)*100;
end

mean_p = mean(agreement_p);
medianp = median(agreement_p);
disp(['Mean:', num2str(mean_p)])  %77.7329
disp(['Median:',num2str(medianp)]) %83.215

%% functions
function wo_skull = skull_removal(im)

gI = medfilt2(im);
% window for skull extracting
grayImage = windowing(gI, 400, 1000);

mask = im2bw(grayImage,0.5);

% window for mask improvement
contour = windowing(gI, 80, 130);

BW = activecontour(contour, mask);
nbhood = strel('disk', 20);
BW = imclose(BW, nbhood);

% window for hemorrhage detection
brain = windowing(im, 40,80);
skull_free = imfill(BW,'holes');
skull_free = skull_free.*brain;
skull_free(BW==1) = 0;

im = im2bw(skull_free,0.001);
BW2 = bwareaopen(im, 50);
skull_free = BW2.*brain;
skull_free(BW==1) = 0;

wo_skull = skull_free;
end

function [grayImage] = windowing(input, L, W)

grayImage = input;
grayImage(grayImage< L-W/2) = L-W/2;
grayImage(grayImage> L+W/2) = L+W/2;
grayImage = im2double(grayImage);
grayImage = (grayImage - min(min(grayImage)))/(max(max(grayImage)-min(min(grayImage))));
end