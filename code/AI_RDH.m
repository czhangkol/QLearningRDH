function [J,Tag] = AI_RDH(I,Capacity,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch)
 
Tag = 0; % 嵌入完成标记: 1完成 0未完成

%% 嵌入准备
[A,B] = size(I);
J = I;
N = fix((B-2)/2)*fix((A-2)/2); %单层预测误差对的数量
AuxL = 0; % 记录边信息长度
Aux = 0;
%% 第一层嵌入
Layer = 1;

%---预处理-------------------------------------------------------

% 位置图标记 & 压缩位置图
[LM,data,J] = LocationMap(J,Layer);

% 像素预测 & 预测误差配对
[PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL] = Prediction(J,N,Layer);

%---边信息长度-------------------------------------------------------
Aux = min(length(LM),length(data));

%需要嵌入的载荷长度
Payload = Capacity/2+Aux;

%---映射优化-------------------------------------------------------
% 生成所有可能的2D直方图
[H,Ts,ecAux,edAux] = H2Da(PEx,PEy,NL,Q);

% 强化学习算法优化2D映射
[Map,bestT,~,~,Tag] = Mapping(H,Ts,ecAux,edAux,Payload,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch);

if Tag == 0 % 预估判断
    return;
end


%---数据嵌入-------------------------------------------------------

[J,nBit] = Embedding(J,PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL,N,Payload,Map,bestT,Q);

if nBit < Payload
    Tag = 0;
    return;
end

AuxL = AuxL + Aux;
t = 1;

%% 第二层嵌入
Layer = 2;

%---预处理-------------------------------------------------------

% 位置图标记 & 压缩位置图
[~,data,J] = LocationMap(J,Layer);

% 像素预测 & 预测误差配对
[PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL] = Prediction(J,N,Layer);

%---边信息长度-------------------------------------------------------
Aux = min(length(LM),length(data));

%需要嵌入的载荷长度
Payload = Capacity/2+Aux;

%---映射优化-------------------------------------------------------

% 生成2D直方图
[H,Ts,ecAux,edAux] = H2Da(PEx,PEy,NL,Q);

% ECs = sum(sum(H.* EcBase))+ecAux;
% EDs = sum(sum(H.*EdBase))+edAux;
% 
% index = find(ECs>=Payload);
% [minRate, id] = min(EDs(index)./ECs(index));
% bestT = Ts(index(id));

% 强化学习算法优化2D映射
[Map,bestT,~,~,Tag] = Mapping(H,Ts,ecAux,edAux,Payload,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch);

if Tag == 0 % 预估判断
    return;
end



%---数据嵌入-------------------------------------------------------

[J,nBit] = Embedding(J,PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL,N,Payload,Map,bestT,Q);

if nBit < Payload
    Tag = 0;
    return;
else
    Tag = 1;
end
AuxL = AuxL + Aux;


%%  嵌入边信息, LSB
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