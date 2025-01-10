classdef Env < handle
    properties
        % 记录初始映射状态
        MapBase; % 2D映射
        EcBase; EdBase; % EC、ED矩阵
        InBase; revBase; % 入度矩阵，可逆矩阵
        Ec0; Ed0; % 初始性能
        
        % 2D映射状态
        Map; MapEc; MapEd; Input; revT;
        
        state; % 状态位置: 映射点位
        max_state;
        state_space;
        action_space;
        
        H; % 2D直方图
        Payload; % 载荷需求
        
        MSEmin;
        
        
    end
    
    methods
        
        function obj = Env(MapBase,EcBase,EdBase,InBase,revBase,H,Payload,state_space,action_space,max_state)
            obj.MapBase = MapBase;
            obj.EcBase = EcBase;
            obj.EdBase = EdBase;
            obj.Map = MapBase;
            obj.MapEc = EcBase;
            obj.MapEd = EdBase;
            obj.InBase = InBase;
            obj.revBase = revBase;
            obj.Input = InBase;
            obj.revT = revBase;
            obj.state = 1;
            obj.max_state = max_state;
            obj.state_space = state_space;
            obj.action_space = action_space;
            
            obj.H = H;
            obj.Payload = Payload;
            
            obj.Ec0 = sum(sum(obj.MapEc .* obj.H));
            obj.Ed0 = sum(sum(obj.MapEd .* obj.H));
            obj.MSEmin = obj.Ed0 / obj.Ec0;
        end
        
        function [reward, state, terminal] = step(obj,action_id)
            
            ids = obj.state_space{obj.state};
            x = ids(1); y = ids(2);
            
            
            % 更新映射状态
            map_old = obj.Map{x,y};
            map_new = obj.action_space{action_id,1};
            obj.Map{x,y} = map_new;
            obj.MapEc(x,y) = obj.action_space{action_id,2};
            obj.MapEd(x,y) = obj.action_space{action_id,3};
            
            % 更新入度矩阵
            is_reversible = 0; % 可逆标志
            old = zeros(1,4); new = zeros(1,4);
            old(map_old+1) = 1; new(map_new+1) = 1;
            Inerror = new - old;
            xm = [0,1,0,1]; ym = [0,0,1,1];
            for i = 1:4
                x1 = x + xm(i); y1 = y + ym(i);
                in = obj.Input{x1,y1};
                if Inerror(i) == -1 % 删减入度
                    in = setdiff(in,i-1);
                    if isempty(in)
                        is_reversible = 1;
                        obj.revT(x1,y1) = 1;
                    end
                    if length(in) == 1
                        obj.revT(x1,y1) = 0;
                    end
                end
                if Inerror(i) == 1 % 增加入度
                    in = [in,i-1];
                    if length(in) > 1
                        is_reversible = 1;
                        obj.revT(x1,y1) = 1;
                    else
                        obj.revT(x1,y1) = 0;
                    end
                    
                end
                obj.Input{x1,y1} = in;
            end
            
            % 计算映射状态性能
            ec = sum(sum(obj.MapEc.*obj.H));
            ed = sum(sum(obj.MapEd.*obj.H));
            rate = ed / ec;
            
            % 即时奖励
            r1 = 0; r2 = 0; r3 = 0;
            if ec >= obj.Payload
                r1 = 1;
                r2 = obj.MSEmin - rate; 
            else
                r1 = -1;
            end
            if is_reversible == 1
                r3 = -1;
            end
            
            terminal = false; % 是否终止
            if obj.state == obj.max_state
                terminal = true;
%                 if sum(sum(obj.revT)) ~= 0
%                     r3 = -100; % 映射不可用
%                 end
            end
            
            % 即时奖励反馈
            reward = r1 + r2 + r3;
            
            % 进入下一个待更新状态位置
            obj.state = obj.state + 1; 
            state = obj.state;
            
        end
        
        function states = reset(obj)
            obj.state = 1;
            obj.Map = obj.MapBase;
            obj.MapEc = obj.EcBase;
            obj.MapEd = obj.EdBase;
            obj.MSEmin = obj.Ed0 / obj.Ec0;
            obj.Input = obj.InBase;
            obj.revT = obj.revBase;
            
            states = 1;
        end
       
    end
end