function result = color_transfer(im, maxlabel, tar_index, tar_label)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% OPTIONAL: modify the label map
for i = 1:7
maxlabel(end+1, :, :) = maxlabel(end, :, :);
end
maxlabel(1:7, :, :) = [];

load('dataset/mean_lab.mat');
load('dataset/ColorSliderIndex.mat');
load ImgDataset;

input_image = im;
%input_image = imread(input_name);
im_sky = nan(size(input_image));
im_sea = nan(size(input_image));
im_sand = nan(size(input_image));

%% calculate mean/var of L/a/b for label sky/sea/sand of input image
%[~, maxlabel] = image_segmentation(input_image, 0);
% maxlabel = imresize(maxlabel, [size(input_image, 1), size(input_image, 2)]);
% maxlabel(:) = round(maxlabel(:));

im_lab = rgb2lab(input_image);

im_mean_lab_sky = zeros(1, 1, 3);
im_mean_lab_sea = zeros(1, 1, 3);
im_mean_lab_sand = zeros(1, 1, 3);
im_var_lab_sky = zeros(1, 1, 3);
im_var_lab_sea = zeros(1, 1, 3);
im_var_lab_sand = zeros(1, 1, 3);

for i = 1:size(im_lab, 1)
    for j = 1:size(im_lab, 2)
        
        if maxlabel(i, j) == 2
            im_sky(i, j, :) = im_lab(i, j, :);
        elseif maxlabel(i, j) == 3
            im_sand(i, j, :) = im_lab(i, j, :);
        elseif maxlabel(i, j) == 4
            im_sea(i, j, :) = im_lab(i, j, :);
        end
        
    end
end

im_sky = reshape(im_sky, [size(im_sky, 1)*size(im_sky, 2) 1 3]);
im_sea = reshape(im_sea, [size(im_sea, 1)*size(im_sea, 2) 1 3]);
im_sand = reshape(im_sand, [size(im_sand, 1)*size(im_sand, 2) 1 3]);
% mean and variance
for label = 1:3
    for index = 1:3
        
        if label == 1
            im_mean_lab_sky(index) = nanmean(im_sky(:, 1, index));
            im_var_lab_sky(index) = nanvar(im_sky(:, 1, index));
        elseif label == 2
            im_mean_lab_sand(index) = nanmean(im_sand(:, 1, index));
            im_var_lab_sand(index) = nanvar(im_sand(:, 1, index));
        elseif label == 3
            im_mean_lab_sea(index) = nanmean(im_sea(:, 1, index));
            im_var_lab_sea(index) = nanvar(im_sea(:, 1, index));
        end
    end
end

%% color transfer
disp('color transfer for target label');
result = im_lab;

tau = 4; % parameter for image blending

if tar_label(2) == 1 % sky
    
    MAP = zeros(size(maxlabel));
    for i = 1:size(maxlabel, 1)
        for j = 1:size(maxlabel, 2)
            if maxlabel(i, j) == 2
                MAP(i, j) = 1;
            end
        end
    end
    MAP = medfilt2(MAP, [5 5], 'symmetric');
    MAP_e = edge(MAP);
    D = bwdist(MAP_e);
      
    target_mean = reshape(mean_lab_sky(ColorSliderIndex_sky(tar_index(2)), :), [1 1 3]); % load data of target image
    
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            
            if MAP(i, j) == 1
                result(i, j, :) = im_lab(i, j, :) - im_mean_lab_sky(1, 1, :) + target_mean(1, 1, :);
            end
        end
    end
    
    % image blending
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            if D(i, j) < tau
                result(i, j, :) = (D(i, j)/tau)*result(i, j, :) + (1-D(i, j)/tau)*im_lab(i, j, :);
            end
        end
    end

end

if tar_label(3) == 1 % sand
    
    MAP = zeros(size(maxlabel));
    for i = 1:size(maxlabel, 1)
        for j = 1:size(maxlabel, 2)
            if maxlabel(i, j) == 3
                MAP(i, j) = 1;
            end
        end
    end
    MAP = medfilt2(MAP, [5 5], 'symmetric');
    MAP_e = edge(MAP);
    D = bwdist(MAP_e);
    
    target_mean = reshape(mean_lab_sand(ColorSliderIndex_sand(tar_index(3)), :), [1 1 3]); % load data of target image
    
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            
            if MAP(i, j) == 1
                result(i, j, :) = im_lab(i, j, :) - im_mean_lab_sand(1, 1, :) + target_mean(1, 1, :);
            end
        end
    end
    
    % image blending
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            if D(i, j) < tau
                result(i, j, :) = (D(i, j)/tau)*result(i, j, :) + (1-D(i, j)/tau)*im_lab(i, j, :);
            end
        end
    end

end

if tar_label(4) == 1 % sea
    
    MAP = zeros(size(maxlabel));
    for i = 1:size(maxlabel, 1)
        for j = 1:size(maxlabel, 2)
            if maxlabel(i, j) ==4
                MAP(i, j) = 1;
            end
        end
    end
    MAP = medfilt2(MAP, [5 5], 'symmetric');
    MAP_e = edge(MAP);
    D = bwdist(MAP_e);
    
    target_mean = reshape(mean_lab_sea(ColorSliderIndex_sea(tar_index(4)), :), [1 1 3]); % load data of target image
    
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            
            if MAP(i, j) == 1
                result(i, j, :) = im_lab(i, j, :) - im_mean_lab_sea(1, 1, :) + target_mean(1, 1, :);
            end
        end
    end
 
    % image blending
    for i = 1:size(im_lab, 1)
        for j = 1:size(im_lab, 2)
            if D(i, j) < tau
                result(i, j, :) = (D(i, j)/tau)*result(i, j, :) + (1-D(i, j)/tau)*im_lab(i, j, :);
            end
        end
    end

end


%% output
result = lab2rgb(result);
% figure; imshow(lab2rgb(result), []);
% title('result image (color transfer)');

%imwrite(result, 'result_color.png');
%% others
%scatter3(mean_lab_sky(:, 1), mean_lab_sky(:, 2), mean_lab_sky(:, 3), 'MarkerFaceColor', [0.1 0.2 0.3]);
end

