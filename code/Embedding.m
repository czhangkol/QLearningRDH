function [J,nBit] = Embedding(I,PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL,N,Payload,Map,T,Q)

J = I;
nBit = 0;
data = randperm(N); % ������Ϣ

% �޸Ļ���
xm = [0,1,0,1];
ym = [0,0,1,1];

% ��ʼǶ��
for t = 1:N
    
    % �Ƿ�Ƕ�ꣿ
    if nBit >= Payload
        break;
    end
    
    if NL(t) > T
        continue;
    end
    
    x = abs(PEx(t))-0.5; y = abs(PEy(t))-0.5; % ����
    xi = XiPos(t); xj = XjPos(t);
    yi = YiPos(t); yj = YjPos(t);
    
    if x == 0 && y > Q+1
        bit = mod(data(t),2);
        if bit == 0
            J(yi,yj) = J(yi,yj) + sign(PEy(t)) * 1;
        elseif bit == 1
            J(xi,xj) = J(xi,xj) + sign(PEx(t)) * 1;
            J(yi,yj) = J(yi,yj) + sign(PEy(t)) * 1;
        end
        nBit = nBit + 1;
        continue
    end
    
    if y == 0 && x > Q+1
        bit = mod(data(t),2);
        if bit == 0
            J(xi,xj) = J(xi,xj) + sign(PEx(t)) * 1;
        elseif bit == 1
            J(xi,xj) = J(xi,xj) + sign(PEx(t)) * 1;
            J(yi,yj) = J(yi,yj) + sign(PEy(t)) * 1;
        end
        nBit = nBit + 1;
        continue
    end
    
    if x > Q+1
        J(xi,xj) = J(xi,xj) + sign(PEx(t)) * 1;
        J(yi,yj) = J(yi,yj) + sign(PEy(t)) * 1;
        continue
    end
    
    if y > Q+1
        J(xi,xj) = J(xi,xj) + sign(PEx(t)) * 1;
        J(yi,yj) = J(yi,yj) + sign(PEy(t)) * 1;
        continue
    end
    
    s = Map{x+1,y+1}; % ��Ӧӳ��
    L = length(s); 
    
    % ������λ��
    if L == 1 % ����λ      
        a = xm(s+1); b = ym(s+1);
    else % Ƕ��
        bit = mod(data(t),L);
        a = xm(s(bit+1)+1); b = ym(s(bit+1)+1);
        nBit = nBit + log2(L);
    end
    
    % �޸�����
    J(xi,xj) = J(xi,xj) + sign(PEx(t)) * a;
    J(yi,yj) = J(yi,yj) + sign(PEy(t)) * b;
    
end
MSE = sum(sum(abs(I-J)));
t = 1;

end