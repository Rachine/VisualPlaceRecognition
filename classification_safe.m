setup;
paths = localPaths();

opts.netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
load( sprintf('%s%s.mat', paths.pretrainedCNNs, opts.netID), 'net' );

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
opts.cityTrain = 'Boston';
opts.cityTest = 'Bosotn';

%Will be possible to train on one and test on another city

net = add_block_perso(net, opts, '8', 1, 1, 4096, 1, 1, 0) ; 
% Not forget to remove loss layer for evaluation and test 

net = relja_simplenn_tidy(net);


function [net, info] = cnn_safety(varagin)

% -------------------------------------------------------------------------
%                                                              Prepare path
% -------------------------------------------------------------------------
% 
[opts, varargin] = vl_argparse(opts, varargin) ;
setup;
paths= localPaths();

% -------------------------------------------------------------------------
%                                                              Prepare data
% -------------------------------------------------------------------------

imdb = dbBoston(opts.delta);

% Compute image statistics (mean, RGB covariances, etc.)
imageStatsPath = fullfile(opts.expDir, strcat('imageStats', imdb.name, '.mat')) ;
if exist(imageStatsPath)
    load(imageStatsPath, 'averageImage', 'rgbMean', 'rgbCovariance') ;
else
    images = imdb.dbImageFns ;
    [averageImage, rgbMean, rgbCovariance] = getImageStats(images, ...
        'imageSize', [400 300], ...
        'numThreads', opts.numFetchThreads, ...
        'gpus', opts.gpus, ...
        'city',opts.cityTrain) ;
    save('imageStats.mat', 'averageImage', 'rgbMean', 'rgbCovariance') ;
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
  net = add_block_perso(net, opts, '8', 1, 1, 4096, 1, 1, 0) ; 
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


% -------------------------------------------------------------------------
%                                                                     Learn
% -------------------------------------------------------------------------

% TODO making sure all the options suits for our network
trainFn = @cnn_train ;
getBatchFn = @getBatch;

[net, info] = trainFn(net, imdb, getBatchFn(opts, net.meta), ...
                      'expDir', opts.expDir, ...
                      net.meta.trainOpts, ...
                      opts.train) ;
                  
                  
end


% TODO Custom getBatch function with our dbBase
% Use trainWeakly.m for the inspiration
function varargout = getBatch(opts, useGpu, networkType, imdb, batch)
% -------------------------------------------------------------------------
images = strcat([imdb.imageDir filesep], imdb.images.name(batch)) ;
if ~isempty(batch) && imdb.images.set(batch(1)) == 1
  phase = 'train' ;
else
  phase = 'test' ;
end
data = getImageBatch(images, opts.(phase), 'prefetch', nargout == 0) ;
if nargout > 0
  labels = imdb.images.label(batch) ;
  switch networkType
    case 'simplenn'
      varargout = {data, labels} ;
    case 'dagnn'
      varargout{1} = {'input', data, 'label', labels} ;
  end
end
end
