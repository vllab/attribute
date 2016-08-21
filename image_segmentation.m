function [scores, maxlabel] = image_segmentation(im, use_gpu)
% FCN for scene segmentation

% Add caffe/matlab to you Matlab search PATH to use matcaffe
if exist('../../matlab/+caffe', 'dir')
  addpath('../../matlab');
else
  error('Please run this demo from caffe/matlab/demo');
end

% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
  caffe.set_mode_gpu();
  gpu_id = 0;  % we will use the first gpu in this demo
  caffe.set_device(gpu_id);
else
  caffe.set_mode_cpu();
end

model_dir = '/mnt/data/isc/caffe-master/projects/ImageEditing/models/FCN/';
net_model = [model_dir 'deploy(original).prototxt'];
net_weights = [model_dir '_iter_68000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please download CaffeNet from Model Zoo before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

if nargin < 1
  % For demo purposes we will use the cat image
  fprintf('using caffe/examples/images/cat.jpg as input image\n');
  im = imread('../../examples/images/cat.jpg');
end

% prepare oversampled input
% input_data is Width x Height x Channel x Num
tic;
input_data = {prepare_image(im)};
toc;

% do forward pass to get scores
% scores are now Channels x Num, where Channels == 4
tic;
% The net forward function. It takes in a cell array of N-D arrays
% (where N == 4 here) containing data of input blob(s) and outputs a cell
% array containing data from output blob(s)
scores = net.forward(input_data);
toc;
scores = scores{1}; % from cell form to array form

scores = permute(scores, [2, 1, 3, 4]);
[~, maxlabel] = max(scores, [], 3);

% call caffe.reset_all() to reset caffe
caffe.reset_all();

% ------------------------------------------------------------------------
function output_data = prepare_image(im)
% ------------------------------------------------------------------------
IMAGE_DIM = 500;

mean_data = zeros(1, 1, 3, 'single');
mean_data(:) = [104.1091 131.3360 116.4144]; % mean data in BGR form
mean_data = repmat(mean_data, IMAGE_DIM, IMAGE_DIM);

% Convert an image returned by Matlab's imread to im_data in caffe's data
% format: W x H x C with BGR channels
im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
im_data = permute(im_data, [2, 1, 3]);  % flip width and height
im_data = single(im_data);  % convert from uint8 to single
im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
im_data = im_data - mean_data;  % subtract mean_data (already in W x H x C, BGR)

output_data = zeros(IMAGE_DIM, IMAGE_DIM, 3, 1, 'single'); % output in W x H x C x N
output_data(:, :, :, 1) = im_data;
