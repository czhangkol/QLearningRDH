classdef Env < handle
    properties
        % ��¼��ʼӳ��״̬
        MapBase; % 2Dӳ��
        EcBase; EdBase; % EC��ED����
        InBase; revBase; % ��Ⱦ��󣬿������
        Ec0; Ed0; % ��ʼ����
        
        % 2Dӳ��״̬
        Map; MapEc; MapEd; Input; revT;
        
        state; % ״̬λ��: ӳ���λ
        max_state;
        state_space;
        action_space;
        
        H; % 2Dֱ��ͼ
        Payload; % �غ�����
        
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
            
            
            % ����ӳ��״̬
            map_old = obj.Map{x,y};
            map_new = obj.action_space{action_id,1};
            obj.Map{x,y} = map_new;
            obj.MapEc(x,y) = obj.action_space{action_id,2};
            obj.MapEd(x,y) = obj.action_space{action_id,3};
            
            % ������Ⱦ���
            is_reversible = 0; % �����־
            old = zeros(1,4); new = zeros(1,4);
            old(map_old+1) = 1; new(map_new+1) = 1;
            Inerror = new - old;
            xm = [0,1,0,1]; ym = [0,0,1,1];
            for i = 1:4
                x1 = x + xm(i); y1 = y + ym(i);
                in = obj.Input{x1,y1};
                if Inerror(i) == -1 % ɾ�����
                    in = setdiff(in,i-1);
                    if isempty(in)
                        is_reversible = 1;
                        obj.revT(x1,y1) = 1;
                    end
                    if length(in) == 1
                        obj.revT(x1,y1) = 0;
                    end
                end
                if Inerror(i) == 1 % �������
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
            
            % ����ӳ��״̬����
            ec = sum(sum(obj.MapEc.*obj.H));
            ed = sum(sum(obj.MapEd.*obj.H));
            rate = ed / ec;
            
            % ��ʱ����
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
            
            terminal = false; % �Ƿ���ֹ
            if obj.state == obj.max_state
                terminal = true;
%                 if sum(sum(obj.revT)) ~= 0
%                     r3 = -100; % ӳ�䲻����
%                 end
            end
            
            % ��ʱ��������
            reward = r1 + r2 + r3;
            
            % ������һ��������״̬λ��
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