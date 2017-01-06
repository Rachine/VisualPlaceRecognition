%% STEP 1: INSTALL DECAF
% Go to decaf-release folder in terminal/cygwin, and type:
% python setup.by build
%
% If it works, congratulations! If not raise your hand to get help!

%% RUNNING CLASSIFICATION ON SAMPLE IMAGES

load class_names;
filelist = {[pwd '/mug.jpg'], [pwd '/car.jpg']};
layer = 'final';

% valid values for layer variable:
% 'pool5_cudanet_out': the last convolutional layer output, of size 6x6x256.
% 'fc6_cudanet_out': the 4096 dimensional feature after the first fully connected layer.
% 'fc6_neuron_cudanet_out': similar to the above feature, but after ReLU so the negative part is cropped out.
% 'fc7_cudanet_out': the 4096 dimensional feature after the second fully connected layer.
% 'fc7_neuron_cudanet_out': similar to the above feature, but after ReLU so the negative part is cropped out. This is the feature that goes into the final logistic regressor.

output = runDecaf(filelist, layer);
subplot(2,1,1);

for i=1:length(filelist)
    img = imread(filelist{i});
    [~, idx] = sort(output.scores(i, :), 'descend');
    subplot(2,1,i);
    imshow(img);
    title(['top class: ' class_names{idx(1)}]);
    fprintf('Image: %s\n', filelist{i});
    fprintf('Top 10 classes: ');
    for j=1:10
        fprintf('%s, ', class_names{idx(j)});
    end
    fprintf('\n');
end

%% STEP 2: INTEGRATE DECAF WITH YESTERDAY'S IMAGES