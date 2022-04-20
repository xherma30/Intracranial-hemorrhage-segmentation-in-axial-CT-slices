clc,clear all,close all
load("skullFree.mat")
index = 7; %number between 1 and 26
im = scans.adjusted{1,index};
im = medfilt2(im,[4 4]);
%% seed initialization
waitfor(msgbox("Mark any number of hemorrhages:"));
imshow(im,[])
for i = 1:5
    [x_point,y_point] = ginput(1);
    hold on
    x(i) = round(x_point);
    y(i) = round(y_point);
    plot(x(i), y(i), 'r+');
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
    % narust oblasti (nasledujici iterace)
    while (ending == 0)
        ending = 1;
        indexes = find(new_x);   % vyhleda indexy nenulovych prvku v promenne souradnic
        n = length(indexes);     % zjisti pocet prvku pro tento krok cyklu
        % promenna pro podminku ukoncujici cyklus
        stop(2:len) = stop(1:len-1);    % zapomenuti nejstarsi hodnoty
        stop(1) = n;    % nova hodnota
        % promenne souradnic novych vych. bodu
        orig_x = zeros(1,n);
        orig_y = zeros(1,n);
        orig_x = new_x(indexes);
        orig_y = new_y(indexes);
        % testovani okoli z novych vych. bodu
        for i = 1:n
            [new_x(step(i):step(i)+7),new_y(step(i):step(i)+7),im] = area(im,orig_y(i),orig_x(i),orig);

        end
        %podminka ukonceni
        if not(stop(1) == sum(stop)/len)
            ending = 0;
        end
        % prubezne zobrazeni
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
cd("C:\Users\ddoko\Desktop\ABO\projekt\Hemoragie\Masks_subset")
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

%% Comparison
im = im==0.2;
im = imfill(im,'holes');
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
