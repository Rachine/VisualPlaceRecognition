function compute_decaf_features(image_path, image_list, features_path)
% Compute decaf featurs on the urban dataset.
% Vicente Ordonez @ UNC Chapel Hill
addpath(genpath('util'));

% Configure experiment datasource.
config.image_path = image_path;
config.layer = 'fc6_cudanet_out';
config.decaf_features_path = features_path;

% Now compute features for all images in our dataset using Decaf.
if ~exist(config.decaf_features_path, 'file')
    cd('../lib/deeplearning/exercise');
    decaf_features = runDecaf(image_list, config.layer);
    cd('../../../code');
    save(config.decaf_features_path, 'decaf_features', 'image_list', '-v7.3');
else
    disp('Features already computed');
end

end
