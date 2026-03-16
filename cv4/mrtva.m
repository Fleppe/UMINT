function [fine] = mrtva(values)
    BIG_FINE = 1e50;
    fine = 0;

    if sum(values) > 10000000,              fine = BIG_FINE; return; end
    if values(1) + values(2) > 2500000,     fine = BIG_FINE; return; end
    if values(5) > values(4),               fine = BIG_FINE; return; end
    if values(3)+values(4) > 0.5*sum(values), fine = BIG_FINE; return; end
    if any(values < 0),                    fine = BIG_FINE; return; end
end