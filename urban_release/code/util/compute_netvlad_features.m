function compute_netvlad_features(image_path, image_list, features_path)
% Compute netvlad features on the urban dataset.
% Vicente Ordonez @ UNC Chapel Hill
% Contribution of Rachid and Kimia
addpath(genpath('util'));

% Configure experiment datasource.
config.image_path = image_path;
config.netvlad_features_path = features_path;

% Now compute features for all images in our dataset using Netvlad.
if ~exist(config.netvlad_features_path, 'file')
    cd('../');
    netvlad_features = runNetvlad(image_list);
    cd('urban_release/code/util');
    save(config.netvlad_features_path, 'netvlad_features', 'image_list', '-v7.3');
    cd('../../');
else
    disp('Features already computed');
end

end
