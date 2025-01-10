function [H,Ts,ecAux,edAux] = H2Da(PEx,PEy,NL,Q)

H = zeros(Q+2,Q+2,2);

Ts = unique(NL);
L = length(Ts);
ecAux = zeros(1,1,L);
edAux = zeros(1,1,L);

for i = 1:L
    T = Ts(i);
    [h,ec,ed] = H2D(PEx,PEy,NL,T,Q);
    H(:,:,i) = h;
    ecAux(i) = ec;
    edAux(i) = ed;
end

t = 1;

end