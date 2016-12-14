%%% DEMO for NETVLAD + SVM 

paths= localPaths();
netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra';
load( sprintf('%s%s.mat', paths.pretrainedCNNs, netID), 'net' );
% net= relja_simplenn_tidy(net);

% Load a test image from Wikipedia and run the model.
im = imread('/home/rachine/VisualPlaceRecognition/Databases/Boston/images/id_1_400_300.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ;
net= relja_simplenn_tidy(net);

feats= computeRepresentation(net, im_,'useGPU',falsefe);