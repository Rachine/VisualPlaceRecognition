function output = runNetvlad(filelist)

setup ;
paths = localPaths() ;

if(~iscell(filelist))
    error('filelist must be a cell array');
end

%save([folder '/tmp_netvlad_filelist.mat'], 'filelist');

% Loading model

netID = 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white' ;
load( sprintf('%s%s.mat', paths.pretrainedCNNs, netID), 'net' ); 
net = relja_simplenn_tidy(net);

% Compute feature representations

numImages = size(filelist(1), 1) ;
features = zeros(numImages, 4096) ;
for i=1:numImages
    im = getImageBatch(filelist(1){i}(1));
%   im = vl_imreadjpeg(imPath) ;
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;
    features(i, :) = computeRepresentation(net, im_,'useGPU',false) ;
end

output.features = features ;