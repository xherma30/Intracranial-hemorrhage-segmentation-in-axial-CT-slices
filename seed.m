clc,clear all,close all
%% Loading a CT scan
load("skullFree.mat")
%Choose a number bewteen 1 and 26
index = 18;
im = scans.adjusted{1,index};
im = medfilt2(im,[4 4]);
%% Seed initialization
waitfor(msgbox("Mark any number of hemorrhages:"));
imshow(im,[])
for i = 1:10 %up to ten seeds in one picture
    title("Click on a hemorrhage:")
    [x_point,y_point] = ginput(1);
    hold on
    x(i) = round(x_point);
    y(i) = round(y_point);
    plot(x(i), y(i), 'rx','LineWidth',2);
    promptMessage = sprintf('Would you like to mark another hemorrhage?');
    titleBarCaption = 'Mark the hemorrhage';
    buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
    if strcmpi(buttonText, 'No')
        break
    else strcmpi(buttonText, 'Yes')
    end
end

step = zeros(1,1000);
step(1) = 1;
for i=2:10000
    step(i) = step(i-1) + 8;
end

ending = 0;
len = 50;
stop = zeros(1,len);

scan = zeros(size(scans.im{1,index}));
for idx = 1:length(x)   
    orig = im(y(idx),x(idx));
    [new_x,new_y,im] = area(im,y(idx),x(idx),orig);
    while (ending == 0)
        ending = 1;
        indexes = find(new_x); 
        n = length(indexes);    
        stop(2:len) = stop(1:len-1);
        stop(1) = n;
        % coordinates of the new originating points
        orig_x = zeros(1,n);
        orig_y = zeros(1,n);
        orig_x = new_x(indexes);
        orig_y = new_y(indexes);
        % testing the area from new points
        for i = 1:n
            [new_x(step(i):step(i)+7),new_y(step(i):step(i)+7),im] = area(im,orig_y(i),orig_x(i),orig);
        end
        if not(stop(1) == sum(stop)/len)
            ending = 0;
        end
        pause(0.01);
        imshow(im,[]);    
    end    
    scan = scan + im;
    title('Segmented image');
    if ending == 1 & idx < length(x)
        ending = 0;
    end
end

%% Loading the masks
cd("C:\Users\ddoko\Desktop\ABO\projekt\Hemoragie\Masks_subset") %path for a folder with the masks
masks_subset = dir('*.dcm');

filename = [];
for idx = 1:size(masks_subset,1) %loads all masks
    filename = masks_subset(idx).name;
    mask = dicomread(filename);
    masks.nazev{idx} = {filename};
    masks.mask{idx} = {mask};
    masks.mask{idx} = masks.mask{1,idx}{1,1};
    masks.mask{idx} = imbinarize(masks.mask{idx});
end

%% Comparison
im = im==0.2;
im = imfill(im,'holes'); %fills holes in a bleeding
figure
subplot 121
imshow(im,[])
title("Our output")
subplot 122
imshow(masks.mask{1,index},[])
title("Original mask")

%% Validation
num_of_pixels = im^2;
hemorrhage = im;
mask = masks.mask{1,index} == 1;
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
dice_score = dice(hemorrhage,mask);
jaccard_coeff = jaccard(hemorrhage,mask);
