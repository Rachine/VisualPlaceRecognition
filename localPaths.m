
function paths= localPaths()
    
    % --- dependencies
    
    % refer to README.md for the information on dependencies
    workdir = pwd;
    paths.libReljaMatlab= strcat(workdir,'/','relja_matlab/');
    paths.libMatConvNet= strcat(workdir,'/','matconvnet/'); % should contain matlab/
    
    % If you have installed yael_matlab (**highly recommended for speed**),
    % provide the path below. Otherwise, provide the path as 'yael_dummy/':
    % this folder contains my substitutes for the used yael functions,
    % which are **much slower**, and only included for demonstration purposes
    % so do consider installing yael_matlab, or make your own faster
    % version (especially of the yael_nn function)
    paths.libYaelMatlab= strcat(workdir,'/','/yael_matlab/');
    
    % --- dataset specifications
    
    paths.dsetSpecDir= strcat(workdir,'/','datasets/datasets');
    
    % --- dataset locations
    paths.dsetRootPitts= strcat(workdir,'/','Databases/Pittsburgh/'); % should contain images/ and queries/
    paths.dsetRootTokyo247= strcat(workdir,'/','Databases/Tokyo247/'); % should contain images/ and query/
    paths.dsetRootTokyoTM= strcat(workdir,'/','Databases/TokyoTM/tinyTimeMachine/'); % should contain images/
    paths.dsetRootOxford= strcat(workdir,'/','Relja/Work/Databases/OxfordBuildings/'); % should contain images/ and groundtruth/, and be writable
    paths.dsetRootParis= strcat(workdir,'/','Relja/Work/Databases/Paris/'); % should contain images/ (with subfolders defense, eiffel, etc), groundtruth/ and corrupt.txt, and be writable
    paths.dsetRootHolidays= strcat(workdir,'/','Relja/Work/Databases/Holidays/'); % should contain jpg/ for the original holidays, or jpg_rotated/ for rotated Holidays, and be writable
    paths.dsetRootNY= strcat(workdir,'/','Databases/NY/'); % should contain jpg/ for the original holidays, or jpg_rotated/ for rotated Holidays, and be writable
    paths.dsetRootBoston= strcat(workdir,'/','Databases/Boston/'); % should contain jpg/ for the original holidays, or jpg_rotated/ for rotated Holidays, and be writable

     % --- our networks
    % models used in our paper, download them from our research page
    paths.ourCNNs= strcat(workdir,'/','Data/models/');
    
    % --- pretrained networks
    % off-the-shelf networks trained on other tasks, available from the MatConvNet
    % website: http://www.vlfeat.org/matconvnet/pretrained/
    paths.pretrainedCNNs= strcat(workdir,'/','Data/pretrained/');
    
    % --- initialization data (off-the-shelf descriptors, clusters)
    % Not necessary: these can be computed automatically, but it is recommended
    % in order to use the same initialization as we used in our work
%     paths.initData= strcat(workdir,'/','Data/netvlad/initdata/');
    
    % --- output directory
    paths.outPrefix= strcat(workdir,'/','output/');
end