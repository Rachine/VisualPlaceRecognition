%%% DEMO for NETVLAD + SVM 
setup;

paths= localPaths();
netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra';
load( sprintf('%s%s.mat', paths.pretrainedCNNs, netID), 'net' );
% net= relja_simplenn_tidy(net);

% Load a test image from Wikipedia and run the model.
im = imread(strcat(paths.dsetRootBoston, 'images/id_1_400_300.jpg')) ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ;
net= relja_simplenn_tidy(net);

feats= computeRepresentation(net, im_,'useGPU',false);

delta = 10 ;
dbTest= dbBoston(delta);

dbFeatFn= sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);
qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);

% % Compute db/query image representations
serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 1); % adjust batchSize depending on your GPU / network size
% % serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1

% Measure recall@N
% [recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
% plot(opts.recallNs, recall, 'ro-'); grid on; xlabel('N'); ylabel('Recall@N');

