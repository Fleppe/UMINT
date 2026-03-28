% load data
load CTGdata   
data_in = NDATA'; 
% formated output in type one-hot
data_out = typ_ochorenia;
data_out_size = size(data_out,1);
data_out_formated = zeros(3,data_out_size);

for i = 1:data_out_size
    if typ_ochorenia(i) == 1
        data_out_formated(1,i) = 1;
    end
    if typ_ochorenia(i) == 2
        data_out_formated(2,i) = 1;
    end
    if typ_ochorenia(i) == 3
        data_out_formated(3,i) = 1;
    end
end

% params
neuron_struct = [50 50];

net = patternnet(neuron_struct); 
% main cycle
   
    net.divideFcn='dividerand';
    net.divideParam.trainRatio=0.60;
    net.divideParam.valRatio=0.0;
    net.divideParam.testRatio=0.4;

    % train params
    net.trainParam.epochs = 100;
    net.trainParam.goal = 1e-5;
     
   %net.trainParam.max_fail = 50;
    % train
    [net, tr] = train(net, data_in, data_out_formated);
    
    % testing
    full_out = sim(net,data_in);
    train_out = sim(net,data_in(:,tr.trainInd));
    test_out = sim(net,data_in(:,tr.testInd));
    [c_train,cm_train] = confusion(data_out_formated(:, tr.trainInd),train_out);
    [c_test,cm_test] = confusion(data_out_formated(:, tr.testInd),test_out);
    train_accuracy = 100*(1 - c_train);
    test_accuracy = 100*(1 - c_test);

    %fprintf("test accuracy of run %d: %.2f\n",run, test_accuracy(run));
    %fprintf("train accuracy of run %d: %.2f\n", run, train_accuracy(run));
    
    figure;
    plotconfusion(data_out_formated(:, tr.testInd), test_out, "Test set ");
    %figure;
    %plotconfusion(data_out_formated(:, tr.trainInd), train_out, "Train set " + run);
    %figure;
    %plotconfusion(data_out_formated, full_out, "Full set " + run);
    

%average_test_accuracy = sum(test_accuracy) / num_run;
%average_train_accuracy = sum(train_accuracy) / num_run;
%fprintf("| Type  | Mean  | Min  | Max   |\n");
%fprintf("| Train | %.2f | %.2f  | %.2f  |\n",average_train_accuracy, min(train_accuracy), max(train_accuracy));
%fprintf("| Test  | %.2f | %.2f  | %.2f  |\n",average_test_accuracy, min(test_accuracy), max(test_accuracy));

 idx1 = find(typ_ochorenia == 1, 1);
 idx2 = find(typ_ochorenia == 2, 1);
 idx3 = find(typ_ochorenia == 3, 1);
 samples = data_in(:,[idx1 idx2 idx3]);
 samples_out = sim(net, samples);
 classes = vec2ind(samples_out);

