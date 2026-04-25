% Food-101: download only if needed, otherwise reuse existing files
rootDir    = fullfile(pwd, "data2");
archiveFile = fullfile(rootDir, "food-101.tar.gz");
datasetDir  = fullfile(rootDir, "food-101");

if ~isfolder(rootDir)
    mkdir(rootDir);
end

% 1) load local
if isfolder(datasetDir)
    disp("Food-101 uz existuje, download sa preskakuje.");

% 2) unzip
elseif isfile(archiveFile)
    disp("Nasiel sa archiv Food-101, rozbalujem bez downloadu...");
    untar(archiveFile, rootDir);

% 3) download
else
    disp("Food-101 sa nenasiel, stahujem dataset...");
    url = "https://data.vision.ee.ethz.ch/cvl/food-101.tar.gz";
    websave(archiveFile, url);
    untar(archiveFile, rootDir);
end

%split rovnako ako v torchvision dataset->Food101
imagesDir = fullfile(datasetDir, "images");
metaDir   = fullfile(datasetDir, "meta");

trainList = readlines(fullfile(metaDir, "train.txt"));
testList  = readlines(fullfile(metaDir, "test.txt"));

trainList = trainList(strlength(trainList) > 0);
testList  = testList(strlength(testList) > 0);

trainFiles  = fullfile(imagesDir, cellstr(trainList + ".jpg"));
testFiles   = fullfile(imagesDir, cellstr(testList + ".jpg"));

trainLabels = categorical(extractBefore(trainList, "/"));
testLabels  = categorical(extractBefore(testList, "/"));











imdsTrain = imageDatastore(trainFiles, "Labels", trainLabels);
imdsTest  = imageDatastore(testFiles,  "Labels", testLabels);

keepClasses = [
    "apple_pie"
    "caesar_salad"
    "clam_chowder"
    "edamame"
    "french_fries"
    "hamburger"
    "hot_dog"
    "ice_cream"
    "sushi"
    "waffles"
];

idxTrain = ismember(string(imdsTrain.Labels), keepClasses);
idxTest  = ismember(string(imdsTest.Labels),  keepClasses);

imdsTrain10 = subset(imdsTrain, find(idxTrain));
imdsTest10  = subset(imdsTest,  find(idxTest));

% toto je dolezite:
imdsTrain10.Labels = removecats(imdsTrain10.Labels);
imdsTest10.Labels  = removecats(imdsTest10.Labels);

classes = categories(imdsTrain10.Labels);
numClasses = numel(classes);

[imdsTrainFinal, imdsVal] = splitEachLabel(imdsTrain10, 0.8, 'randomized');

%% --- KONFIGURÁCIA TRÉNOVANIA ---
%% 2. KONFIGURÁCIA JEDNÉHO EXPERIMENTU (Toto meň)
% --- NASTAVENIE ---
modelName = "alexnet";      % Možnosti: "vgg16", "resnet18", "mobilenetv2"
useTransferLearning = true;  % true = Transfer Learning | false = From Scratch
useAugmentation = true;     % true = zapne augmentáciu | false = bez augmentácie
% ------------------
% Rozmer vstupu (ResNet/MobileNet: 224, VGG: 224, AlexNet: 227)
inputSize = [227 227 3]; 

% Príprava datastorov
if useAugmentation
    augmenter = imageDataAugmenter('RandXReflection', true, 'RandRotation', [-15 15]);
    dsTrain = augmentedImageDatastore(inputSize, imdsTrainFinal, 'DataAugmentation', augmenter);
    disp("Trénujem S augmentáciou.");
else
    dsTrain = augmentedImageDatastore(inputSize, imdsTrainFinal);
    disp("Trénujem BEZ augmentácie.");
end
dsVal  = augmentedImageDatastore(inputSize, imdsVal);
dsTest = augmentedImageDatastore(inputSize, imdsTest10);

%% 3. DEFINÍCIA SIETE
if useTransferLearning
    net = imagePretrainedNetwork(modelName, "NumClasses", numClasses);
    disp("Režim: Transfer Learning (predtrénované váhy)");
else
    net = imagePretrainedNetwork(modelName, "NumClasses", numClasses, "Weights", "none");
    disp("Režim: From Scratch (náhodné váhy)");
end

