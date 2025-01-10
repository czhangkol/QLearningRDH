classdef Env1 < handle
    properties
        % 记录初始映射状态
        MapBase; % 2D映射
        EcBase; EdBase; % EC、ED矩阵
        InBase; % 入度矩阵
        rateBase; % 初始性能
        
        % 2D映射状态
        Map; MapEc; MapEd; Input;
        
        state; % 状态位置: 映射点位
        max_state;
        state_space;
        action_space;
        
        H; % 2D直方图
        Payload; % 载荷需求
        Ts; % 复杂度阈值
        ecAux;edAux; % 固定性能
        
        MSEmin;
        
        % 保存最有结果
        MSEbest;
        MapBest; EcBest; EdBest;
        bestT;
    end
    
    methods
        
        function obj = Env1(MapBase,EcBase,EdBase,InBase,H,Ts,ecAux,edAux,Payload,state_space,action_space,max_state)
            obj.MapBase = MapBase;
            obj.EcBase = EcBase;
            obj.EdBase = EdBase;
            obj.Map = MapBase;
            obj.MapEc = EcBase;
            obj.MapEd = EdBase;
            obj.InBase = InBase;
            obj.Input = InBase;
            obj.state = 1;
            obj.max_state = max_state;
            obj.state_space = state_space;
            obj.action_space = action_space;
            
            obj.H = H;
            obj.Ts = Ts;
            obj.ecAux = ecAux;
            obj.edAux = edAux;
            obj.Payload = Payload;
            
            ECs = sum(sum(obj.H .* obj.EcBase))+obj.ecAux;
            EDs = sum(sum(obj.H .* obj.EdBase))+obj.edAux;
            
            index = find(ECs >= obj.Payload);
            obj.rateBase = min(EDs(index)./ECs(index));

            obj.MSEmin = obj.rateBase;
            
            obj.MSEbest = obj.MSEmin;
            obj.MapBest = MapBase;
            obj.EcBest = EcBase;
            obj.EdBest = EdBase;
            obj.bestT = max(obj.Ts);
        end
        
        function [reward, state, terminal] = step(obj,action_id)
            
            ids = obj.state_space{obj.state};
            x = ids(1); y = ids(2);
            
            % 更新映射状态
            map_old = obj.Map{x,y};
            map_new = obj.action_space{action_id,1};
            obj.Map{x,y} = map_new;
            
            
            % 微调映射，保持可逆---------------------------------------------
            old = zeros(1,4); new = zeros(1,4);
            old(map_old+1) = 1; new(map_new+1) = 1;
            Inerror = new - old;
            xm = [0,1,0,1]; ym = [0,0,1,1];
            shift = [0,1,1,2];

            % A.遍历新增的映射出度 >> 解决入度冲突问题
            index = find(Inerror == 1);
            tag = 0; % 映射不可用标记
            flag = 0; % 动作调整标记
            for id = 1:length(index)
                i = index(id);
                x1 = x + xm(i); y1 = y + ym(i); % 新的出度方向(x1,y1)
                in = obj.Input{x1,y1};
                
                % (x1,y1)的原入度方向
                x2 = x1 - xm(in+1); y2 = y1 - ym(in+1);
                out = obj.Map{x2,y2};
                
                if length(out) == 1 % Case 1 (x2,y2)的出度唯一  
                    if length(map_new) == 1 % 1.1 映射动作不可调整
                        tag = 1; flag = 0;
                    else % 1.2 调整映射动作,即无法映射到(x1,y1) 
                        map_new = setdiff(map_new, i-1); % 删减映射方向                      
                        flag = 1;
                    end             
                else % Case 2 (x2,y2)有多个出度（可微调）
                    out = setdiff(obj.Map{x2,y2},in); % 删除对应出度
                    obj.Map{x2,y2} = out;
                    L = length(out);
                    obj.MapEc(x2,y2) = log2(L);
                    obj.MapEd(x2,y2) = sum(shift(out+1))/L;
                    
                    
                    in = i-1; % 调整(x1,y1)的入度
                    obj.Input{x1,y1} = in;
                end
            end
            
            if tag == 1 % 维持原动作
                obj.Map{x,y} = map_old;
            elseif flag == 1
                obj.Map{x,y} = map_new;
                L = length(map_new);
                obj.MapEc(x,y) = log2(L);
                obj.MapEd(x,y) = sum(shift(map_new+1))/L;
            else
                obj.MapEc(x,y) = obj.action_space{action_id,2};
                obj.MapEd(x,y) = obj.action_space{action_id,3};
            end
            
            % B.遍历删减的映射出度 >> 解决无入度问题
            if tag == 0
                index = find(Inerror == -1);
                for id = 1:length(index)
                    i = index(id);
                    x1 = x + xm(i); y1 = y + ym(i); % 原出度方向(x1,y1)
                    
                    obj.Input{x1,y1} = 0; % 变原入度为自映射
                    
                    % 调整(x1,y1)的出度
                    out = sort([obj.Map{x1,y1},0]);
                    obj.Map{x1,y1} = out;
                    L = length(out);
                    obj.MapEc(x1,y1) = log2(L);
                    obj.MapEd(x1,y1) = sum(shift(out+1))/L;
                end
            end
            
            
            % 计算映射状态性能
            ECs = sum(sum(obj.H .* obj.MapEc))+obj.ecAux;
            ec = max(ECs); % 最大容量
            
            % 即时奖励
            r1 = 0; r2 = 0;
            if ec >= obj.Payload
                r1 = 1; % 容量满足需求：给奖励
                
                % 计算移位损失
                EDs = sum(sum(obj.H .* obj.MapEd))+obj.edAux;
                index = find(ECs >= obj.Payload);
                [rate, id] = min(EDs(index)./ECs(index));
                
                if rate < obj.MSEmin
                    obj.MSEmin = rate;
                    r2 = 2; % 性能提升：给奖励
                elseif rate > obj.MSEmin
                    r2 = -1; % 性能下降：给惩罚
                end

                if rate < obj.MSEbest % 记录最优结果
                    obj.MSEbest = rate;
                    obj.MapBest = obj.Map;
                    obj.EcBest = obj.MapEc;
                    obj.EdBest = obj.MapEd;
                    obj.bestT = obj.Ts(index(id)); % 最优性能对应阈值
                end
            else
                r1 = -1; % 容量不满足需求：给惩罚
            end
            
            terminal = false; % 是否终止
            if obj.state == obj.max_state
                terminal = true;
            end
            
            % 即时奖励反馈
            reward = r1 + r2;
            
            % 进入下一个待更新状态位置
            obj.state = obj.state + 1; 
            state = obj.state;
            
        end
        
        function states = reset(obj)
            obj.state = 1;
            obj.Map = obj.MapBase;
            obj.MapEc = obj.EcBase;
            obj.MapEd = obj.EdBase;
            obj.MSEmin = obj.rateBase;
            obj.Input = obj.InBase;
            
            states = 1;
        end
       
    end
end