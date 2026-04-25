% vypise do matice pod seba dvojce suradnic(indexov v matici w1(w2)) 
% najblizsieho neuronu pre kazdy bod vstupnych dat
function[vysledok]=roztried(w1,w2,x,y)
    vysledok=[];                   % pozicie (v matici) najblizsich neuronov k bodom 
                                    % usporiadane podla poradia bodov v poli
    for m=1:length(x)               % cez vsetky vstupne body
        min_vzdial=1000;
        neuron=[];
        for i=1:size(w1,2)          % x-suradnice neuronov (riadky)
            for j=1:size(w1,1)      % x-suradnice neuronov (stlpce)   
                vzdial= vzdialenost(x(m,1), y(m,1), w1(i,j), w2(i,j));     % vyrata vzdialenost pre konkretny neuron
                if (vzdial <= min_vzdial)
                    min_vzdial=vzdial;
                    neuron=[i j];
                end
            end
        end
        vysledok=[vysledok; neuron];
    end
    vysledok;