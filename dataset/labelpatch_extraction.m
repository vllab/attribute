function labelpatch_extraction()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

load ImgDataset256.mat;
load LabelDataset256.mat;

for index = 1:size(LabelDataset, 1)
    
    disp(index);
    im = ImgDataset{index, 1};
    label = LabelDataset{index};
    
    sky = zeros(size(im));
    sea = sky;
    sand = sky;
    for i = 1:size(im, 1)
        for j = 1:size(im, 2)
            if label(i, j, 1) >= 200 && label(i, j, 2) < 50 && label(i, j, 3) < 50
                sky(i, j, :) = im(i, j, :);
            elseif label(i, j, 3) >= 200 && label(i, j, 1) < 50 && label(i, j, 2) < 50
                sea(i, j, :) = im(i, j, :);
            elseif label(i, j, 2) >= 200 && label(i, j, 1) < 50 && label(i, j, 3) < 50
                sand(i, j, :) = im(i, j, :);
            end
        end
    end
    
    patch{index, 2} = uint8(sky);
    patch{index, 3} = uint8(sea);
    patch{index, 4} = uint8(sand);
end

save ImgPatch.mat patch;
end

