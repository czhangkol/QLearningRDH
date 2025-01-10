function Thresh = sorting(PEx,PEy,NL,MapEc,MapEd,Payload)

MSEmin = 1000000;
Thresh = max(NL);

for T = min(NL):max(NL)
    H = H2D(PEx,PEy,NL,T);
    ec = sum(sum(H.*MapEc));
    if ec >= Payload
        ed = sum(sum(H.*MapEd))/ec;
        if ed < MSEmin
            MSEmin = ed;
            Thresh = T;
        end
    end
end

t = 1;
end