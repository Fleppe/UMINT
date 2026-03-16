function [fine] = stupnovita(values)
    STEP = 5000000;  
    fine = 0;

    if sum(values) > 10000000,                fine = fine + STEP; end
    if values(1) + values(2) > 2500000,       fine = fine + STEP; end
    if values(5) > values(4),                 fine = fine + STEP; end
    if values(3)+values(4) > 0.5*sum(values), fine = fine + STEP; end
    if any(values < 0),                       fine = fine + STEP; end
end