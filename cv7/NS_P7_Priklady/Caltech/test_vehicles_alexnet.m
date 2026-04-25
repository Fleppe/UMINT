% Demo - Alexnet - vozidla

% nacitanie obrazkov
clear
rootFolder = fullfile(cd, 'Data2');
categories = {'airplanes', 'bus', 'car','motorbikes'};

imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

tbl = countEachLabel(imds)

minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
minSetCount=200;

% vyber z datasetu tak, aby v kazdej skupine bol rovnaky pocet obrazov
imds = splitEachLabel(imds, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)

% Find the first instance of an image for each category
airplanes = find(imds.Labels == 'airplanes', 1);
bus = find(imds.Labels == 'bus', 1);
car = find(imds.Labels == 'car', 1);
motorbikes = find(imds.Labels == 'motorbikes', 1);

% zobrazenie nahodnych obrazov z tried
figure
subplot(2,2,1);
imshow(readimage(imds,airplanes))
subplot(2,2,2);
imshow(readimage(imds,bus))
subplot(2,2,3);
imshow(readimage(imds,car))
subplot(2,2,4);
imshow(readimage(imds,motorbikes))

% Location of pre-trained "AlexNet"
net = alexnet;

% View the CNN architecture
net.Layers

% Inspect the first layer
net.Layers(1)

% Inspect the last layer
net.Layers(end)

% Number of class names for ImageNet classification task
numel(net.Layers(end).ClassNames)

% funkcia na nacitavanie obrazov
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

% rozdelenie dat na trenovacie / testovacie
[trainingSet, testSet] = splitEachLabel(imds, 0.6, 'randomize');

% prenesena struktura
layersTransfer = net.Layers(1:end-3);

numClasses = 4; % pocet tried
% nova struktura
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

% parametre trenovania
miniBatchSize = 20;
numIterationsPerEpoch = floor(numel(trainingSet.Labels)/miniBatchSize);
options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',2,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',testSet,...
    'ValidationFrequency',numIterationsPerEpoch);

% trenovanie siete
netTransfer = trainNetwork(trainingSet,layers,options);

% testovanie náhodných vzoriek
inputSize=227;
numtestimage=12;
figure
idx = randperm(numel(testSet.Labels),20);
for i = 1:numtestimage
    I=imread(testSet.Files{idx(i)});
    if ismatrix(I)
        I = cat(3,I,I,I);
    end    
    Ir = imresize(I,[inputSize inputSize]);
    subplot(3,4,i)
    image(Ir)
    [label,score] = classify(netTransfer,Ir);
    title({char(label), num2str(max(score),2)});
end

% vypocet vystupu siete pre validacne (testovacie data)
YPred = classify(netTransfer,testSet);
YTest = testSet.Labels;

% vypocet uspesnosti pre tesovacie data
accuracy = sum(YPred == YTest)/numel(YTest)

% kontingencna matica
figure
plotconfusion(YTest,YPred)

% Zobrazenie filtrov
% % Get the network weights for the second convolutional layer
w1 = netTransfer.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5);

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
figure
montage(w1)
title('First convolutional layer weights')


% Get the network weights for the next convolutional layer
w2 = netTransfer.Layers(6).Weights;

% Scale and resize the weights for visualization
w2b = mat2gray(w2(:,:,1:3,:));
w2b = imresize(w2b,5);

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
figure
montage(w2b)
title('next convolutional layer weights')

% Zobrazenie mapy priznakov
indxtest=10;
im = imread(testSet.Files{indxtest});             % vstupny obraz
im = imresize(im,[inputSize inputSize]);
figure
imshow(im)

name='conv1';                          % meno vrstvy pre zobr. priznakov
% name='conv2';                          % meno vrstvy pre zobr. priznakov
% name='pool5';
act6 = activations(netTransfer,im,name);     % aktivacia def. vrstvy
sz = size(act6);
act6 = reshape(act6,[sz(1) sz(2) sz(3)]);       % rozdelenie map 

I = imtile(act6,'GridSize',[10 10]);                   % rozdelenie do gridu
figure
imshow(I)
