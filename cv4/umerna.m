function [fine] = umerna(values)  
    fine = 0;
    % Koeficient citlivosti (váha pokuty) - treba odladiť podľa fitness
    w = 1; 

    % 1) Celková investícia <= 10 000 000
    fine = fine + w * max(0, sum(values) - 10000000);
    
    % 2) Akcie <= 2 500 000
    fine = fine + w * max(0, (values(1) + values(2)) - 2500000);
    
    % 3) Štátne dlhopisy >= úspory (x4 >= x5 => x5 - x4 <= 0)
    fine = fine + w * max(0, values(5) - values(4));
    
    % 4) Dlhopisy <= 0.5 * celok (x3 + x4 - 0.5 * sum <= 0)
    fine = fine + w * max(0, (values(3) + values(4)) - 0.5 * sum(values));
    
    % 5) Nezápornosť (x_i >= 0)
    % Vaša verzia sum(abs(values(values < 0))) je v poriadku, 
    % ale max(0, -values) je čistejší zápis pre GA
    fine = fine + w * sum(max(0, -values));
end