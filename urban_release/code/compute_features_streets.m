
if strcmp(config.feature_type, 'decaf')
    if ~exist(config.decaf_features_path, 'file')
        image_list = cellfun(@(x){sprintf('%s/%s', config.image_path, x)}, urban.data.image_names);
        compute_decaf_features(config.image_path, data.images, config.decaf_features_path);
    else
        decaf_features = load(config.decaf_features_path);
        thefeatures = squeeze(decaf_features.decaf_features.features);
        image_list = decaf_features.image_list;
        feature_matrix = double(thefeatures);
        for i = 1 : length(image_list)
            [aa, bb, cc] = fileparts(image_list{i});
            assert(strcmp([bb cc], urban.data.image_names{i}));
        end
    end
   %urban = decaf_features.urban;
elseif strcmp(config.feature_type, 'gist')
    if ~exist(config.gist_features_path, 'file')
        data.images = cellfun(@(x){sprintf('%s/%s', config.image_path, x)}, ...
                              urban.data.image_names);
        feature_matrix = double(VisionImage.ComputeGistFeatures(data));
        image_list = data.images;
        save(config.gist_features_path, 'feature_matrix', 'image_list', 'urban', '-v7.3');
    else
        load(config.gist_features_path);
    end
elseif strcmp(config.feature_type, 'netvlad')
    if ~exist(config.netvlad_features_path, 'file') % TO DO: DEFINE PATH
        image_list = cellfun(@(x){sprintf('%s/%s', config.image_path, x)}, urban.data.image_names); % TO DO: LOAD DATA
        compute_netvlad_features(config.image_path,image_list, config.netvlad_features_path);
    else
        netvlad_features = load(config.netvlad_features_path);
        thefeatures = squeeze(netvlad_features.netvlad_features.features); % TO DO: UNDERSTAND (cleaning ?)
        image_list = netvlad_features.image_list;
        feature_matrix = double(thefeatures);
        for i = 1 : length(image_list) 
            [aa, bb, cc] = fileparts(image_list{i});
            assert(strcmp([bb cc], urban.data.image_names{i}));
        end
    end
else
    % Now create a GMM dictionary from random images taken from the dataset.
    if ~exist(config.gmm_dictionary_path, 'file')
        image_list = cellfun(@(x){sprintf('%s/%s', config.image_path, x)}, ...
                                  urban.data.image_names);
        image_list = image_list(randperm(length(image_list)));
        gmm_codebook = VisionImage.BuildSiftCodebookGmm(image_list(1:config.kCodebookSizeGmm), ...
                           config.kCodebookSizeGmm, config.kCodebookSizeGmm * 1000);
        save(config.gmm_dictionary_path, 'gmm_codebook');
    else
        load(config.gmm_dictionary_path);
    end

    % Now compute features for all images in our dataset using SIFT + Fisher Vectors.
    if ~exist(config.fisher_features_path, 'file')
        data.images = cellfun(@(x){sprintf('%s/%s', config.image_path, x)}, ...
                                   urban.data.image_names);
        feature_matrix = VisionImage.ComputeSiftFeatures(data, 'fisher', ...
                                                          config.pyramid, gmm_codebook);
        image_list = data.images;
        save(config.fisher_features_path, 'feature_matrix', 'image_list', 'urban', '-v7.3');
    else
        if ~exist('feature_matrix', 'var')
            load(config.fisher_features_path);
        end
    end
end


