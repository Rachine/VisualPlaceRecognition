% EXERCISE1: basic training and testing of a classifier
% setup MATLAB and the paths
setup ;
paths = localPaths() ;
% error('missing trainLinearSVM');
% --------------------------------------------------------------------
% Stage A: Data Preparation
% --------------------------------------------------------------------

% Load the pretrained CNN

netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';

load( sprintf('%s%s.mat', paths.pretrainedCNNs, netID), 'net' ); 
net = relja_simplenn_tidy(net);

% Load the dataset and run the CNN
delta = 40 ;
city = 'Boston';
task = 'safety' ;
db = dbBoston(delta) ;
display('Compute feature representation with NetVlad');
feats = zeros(db.numImages, 4096) ;
for i=1:db.numImages
    im = getImageBatch(db.dbImageFns(i),'city',city);
%     im = vl_imreadjpeg(imPath) ;
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;
    feats(i, :) = computeRepresentation(net, im_,'useGPU',false) ;
end

% Load training data

display('Load training and test labels from db');

train = find(db.set.(task) == 1) ;
img_train = db.dbImageFns(train) ;
pos = img_train(db.safetyLabels(train) == 1) ;
neg = img_train(db.safetyLabels(train) == 2) ;
 
trainFeatures = feats(train, :) ;
% for i=1:size(names, 2)
%     trainFeatures = [trainFeatures, feats.layer_fc7(find(strcmp(feats.imgnames, names{i})), :)'] ;
% end

trainLabels = [ones(1,numel(pos)), - ones(1,numel(neg))] ;
clear pos neg ;

% Load testing data
test = find(db.set.(task) == -1) ;
img_test = db.dbImageFns(test) ;
pos = img_test(db.safetyLabels(test) == 1) ;
neg = img_test(db.safetyLabels(test) == 2) ;

testFeatures = feats(test, :) ;
% for i=1:size(testNames, 2)
%     testFeatures = [testFeatures, feats.layer_fc7(find(strcmp(feats.imgnames, testNames{i})), :)'] ;
% end

testLabels = [ones(1,numel(pos)), - ones(1,numel(neg))] ;
clear pos neg ;
    
% count how many images are there
fprintf('Number of training images: %d positive, %d negative\n', ...
    sum(trainLabels > 0), sum(trainLabels < 0)) ;
fprintf('Number of testing images: %d positive, %d negative\n', ...
    sum(testLabels > 0), sum(testLabels < 0)) ;    
% L2 normalize the histograms before running the linear SVM
%trainFeatures = bsxfun(@times, trainFeatures, 1./sqrt(sum(trainFeatures.^2,2))) ;
%testFeatures = bsxfun(@times, testFeatures, 1./sqrt(sum(testFeatures.^2,2))) ;
    
% L1 normalize the histograms before running the linear SVM
% trainFeatures = bsxfun(@times, trainFeatures, 1./sum(trainFeatures,2)) ;
% testFeatures = bsxfun(@times, testFeatures, 1./sum(testFeatures,2)) ;
    
% --------------------------------------------------------------------
% Stage B: Training a classifier
% --------------------------------------------------------------------
    
% Train the linear SVM. The SVM paramter C is cross-validated.
    
% crossind = crossvalind('Kfold', size(trainFeatures, 2), 3) ;
%     
% avg_ap = zeros(1, 5) ;
%     
% C_choice = [0.1, 15, 50, 100, 1000] ;
%     
% for C = C_choice
%         
%         for crossround=1:3
%             
%             trainFeatures_i = trainFeatures(:, crossind ~= crossround) ;
%             testFeatures_i = trainFeatures(:, crossind == crossround) ;
%             labels_i = trainLabels(crossind ~= crossround) ;
%             testLabels_i = trainLabels(crossind == crossround) ;
%             
%             [w, bias] = trainLinearSVM(trainFeatures_i, labels_i, C) ;
%             
%             % Evaluate the scores on the training data
%             scores = w' * trainFeatures_i + bias ;
%             
%             % Visualize the ranked list of images
%             figure(1) ; clf ; set(1,'name','Ranked training images (subset)') ;
%             displayRankedImageList(names, scores)  ;
%             
%             % Visualize the precision-recall curve
%             figure(2) ; clf ; set(2,'name','Precision-recall on train data') ;
%             vl_pr(labels_i, scores) ;
%             
%             % --------------------------------------------------------------------
%             % Stage C: Classify the test images and assess the performance
%             % --------------------------------------------------------------------
%             
%             % Test the linear SVM
%             testScores = w' * testFeatures_i + bias ;
%             
%             % Visualize the ranked list of images
%             %figure(3) ; clf ; set(3,'name','Ranked test images (subset)') ;
%             %displayRankedImageList(testNames, testScores)  ;
%             
%             % Visualize the precision-recall curve
%             %figure(4) ; clf ; set(4,'name','Precision-recall on test data') ;
%             %vl_pr(testLabels_i, testScores) ;
%             
%             % Print results
%             [~,~,info] = vl_pr(testLabels_i, testScores) ;
%             fprintf('Test AP: %.2f\n', info.auc) ;
%             
%             avg_ap(1, C_choice == C) = avg_ap(1, C_choice == C) + info.auc ;
%             
%             [~,perm] = sort(testScores,'descend') ;
%             fprintf('Correctly retrieved in the top 36: %d\n', sum(testLabels(perm(1:36)) > 0)) ;
%             
%         end
%         
% end
%     
%     avg_ap = avg_ap / 3 ;
%     [~, max_id] = max(avg_ap) ;
%     C_best = C_choice(max_id) ;
%     disp(C_best)
%     
    % SVM classifier with the best C
    %%
    C_best = 0.00001;
    display('Train a SVM classifier on training dataset');
    trainFeatures = trainFeatures';
    testFeatures = testFeatures';
    [w, bias] = trainLinearSVM(trainFeatures, trainLabels, C_best) ;
            
    % Evaluate the scores on the training data
    display('Evaluate scores on training');

    scores = w' * trainFeatures + bias ;
            
%     % Visualize the ranked list of images
%     figure(1) ; clf ; set(1,'name','Ranked training images (subset)') ;
%     displayRankedImageList(names, scores)  ;
%             
    % Visualize the precision-recall curve
    figure(2) ; clf ; set(2,'name','Precision-recall on train data') ;
    vl_pr(trainLabels, scores) ;
    
    % Test the linear SVM
    display('Evaluate scores on test');

    testScores = w' * testFeatures + bias ;
    
    % Visualize the ranked list of images
%     figure(3) ; clf ; set(3,'name','Ranked test images (subset)') ;
%     displayRankedImageList(testNames, testScores)  ;
    
    % Visualize the precision-recall curve
    figure(4) ; clf ; set(4,'name','Precision-recall on test data') ;
    vl_pr(testLabels, testScores) ;
    
    % Print results
    [~,~,info] = vl_pr(testLabels, testScores) ;
    fprintf('Test AP: %.2f\n', info.auc) ;
    
%     ap_array = [ap_array info.auc] ;
    
    [~,perm] = sort(testScores,'descend') ;
    fprintf('Correctly retrieved in the top 36: %d\n', sum(testLabels(perm(1:36)) > 0)) ;
