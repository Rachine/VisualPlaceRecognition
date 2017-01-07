paths= localPaths();
rmpath('/home/rachine/VisualPlaceRecognition/urban_release/lib/LLC/Liblinear/matlab/'); 
run( fullfile(paths.libMatConvNet, 'matlab', 'vl_setupnn.m') );
addpath('/home/rachine/VisualPlaceRecognition/urban_release/lib/LLC/Liblinear/matlab/'); 

addpath( genpath(paths.libReljaMatlab) );
addpath( genpath(paths.libYaelMatlab) );

NetVLADRoot= fileparts(mfilename('fullpath'));
addpath(NetVLADRoot);
addpath(fullfile(NetVLADRoot, 'datasets/'));
clear NetVLADRoot;
