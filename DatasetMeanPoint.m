function [ output_args ] = DatasetMeanPoint( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
load('dataset/mean_lab.mat');

for i = 1:size(mean_lab_sky, 1)
    DatasetLabel_lab(i, 1) = mean(mean_lab_sky(i, :));
    DatasetLabel_lab(i, 2) = mean(mean_lab_sea(i, :));
    DatasetLabel_lab(i, 3) = mean(mean_lab_sand(i, :));
end


end