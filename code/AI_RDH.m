function [J,Tag] = AI_RDH(I,Capacity,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch)
 
Tag = 0; % Ƕ����ɱ��: 1��� 0δ���

%% Ƕ��׼��
[A,B] = size(I);
J = I;
N = fix((B-2)/2)*fix((A-2)/2); %����Ԥ�����Ե�����
AuxL = 0; % ��¼����Ϣ����
Aux = 0;
%% ��һ��Ƕ��
Layer = 1;

%---Ԥ����-------------------------------------------------------

% λ��ͼ��� & ѹ��λ��ͼ
[LM,data,J] = LocationMap(J,Layer);

% ����Ԥ�� & Ԥ��������
[PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL] = Prediction(J,N,Layer);

%---����Ϣ����-------------------------------------------------------
Aux = min(length(LM),length(data));

%��ҪǶ����غɳ���
Payload = Capacity/2+Aux;

%---ӳ���Ż�-------------------------------------------------------
% �������п��ܵ�2Dֱ��ͼ
[H,Ts,ecAux,edAux] = H2Da(PEx,PEy,NL,Q);

% ǿ��ѧϰ�㷨�Ż�2Dӳ��
[Map,bestT,~,~,Tag] = Mapping(H,Ts,ecAux,edAux,Payload,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch);

if Tag == 0 % Ԥ���ж�
    return;
end


%---����Ƕ��-------------------------------------------------------

[J,nBit] = Embedding(J,PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL,N,Payload,Map,bestT,Q);

if nBit < Payload
    Tag = 0;
    return;
end

AuxL = AuxL + Aux;
t = 1;

%% �ڶ���Ƕ��
Layer = 2;

%---Ԥ����-------------------------------------------------------

% λ��ͼ��� & ѹ��λ��ͼ
[~,data,J] = LocationMap(J,Layer);

% ����Ԥ�� & Ԥ��������
[PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL] = Prediction(J,N,Layer);

%---����Ϣ����-------------------------------------------------------
Aux = min(length(LM),length(data));

%��ҪǶ����غɳ���
Payload = Capacity/2+Aux;

%---ӳ���Ż�-------------------------------------------------------

% ����2Dֱ��ͼ
[H,Ts,ecAux,edAux] = H2Da(PEx,PEy,NL,Q);

% ECs = sum(sum(H.* EcBase))+ecAux;
% EDs = sum(sum(H.*EdBase))+edAux;
% 
% index = find(ECs>=Payload);
% [minRate, id] = min(EDs(index)./ECs(index));
% bestT = Ts(index(id));

% ǿ��ѧϰ�㷨�Ż�2Dӳ��
[Map,bestT,~,~,Tag] = Mapping(H,Ts,ecAux,edAux,Payload,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch);

if Tag == 0 % Ԥ���ж�
    return;
end



%---����Ƕ��-------------------------------------------------------

[J,nBit] = Embedding(J,PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL,N,Payload,Map,bestT,Q);

if nBit < Payload
    Tag = 0;
    return;
else
    Tag = 1;
end
AuxL = AuxL + Aux;


%%  Ƕ�����Ϣ, LSB
Aux = AuxL;

%%%%%%%%%%% Read the edge pixels
iPos = []; jPos = [];
for i = 1:A
    for j = 1:B
        if i >= 2 && i <= A-2 && j >=2 && j <= B-2
            continue;
        end
        iPos = [iPos i];
        jPos = [jPos j];
    end
end
%%%%%%%%%% Random message
X = randperm(A*B);
M = zeros(A,B);
for i = 1:A
    for j = 1:B
        M(i,j) = mod(X(B*(i-1)+j),2);
    end
end
for t = 1:length(iPos)
     i = iPos(t);j = jPos(t);
     if Aux > 0
         J(i,j) = 2*floor(J(i,j)/2)+M(i,j);
         Aux = Aux-1;
     end
end

end