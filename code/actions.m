clc;clear;
% 用于生成映射动作空间

action_space = cell(15,3);
action = [3,2,1,0];
shift = [0,1,1,2];

for i = 1:15
    map = dec2bin(i,4);
    map_new = [];
    for j = 1:4
        out = map(j);
        if out == '1'
            map_new = [map_new, action(j)];
        end
    end
    map_new = sort(map_new);
    L = length(map_new);
    
    action_space{i,1} = map_new;
    action_space{i,2} = log2(L);
    action_space{i,3} = sum(shift(map_new+1))/L;
    
    t = 1;
end
save Actions.mat action_space;