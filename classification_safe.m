
function [net, info] = classification_safe(varargin)
paths = localPaths();

opts.netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';

opts.scale = 1 ;
opts.initBias = 0 ;
opts.weightDecay = 1 ;
opts.weightInitMethod = 'gaussian' ;
opts.model = 'alexnet' ;
opts.batchNormalization = false ;
opts.networkType = 'simplenn' ;
opts.cudnnWorkspaceLimit = 1024*1024*1204 ; % 1GB
opts.classNames = {} ;
opts.classDescriptions = {} ;
opts.averageImage = zeros(3,1) ;
opts.colorDeviation = zeros(3) ;
opts.loss = 'hinge';
opts.delta = 50;
opts.no_retrain = true ; % Variable to retrain or not the transferred layers from NetVlad
opts.network = [] ;
opts.expDir = paths.dsetSpecDir ;
opts.numFetchThreads = 6 ;
opts.gpus = [] ; 
opts.train = struct() ;
bs = 1 ;

%Will be possible to train on one and test on another city
opts.cityTrain = 'Boston'; % Can be NY or Boston
opts.cityTest = 'Boston'; % Can be NY or Boston
opts.task = 'safety'; % Can be safety or wealth


% -------------------------------------------------------------------------
%                                                              Prepare path
% -------------------------------------------------------------------------
% 
[opts, varargin] = vl_argparse(opts, varargin) ;
setup;


% -------------------------------------------------------------------------
%                                                              Prepare data
% -------------------------------------------------------------------------

imdb = dbBoston(opts.delta);

% Compute image statistics (mean, RGB covariances, etc.)
imageStatsPath = fullfile(opts.expDir, strcat('imageStats', imdb.name, '.mat')) ;
if exist(imageStatsPath)
    load(imageStatsPath, 'averageImage', 'rgbMean', 'rgbCovariance') ;
else
    train = find(imdb.set == 1) ;
    images = imdb.dbImageFns(train) ;
    [averageImage, rgbMean, rgbCovariance] = getImageStats(images, ...
        'imageSize', [300 400], ...
        'numThreads', opts.numFetchThreads, ...
        'gpus', opts.gpus, ...
        'city',opts.cityTrain) ;
    save(imageStatsPath, 'averageImage', 'rgbMean', 'rgbCovariance') ;
end
[v,d] = eig(rgbCovariance) ;
rgbDeviation = v*sqrt(d) ;
clear v d ;

% -------------------------------------------------------------------------
%                                                             Prepare model
% -------------------------------------------------------------------------

if isempty(opts.network)
  load( sprintf('%s%s.mat', paths.pretrainedCNNs, opts.netID), 'net' );
  opts.network = net;
%   net = add_block_perso(net, opts, '8',1, 1, 4096, 2, 1, 0) ;
    net = add_block(net, opts, '8', 1, 1, 4096, 2, 1, 0) ;

  net = relja_simplenn_tidy(net);

else
  net = opts.network ;
  opts.network = [] ;
end

% -------------------------------------------------------------------------
%            Prepare Learning rate for NetVlad architechture and last Layer
% -------------------------------------------------------------------------
% TODO Custom netPrepareForTest.m and netPrepareForTrain.m instead, still
% need to add Dropout Layers for the last layer
if opts.no_retrain
    for index = 1:30
        if isfield(net.layers{index}, 'learningRate') 
            net.layers{index}.learningRate = [0  0];
            net.layers{index}.weightDecay = [0  0];
        end
    end
    net.layers{31}.learningRate = [0  0]; % Custom NetVlad layer is a custom class not struct
    net.layers{31}.weightDecay = [0  0];
end

if ~opts.batchNormalization
  lr = logspace(-2, -4, 60) ;
else
  lr = logspace(-1, -4, 20) ;
end

net.meta.trainOpts.learningRate = lr ;
net.meta.trainOpts.numEpochs = numel(lr) ;
net.meta.trainOpts.batchSize = bs ;
net.meta.trainOpts.weightDecay = 0.0005 ;

% -------------------------------------------------------------------------
%                                                                     Learn
% -------------------------------------------------------------------------

% TODO making sure all the options suits for our network
trainFn = @cnn_train ;
getBatchFn = @getBatch;

[net, info] = trainFn(net, imdb, getBatchFn, ...
                      'expDir', opts.expDir, ...
                      net.meta.trainOpts, ...
                      opts.train) ;
                  
                  
end


% TODO Custom getBatch function with our dbBase
% Use trainWeakly.m for the inspiration
function varargout = getBatch(opts, useGpu, networkType, imdb, batch)
% -------------------------------------------------------------------------
images = imdb.dbImageFns(batch) ;
if ~isempty(batch) && imdb.set(batch(1)) == 1
  phase = 'train' ;
else
  phase = 'test' ;
end
data = getImageBatch(images,'phase', opts.(phase), 'prefetch', nargout == 0) ;
if nargout > 0
  labels = imdb.(strcat(opts.task,'Labels'))(batch) ;
  switch networkType
    case 'simplenn'
      varargout = {data, labels} ;
    case 'dagnn'
      varargout{1} = {'input', data, 'label', labels} ;
  end
end
end


% --------------------------------------------------------------------
function net = add_block(net, opts, id, h, w, in, out, stride, pad)
% --------------------------------------------------------------------
name='fc';
convOpts = {'CudnnWorkspaceLimit', opts.cudnnWorkspaceLimit} ;
net.layers{end+1} = struct('type', 'conv', 'name', sprintf('%s%s', name, id), ...
                           'weights', {{init_weight(opts, h, w, in, out, 'single'), ...
                             ones(out, 1, 'single')*opts.initBias}}, ...
                           'stride', stride, ...
                           'pad', pad, ...
                           'dilate', 1, ...
                           'learningRate', [1 2], ...
                           'weightDecay', [opts.weightDecay 0], ...
                           'opts', {convOpts}) ;
net.layers{end+1} = struct('type', 'loss','name','classification_error');

if opts.batchNormalization
  net.layers{end+1} = struct('type', 'bnorm', 'name', sprintf('bn%s',id), ...
                             'weights', {{ones(out, 1, 'single'), zeros(out, 1, 'single'), ...
                               zeros(out, 2, 'single')}}, ...
                             'epsilon', 1e-4, ...
                             'learningRate', [2 1 0.1], ...
                             'weightDecay', [0 0]) ;
end
end