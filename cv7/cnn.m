unzip('MNIST_MATLAB.zip');

[Xtrain, Ytrain] = loadMNIST( ...
    'MNIST_MATLAB/train/images.idx3-ubyte', ...
    'MNIST_MATLAB/train/labels.idx1-ubyte');

[Xtest, Ytest] = loadMNIST( ...
    'MNIST_MATLAB/test/images.idx3-ubyte', ...
    'MNIST_MATLAB/test/labels.idx1-ubyte');

function [images, labels] = loadMNIST(imageFile, labelFile)
    fid = fopen(imageFile, 'rb');
    fread(fid, 1, 'int32', 0, 'ieee-be');
    n = fread(fid, 1, 'int32', 0, 'ieee-be');
    r = fread(fid, 1, 'int32', 0, 'ieee-be');
    c = fread(fid, 1, 'int32', 0, 'ieee-be');
    images = fread(fid, inf, 'uint8');
    fclose(fid);

    images = reshape(images, [c, r, n]);
    images = permute(images, [2 1 3]);

    fid = fopen(labelFile, 'rb');
    fread(fid, 1, 'int32', 0, 'ieee-be');
    fread(fid, 1, 'int32', 0, 'ieee-be');
    labels = fread(fid, inf, 'uint8');
    fclose(fid);
end

Xtrain = reshape(double(Xtrain)/255, [28, 28, 1, size(Xtrain, 3)]);
Xtest = reshape(double(Xtest)/255, [28, 28, 1, size(Xtest, 3)]);

Ytrain = categorical(Ytrain);
Ytest = categorical(Ytest);

idx = randperm(60000);
Xtrain_train = Xtrain(:,:,:,idx(1:50000));
Ytrain_train = Ytrain(idx(1:50000));
Xval = Xtrain(:,:,:,idx(50001:60000));
Yval = Ytrain(idx(50001:60000));


layers = [
    imageInputLayer([28 28 1])

    convolution2dLayer(5, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2) 

    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2) 

    convolution2dLayer(3, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    
    %fullyConnectedLayer(128)
    %reluLayer
    %dropoutLayer(0.5) 
    %dropoutLayer(0.3) 
    %dropoutLayer(0.7)
    fullyConnectedLayer(10) 
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 30, ... 
    'Shuffle', 'every-epoch', ...
    'ValidationData', {Xval, Yval}, ...
    'ValidationFrequency', 30, ...  
    'ValidationPatience', 65, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto');
    

[net_cnn, info] = trainNetwork(Xtrain_train, Ytrain_train, layers, options);
vl = info.ValidationLoss;
vl_clean = vl(~isnan(vl));  % odstranenie Nan

[min_val_loss, min_idx] = min(vl_clean);
overfit_epoch = min_idx * 30 / 390; % vypocet epoch
[YPred, scores] = classify(net_cnn, Xtest); % predikcia na testovacích dátach
YPred_train = classify(net_cnn, Xtrain_train);
accuracy = sum(YPred == Ytest) / numel(Ytest) * 100;
Y_true = dummyvar(double(Ytest));
test_loss = -mean(sum(Y_true .* log(scores + eps), 2));
% vypis
fprintf('Min val loss: %.4f | Epocha začiatku pretrénovania: %.1f\n', min_val_loss, overfit_epoch);
fprintf("Train loss: %.4f.\n",info.TrainingLoss(min_idx*30));
fprintf('Celková úspešnosť CNN na testovacích dátach: %.2f%%\n', accuracy);
fprintf('Finálny Test Loss: %.6f\n', test_loss);

figure;
plotconfusion(Ytrain_train, YPred_train);
figure;
plotconfusion(Ytest, YPred);
title('Confusion Matrix: CNN Model');


figure('Name', 'Vizuálna verifikácia CNN');
for i = 0:9
    idx = find(Ytest == i, 1); 
    img = Xtest(:,:,:,idx);
    
    [pred, skore] = classify(net_cnn, img);
    
    subplot(2, 5, i+1);
    imshow(img);
    title(['S: ' num2str(i) ' | P: ' char(pred)]);
    xlabel(['Pravd: ' num2str(max(skore)*100, '%.1f') '%']);
end