%% 4. PARAMETRE TRÉNOVANIA
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-4, ...
    'MaxEpochs', 6, ... 
    'MiniBatchSize', 32, ...
    'ValidationData', dsVal, ...
    'Plots', 'training-progress', ...
    'Metrics', 'accuracy', ...
    'Verbose', false);

%% 5. SPUSTENIE TRÉNOVANIA
fprintf('Spúšťam beh pre model %s...\n', modelName);
[trainedNet, info] = trainnet(dsTrain, net, "crossentropy", options);

%% 6. FINÁLNE TESTOVANIE A GRAF
% Testovanie na testovacej množine (údaj do tabuliek)
testAcc = testnet(trainedNet, dsTest, "accuracy");
fprintf('\n--- VÝSLEDOK BEHU ---\n');
fprintf('Model: %s | TL: %d | Aug: %d\n', modelName, useTransferLearning, useAugmentation);
fprintf('Finálna presnosť na TEST dátach: %.2f%%\n', testAcc);

% Vykreslenie vlastného grafu (ulož si ako obrázok do PDF)
figure;
subplot(2,1,1);
plot(info.TrainingLoss, 'LineWidth', 1.2); hold on;
plot(info.ValidationLoss, '--', 'LineWidth', 1.2);
title(['Loss: ' char(modelName)]); grid on;
legend('Train', 'Validation');

subplot(2,1,2);
plot(info.TrainingAccuracy, 'LineWidth', 1.2); hold on;
plot(info.ValidationAccuracy, '--', 'LineWidth', 1.2);
title(['Accuracy: ' char(modelName)]); grid on;
legend('Train', 'Validation');

%% --- EXPERIMENT 1: POROVNANIE TL vs. SCRATCH (3 BEHY) ---

% modelName = "resnet18"; % Sem doplň postupne "vgg16" (M1) a "mobilenetv2" (M3)
% resultsTL = cell(3,1);
% resultsScratch = cell(3,1);
% for i = 1:3
%     fprintf('--- Štart behu č. %d pre model %s ---\n', i, modelName);
% 
%     % A) Transfer Learning (predtrénované váhy)
%     netTL = imagePretrainedNetwork(modelName, "NumClasses", numClasses);
%     [~, infoTL] = trainnet(augImdsTrainBase, netTL, "crossentropy", options);
%     resultsTL{i} = infoTL;
% 
%     % B) Trénovanie od nuly (náhodné váhy)
%     netScratch = imagePretrainedNetwork(modelName, "NumClasses", numClasses, "Weights", "none");
%     [~, infoScratch] = trainnet(augImdsTrainBase, netScratch, "crossentropy", options);
%     resultsScratch{i} = infoScratch;
% end

% %% --- EXPERIMENT 2: NAJLEPŠÍ MODEL S AUGMENTÁCIOU (3 BEHY) ---
% 
% % Vyber najlepší model z predchádzajúceho testu (pravdepodobne TL)
% augmenter = imageDataAugmenter( ...
%     'RandXReflection', true, ...
%     'RandRotation', [-15 15], ...
%     'RandXTranslation', [-10 10], ...
%     'RandYTranslation', [-10 10]);
% 
% augImdsTrainAug = augmentedImageDatastore(inputSize, imdsTrainFinal, 'DataAugmentation', augmenter);
% 
% resultsAug = cell(3,1);
% for i = 1:3
%     fprintf('--- Štart AUGMENTOVANÉHO behu č. %d ---\n', i);
%     netAug = imagePretrainedNetwork(modelName, "NumClasses", numClasses); % TL verzia
%     [~, infoAug] = trainnet(augImdsTrainAug, netAug, "crossentropy", options);
%     resultsAug{i} = infoAug;
% end

%% --- VYHODNOTENIE (PRÍPRAVA PRE TABUĽKY) ---

% % Príklad ako vytiahnuť finálnu presnosť pre Tabuľku 1:
% avgAccTL = mean(cellfun(@(x) x.ValidationAccuracy(end), resultsTL));
% fprintf('Priemerná validačná presnosť TL: %.2f%%\n', avgAccTL);
% 
% % Vykreslenie grafu pre PDF (vlastná figura, nie screenshot)
% figure;
% plot(infoTL.TrainingLoss, 'b'); hold on;
% plot(infoTL.ValidationLoss, 'r--');
% title(['Priebeh učenia: ' char(modelName) ' (TL)']);
% xlabel('Iterácia'); ylabel('Loss');
% legend('Train Loss', 'Validation Loss');
% grid on;