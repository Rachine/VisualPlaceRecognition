% Plot the comparaison results on the same plots
% Rachid Riad 

addpath(genpath('/home/rachine/Documents/MVA/Object Recognition/practical-category-recognition-2015a/vlfeat')); vl_setup;
addpath(genpath('../lib/liblinear-1.94/matlab'));
addpath(genpath('../lib/gist'));
addpath(genpath('util'));

% Set unique experiment identifier.
config.experiment_id = 'urbanperception';

% Configure experiment datasource for 2011 images.
%config.homedir = '/mnt/raid/data/vicente/urbanperception/';
config.homedir = pwd;
config.datasource = 'placepulse_2011';
config.image_url = ['http://localhost:8000/data/' config.datasource '/images'];
config.image_path = [config.homedir '/data/' config.datasource '/images'];
config.urban_data_file = [config.homedir '/data/' config.datasource '/consolidated_data_jsonformatted.json'];
%%config.urban_data_file = [config.homedir '/data/' config.datasource '/consolidated_data.csv'];
%%config.urban_data_file_type = 'csv';
config.urban_data_file_type = 'json';

% Netvlad features configuration.
config.netvlad_features_path = [config.homedir '/output/' config.datasource '/netvlad_features.mat'];

% Gist features configuration.
config.gist_features_path = [config.homedir '/output/' config.datasource '/gist_features.mat'];

% Decaf features configuration.
config.decaf_layer = 'fc6_cudanet_out';
config.decaf_features_path = [config.homedir '/output/' config.datasource '/decaf_features_' config.decaf_layer '.mat'];

% Sift features with Fisher Vectors settings.
config.kCodebookSizeGmm = 128;
config.gmm_dictionary_path = [config.homedir '/output/' config.datasource '/gmm_dictionary.mat'];
config.pyramid = {[1 1], [2 2]};
config.fisher_features_path = [config.homedir '/output/' config.datasource '/fisher_features.mat'];

% Configure output directory.
config.output_path = [config.homedir '/output/' config.datasource];

% Load list of cities in the dataset.
cities = UrbanPerception.ListCities();

% Print and save comparaison results
metric_set = {'safer', 'unique', 'upperclass'};
cities_harder = cities(end:-1:1);

config.features_type = {'gist','fisher','netvlad_alexnet','netvlad_vgg'};
config.features_color = {[0.6 0.3 0.1],'blue','red','green'};
config.features_symbol = {'*','x','o','+'};
config.year = '2011';


config.plots_comparison_path = [config.output_path,'/plots_comparison'];
ensuredir(config.plots_comparison_path);
delta_set = [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.5];
for metric_ind = 1 : length(metric_set)

metric_str = metric_set{metric_ind};
for city_ind = 1 : length(cities)
    city_string = cities{city_ind};
    city_string_harder = cities_harder{city_ind};
    city_identifier = regexprep(lower(city_string), ' ', '_');
figure;  hold on;
ensuredir(sprintf('%s/%s_%s/%s', config.plots_comparison_path, ...
                      config.experiment_id, city_identifier, metric_str))
for feature_ind = 1 : length(config.features_type)
    feature_type = config.features_type{feature_ind};
    color = config.features_color{feature_ind};
    marker = config.features_symbol{feature_ind};
    results.feature_type = load([config.output_path,'/classification_results_',feature_type,config.year,'/',config.experiment_id,'_',city_identifier,'/',metric_str,'/results.mat']);
    h(feature_ind) = line(delta_set, mean(results.feature_type.delta_aucs, 2), 'Color', color,'Marker',marker);

end
legend(h,'gist','fisher','netvlad with alexnet','netvlad with vgg');
axis([0 0.55 0.5 1]);grid;
xlabel('delta \delta');
ylabel('Average accuracy');
print('-dpng', '-r0', sprintf('%s/%s_%s/%s/results.png', ...
                            config.plots_comparison_path, config.experiment_id, ...
                            city_identifier, metric_str));
    close;    
end
end