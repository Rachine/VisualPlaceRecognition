%%% DEMO for NETVLAD + SVM 
setup;

paths = localPaths();
netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
load( sprintf('%s%s.mat', paths.pretrainedCNNs, netID), 'net' ); 
% opts.scale = 1 ;
% opts.initBias = 0 ;
% opts.weightDecay = 1 ;
% %opts.weightInitMethod = 'xavierimproved' ;
% opts.weightInitMethod = 'gaussian' ;
% opts.batchNormalization = false ;
% opts.networkType = 'simplenn' ;
% opts.cudnnWorkspaceLimit = 1024*1024*1204 ; % 1GB
% opts.classNames = {} ;
% opts.classDescriptions = {} ;
% opts.averageImage = zeros(3,1) ;
% opts.colorDeviation = zeros(3) ;
% opts.loss = 'hinge';

opts.scale = 1 ;
opts.initBias = 0 ;
opts.weightDecay = 1 ;
%opts.weightInitMethod = 'xavierimproved' ;
opts.weightInitMethod = 'gaussian' ;
opts.model = 'alexnet' ;
opts.batchNormalization = false ;
opts.networkType = 'simplenn' ;
opts.cudnnWorkspaceLimit = 1024*1024*1204 ; % 1GB
opts.classNames = {} ;
opts.classDescriptions = {} ;
opts.averageImage = zeros(3,1) ;
opts.colorDeviation = zeros(3) ;
% opts = vl_argparse(opts, varargin) ;



net = add_block_perso(net, opts, '8', 1, 1, 4096, 1, 1, 0) ; 
% net.layers{end+1} = struct('type', 'softmaxloss') ; % add loss layer
net= relja_simplenn_tidy(net);
   
    
% Load a test image from Wikipedia and run the model.
im = imread(strcat(paths.dsetRootBoston, 'images/id_1_400_300.jpg')) ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ;

% delta = 10 ;
% dbTest= dbBoston(delta);


feats= computeRepresentation(net, im_,'useGPU',false)


