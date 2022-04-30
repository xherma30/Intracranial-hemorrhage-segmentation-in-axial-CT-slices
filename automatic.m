clc,clear all,close all

dice_score=[];
jaccard_coeff=[];

cd('I:\Hemoragie\hemo_subset');
images = dir('*.dcm');

filename = [];
for idx = 1:size(images,1)
    filename = images(idx).name;
    im = dicomread(filename);

% im = dicomread(['049_21.dcm']);
im = skull_removal(im);
im_adj = imadjust(im);
im = im_adj;

% figure;
% imshow(im_adj, [])

max_intensity = max(max(im));
max_int_10 = (max_intensity/100)*10;
bi = max_intensity <= im ;
bi = bwareafilt(bi, 4);
se2 = strel('disk',3);   
bi = imclose(bi,se2);
bi = imfill(bi, 'holes');

% figure;
% imshow(bi, [])

%% real hemorrhage
%  baseFileName = '049_21.dcm';
 baseFileName = filename;
folder = 'I:\Hemoragie\Masks_subset';
fullFileName = fullfile(folder, baseFileName);
result = dicomread(fullFileName);
result = imbinarize(result);

% figure;
% subplot(211)
% imshow(vysledek,[])
% title('Real hemorrhage')
% subplot(212)
% imshow(bi,[])
% title('Our output')
%% Validation
num_of_pixels = bi^2;
hemorrhage = bi ;
mask =result == 1;
num_of_agreement = 0;
for y = 1:size(mask,1)
    for z = 1:size(mask,2)
        if (hemorrhage(y,z) == 1) & (mask(y,z) == 1)
            num_of_agreement = num_of_agreement  + 1;
        end
    end
end

num_of_all_white_mask = sum(sum(mask));
agreement_p = (num_of_agreement/num_of_all_white_mask)*100;
dice_score = [dice_score , dice(hemorrhage,mask)];
jaccard_coeff = [jaccard_coeff , jaccard(hemorrhage,mask)];

end
disp(['Mean dice score:',num2str(mean(dice_score))])
disp(['Mean jaccard coefficient:',num2str(mean(jaccard_coeff))])

%%
function wo_skull = skull_removal(im)
% window for skull removal
L = 400;
W = 1000;

gI = medfilt2(im);
grayImage = gI;
grayImage(grayImage< L-W/2) = L-W/2;
grayImage(grayImage> L+W/2) = L+W/2;
grayImage = im2double(grayImage);
scaled = (grayImage - min(min(grayImage)))/(max(max(grayImage)-min(min(grayImage))));

mask = im2bw(scaled,0.5); 

brain = gI;
brain(brain< 15) = 15;
brain(brain> 145) = 145;
brain = im2double(brain);
brain = (brain - min(min(brain)))/(max(max(brain)-min(min(brain))));

BW = activecontour(brain, mask);
nbhood = strel('disk', 40);
BW = imclose(BW, nbhood);
SE = strel('diamond',5);
BW = imdilate(BW,SE);


gI(gI< 0) = 0;
gI(gI> 80) = 80;
gI = im2double(gI);
gI = (gI - min(min(gI)))/(max(max(gI)-min(min(gI))));
skull_free = imfill(BW,'holes');
skull_free = skull_free.*gI;
skull_free(BW==1) = 0;
wo_skull = skull_free;
end


