function [ output_args ] = SliderGeneration()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load ImgDataset256.mat;
load ImagePatch.mat; % contain a cell named 'ImgPatch'

%% use HSV color space
mean_sky = zeros(size(ImgPatch, 1), 3);
mean_sea = mean_sky;
mean_sand = mean_sky;

for index = 1:size(ImgPatch, 1)
    
    disp(index);
    for c = 2:4 % sky/sand/sea
        HSV = rgb2hsv(ImgPatch{index, c});
        
        for i = 1:size(HSV, 1)
            for j = 1:size(HSV, 2)
                
                if HSV(i, j, 1) == 0 && HSV(i, j, 2) == 0 && HSV(i, j, 3) == 0
                    HSV(i, j, :) = [nan nan nan];
                end
            end
        end
        for k = 1:3 % H\S\V    
          
            data = reshape(HSV(:, :, k), [size(HSV, 1)*size(HSV, 2) 1]);
            % calculate mean
            if c == 2
                mean_sky(index, k) = nanmean(data);
            elseif c == 3
                mean_sand(index, k) = nanmean(data);
            elseif c == 4
                mean_sea(index, k) = nanmean(data);
            end
        end
    end
    
end

%% calculate mean of R/G/B for sky/sea/sand
% mean_rgb_sky = zeros(size(ImgPatch, 1), 3);
% mean_rgb_sea = mean_rgb_sky;
% mean_rgb_sand = mean_rgb_sky;
% 
% for index = 1:size(ImgPatch, 1)
%     
%     disp(index);
%     for c = 2:4 % sky/sand/sea
%         rgb = double(ImgPatch{index, c});
%         
%         for i = 1:size(rgb, 1)
%             for j = 1:size(rgb, 2)
%                 
%                 if rgb(i, j, 1) == 0 && rgb(i, j, 2) == 0 && rgb(i, j, 3) == 0
%                     rgb(i, j, :) = [nan nan nan];
%                 end
%             end
%         end
%         for k = 1:3 % R/G/B   
%           
%             data = reshape(rgb(:, :, k), [size(rgb, 1)*size(rgb, 2) 1]);
%             % calculate mean and variance
%             if c == 2
%                 mean_rgb_sky(index, k) = nanmean(data);
%             elseif c == 3
%                 mean_rgb_sand(index, k) = nanmean(data);
%             elseif c == 4
%                 mean_rgb_sea(index, k) = nanmean(data);
%             end
%         end
%     end
%     
% end

%% sky
[score, ColorSliderIndex_sky] = sort(mean_sky(:, 1));
for i = size(score):-1:1
    
    if isnan(score(i))
        ColorSliderIndex_sky(i) = [];
    end
end

i=1;
for x = 1:size(ColorSliderIndex_sky)
    disp(x);
    
    ColorBar_sky(1:150, (i-1)*20+1:i*20, 1) = mean_sky(ColorSliderIndex_sky(x), 1);
    ColorBar_sky(1:150, (i-1)*20+1:i*20, 2) = 0.9;%mean_sky(ColorSliderIndex_sky(x), 2);
    ColorBar_sky(1:150, (i-1)*20+1:i*20, 3) = 0.9;%mean_sky(ColorSliderIndex_sky(x), 3);
%     ColorBar_sky(1:150, (i-1)*20+1:i*20, 1) = mean_rgb_sky(ColorSliderIndex_sky(x), 1);
%     ColorBar_sky(1:150, (i-1)*20+1:i*20, 2) = mean_rgb_sky(ColorSliderIndex_sky(x), 2);
%     ColorBar_sky(1:150, (i-1)*20+1:i*20, 3) = mean_rgb_sky(ColorSliderIndex_sky(x), 3);
    i = i+1;
end
% ColorBar_sky = uint8(ColorBar_sky);
% imwrite(ColorBar_sky, 'ColorSlider_sky.png');
imwrite(hsv2rgb(ColorBar_sky), 'ColorSlider_sky.png');

clear score;

    
%% sea
[score, ColorSliderIndex_sea] = sort(mean_sea(:, 1));
for i = size(score):-1:1
    
    if isnan(score(i))
        ColorSliderIndex_sea(i) = [];
    end
end

i=1;
for x = 1:size(ColorSliderIndex_sea)
    disp(x);
    
    ColorBar_sea(1:150, (i-1)*20+1:i*20, 1) = mean_sea(ColorSliderIndex_sea(x), 1);
    ColorBar_sea(1:150, (i-1)*20+1:i*20, 2) = 0.9;%mean_sea(ColorSliderIndex_sea(x), 2);
    ColorBar_sea(1:150, (i-1)*20+1:i*20, 3) = 0.9;%mean_sea(ColorSliderIndex_sea(x), 3);
%     ColorBar_sea(1:150, (i-1)*20+1:i*20, 1) = mean_rgb_sea(ColorSliderIndex_sea(x), 1);
%     ColorBar_sea(1:150, (i-1)*20+1:i*20, 2) = mean_rgb_sea(ColorSliderIndex_sea(x), 2);
%     ColorBar_sea(1:150, (i-1)*20+1:i*20, 3) = mean_rgb_sea(ColorSliderIndex_sea(x), 3);
    i = i+1;
end
% ColorBar_sea = uint8(ColorBar_sea);
% imwrite(ColorBar_sea, 'ColorSlider_sea.png');
imwrite(hsv2rgb(ColorBar_sea), 'ColorSlider_sea.png');

clear score;    
    
 %% sand
[score, ColorSliderIndex_sand] = sort(mean_sand(:, 1));
for i = size(score):-1:1
    
    if isnan(score(i))
        ColorSliderIndex_sand(i) = [];
    end
end

i=1;
for x = 1:size(ColorSliderIndex_sand)
    disp(x);
    
    ColorBar_sand(1:150, (i-1)*20+1:i*20, 1) = mean_sand(ColorSliderIndex_sand(x), 1);
    ColorBar_sand(1:150, (i-1)*20+1:i*20, 2) = 0.9;%mean_sand(ColorSliderIndex_sand(x), 2);
    ColorBar_sand(1:150, (i-1)*20+1:i*20, 3) = 0.9;%mean_sand(ColorSliderIndex_sand(x), 3);
%     ColorBar_sand(1:150, (i-1)*20+1:i*20, 1) = mean_rgb_sand(ColorSliderIndex_sand(x), 1);
%     ColorBar_sand(1:150, (i-1)*20+1:i*20, 2) = mean_rgb_sand(ColorSliderIndex_sand(x), 2);
%     ColorBar_sand(1:150, (i-1)*20+1:i*20, 3) = mean_rgb_sand(ColorSliderIndex_sand(x), 3);

    i = i+1;
end
% ColorBar_sand = uint8(ColorBar_sand);
% imwrite(ColorBar_sand, 'ColorSlider_sand.png');
imwrite(hsv2rgb(ColorBar_sand), 'ColorSlider_sand.png');

clear score;
end

