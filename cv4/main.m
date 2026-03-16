
%=========== Params ==============
space = [zeros(1,5); ones(1,5)*1e7];
numPop = 100;
amp = ones(1,5)*20;
max_gen = 2500;
num_runs = 5;
%=========== Params ==============

%=========== Run =================
fitness_history = zeros(1, max_gen); 
for run = 1:num_runs
    
    pop = genrpop(numPop, space);

    for gen = 1:max_gen
        for i = 1:numPop
           fitness(i) = -(0.04*pop(i,1) + 0.07*pop(i,2) + 0.11*pop(i,3) + 0.06*pop(i,4) + 0.05*pop(i,5));
        end
    
        for j = 1:numPop
        fitness(j) = fitness(j) + mrtva(pop(j,:));
        %fitness(j) = fitness(j) + stupnovita(pop(j,:));
        %itness(j) = fitness(j) + umerna(pop(j,:));
        end
        if gen == max_gen
            [best, idx] = min(fitness);
            fprintf('Najlepsi jedinec %d behu: %d.\n',run, -best);
            fprintf('Jeho geny:');
            pop(idx,:)

        
        end
        fitness_history(gen) = min(fitness);  % najlepší (najnižší) fitness v generácii
    
        best   = selbest(pop, fitness, [3 2 1]);
        others = selsus(pop, fitness, numPop - 2*6);
        joined = [others; best];
        joined = crossov(joined, 1, 0);
        joined = mutx(joined, 0.1, space);
        joined = muta(joined, 0.1, amp,space);
        pop    = [joined; best];
    end
end

%=========== Run =================


% --- vykreslenie ---

figure(1);
plot(1:max_gen, -fitness_history, 'b-', 'LineWidth', 2);
xlabel('Generácia');
ylabel('Fitness (najlepší jedinec)');
title('Moje XTB portfolio.');
legend("Palantir stocks.")
ylim([-1000000, 1000000]);
grid on;
hold on;

