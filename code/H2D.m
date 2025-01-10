function [H,ec,ed] = H2D(PEx,PEy,NL,T,Q)

H = zeros(Q+2,Q+2);
ec = 0;
ed = 0;
N = length(PEx);

for i = 1:N
    
    if NL(i) > T
        continue
    end
    
    x = abs(PEx(i))-0.5;
    y = abs(PEy(i))-0.5;
    
    if x == 0 && y > Q+1
        ec = ec + 1;
        ed = ed + 3/2;
        continue
    end
    
    if y == 0 && x > Q+1
        ec = ec + 1;
        ed = ed + 3/2;
        continue
    end
    
    if x > Q+1
        ed = ed + 2;
        continue
    end
    
    if y > Q+1
        ed = ed + 2;
        continue
    end
    
    H(x+1,y+1) = H(x+1,y+1) + 1;
    
end

t = 1;

end