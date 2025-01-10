function [Map,MapEc,MapEd,Input] = BaseMap(Q)

% 生成初始的2D映射
Map = cell(Q+2,Q+2);
for x = 0:Q+1
    for y = 0:Q+1
        
        if x == 0 && y == 0
            Map{x+1,y+1} = [0,1,2];
            continue
        end
        
        if x == 1 && y == 1
            Map{x+1,y+1} = [0,3];
            continue
        end
        
        if x == 0
            Map{x+1,y+1} = [2,3];
            continue
        end
        
        if y == 0
            Map{x+1,y+1} = [1,3];
            continue
        end
        
        Map{x+1,y+1} = 3;
        
    end
end

%%% 测试对比常琪的方法
% Map = cell(256,256);
% for x = 0:255
%     for y = 0:255
%         
%         if x == 0 && y == 0
%             Map{x+1,y+1} = 0;
%             continue
%         end
%         
%         if x == 0
%             Map{x+1,y+1} = [2,3];
%             continue
%         end
%         
%         if y == 0
%             Map{x+1,y+1} = [1,3];
%             continue
%         end
%         
%         Map{x+1,y+1} = 3;
%         
%     end
% end
% 
%                  Map{2,1} = [0,1];Map{3,1}=[1,2];Map{4,1}=1;Map{5,1}=1;Map{6,1}=1;
% Map{1,2} = [0,2];Map{2,2}=0;      Map{3,2}=[1,2];Map{4,2}=1;Map{5,2}=1;Map{6,2}=1;
%                  Map{2,3}=0;      Map{3,3}=[1,3];Map{4,3}=[1,3];Map{5,3}=1;Map{6,3}=1;
% Map{1,4} = 2;Map{2,4}=[2,3];      Map{3,4}=0;Map{4,4}=[2,3];Map{5,4}=[1,3];Map{6,4}=[1,3];
% Map{1,5} = 2;Map{2,5}=2;      Map{3,5}=2;Map{4,5}=2;
% Map{4,6}=[1,3];

% 计算映射的单位失真和单位容量
MapEc = zeros(Q+2,Q+2);
MapEd = zeros(Q+2,Q+2);
shift = [0,1,1,2];
for i = 1:Q+2
    for j = 1:Q+2
        map = Map{i,j};
        L = length(map);
        MapEc(i,j) = log2(L);
        MapEd(i,j) = sum(shift(map+1))/L;
    end
end

% 入度矩阵
Input = cell(Q+2,Q+2);
for x = 1:Q+2 
    for y = 1:Q+2
        Input{x,y} = [];
    end
end
idx = [0,1,0,1];
idy = [0,0,1,1];
for x = 1:Q+1
    for y = 1:Q+1
        map = Map{x,y};
        L = length(map);
        for i = 1:L
            x1 = x + idx(map(i)+1);
            y1 = y + idy(map(i)+1);
            Input{x1,y1} = sort([Input{x1,y1} map(i)]);
        end
    end
end

t = 1;
end

