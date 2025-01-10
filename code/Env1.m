classdef Env1 < handle
    properties
        % ��¼��ʼӳ��״̬
        MapBase; % 2Dӳ��
        EcBase; EdBase; % EC��ED����
        InBase; % ��Ⱦ���
        rateBase; % ��ʼ����
        
        % 2Dӳ��״̬
        Map; MapEc; MapEd; Input;
        
        state; % ״̬λ��: ӳ���λ
        max_state;
        state_space;
        action_space;
        
        H; % 2Dֱ��ͼ
        Payload; % �غ�����
        Ts; % ���Ӷ���ֵ
        ecAux;edAux; % �̶�����
        
        MSEmin;
        
        % �������н��
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
            
            % ����ӳ��״̬
            map_old = obj.Map{x,y};
            map_new = obj.action_space{action_id,1};
            obj.Map{x,y} = map_new;
            
            
            % ΢��ӳ�䣬���ֿ���---------------------------------------------
            old = zeros(1,4); new = zeros(1,4);
            old(map_old+1) = 1; new(map_new+1) = 1;
            Inerror = new - old;
            xm = [0,1,0,1]; ym = [0,0,1,1];
            shift = [0,1,1,2];

            % A.����������ӳ����� >> �����ȳ�ͻ����
            index = find(Inerror == 1);
            tag = 0; % ӳ�䲻���ñ��
            flag = 0; % �����������
            for id = 1:length(index)
                i = index(id);
                x1 = x + xm(i); y1 = y + ym(i); % �µĳ��ȷ���(x1,y1)
                in = obj.Input{x1,y1};
                
                % (x1,y1)��ԭ��ȷ���
                x2 = x1 - xm(in+1); y2 = y1 - ym(in+1);
                out = obj.Map{x2,y2};
                
                if length(out) == 1 % Case 1 (x2,y2)�ĳ���Ψһ  
                    if length(map_new) == 1 % 1.1 ӳ�䶯�����ɵ���
                        tag = 1; flag = 0;
                    else % 1.2 ����ӳ�䶯��,���޷�ӳ�䵽(x1,y1) 
                        map_new = setdiff(map_new, i-1); % ɾ��ӳ�䷽��                      
                        flag = 1;
                    end             
                else % Case 2 (x2,y2)�ж�����ȣ���΢����
                    out = setdiff(obj.Map{x2,y2},in); % ɾ����Ӧ����
                    obj.Map{x2,y2} = out;
                    L = length(out);
                    obj.MapEc(x2,y2) = log2(L);
                    obj.MapEd(x2,y2) = sum(shift(out+1))/L;
                    
                    
                    in = i-1; % ����(x1,y1)�����
                    obj.Input{x1,y1} = in;
                end
            end
            
            if tag == 1 % ά��ԭ����
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
            
            % B.����ɾ����ӳ����� >> ������������
            if tag == 0
                index = find(Inerror == -1);
                for id = 1:length(index)
                    i = index(id);
                    x1 = x + xm(i); y1 = y + ym(i); % ԭ���ȷ���(x1,y1)
                    
                    obj.Input{x1,y1} = 0; % ��ԭ���Ϊ��ӳ��
                    
                    % ����(x1,y1)�ĳ���
                    out = sort([obj.Map{x1,y1},0]);
                    obj.Map{x1,y1} = out;
                    L = length(out);
                    obj.MapEc(x1,y1) = log2(L);
                    obj.MapEd(x1,y1) = sum(shift(out+1))/L;
                end
            end
            
            
            % ����ӳ��״̬����
            ECs = sum(sum(obj.H .* obj.MapEc))+obj.ecAux;
            ec = max(ECs); % �������
            
            % ��ʱ����
            r1 = 0; r2 = 0;
            if ec >= obj.Payload
                r1 = 1; % �����������󣺸�����
                
                % ������λ��ʧ
                EDs = sum(sum(obj.H .* obj.MapEd))+obj.edAux;
                index = find(ECs >= obj.Payload);
                [rate, id] = min(EDs(index)./ECs(index));
                
                if rate < obj.MSEmin
                    obj.MSEmin = rate;
                    r2 = 2; % ����������������
                elseif rate > obj.MSEmin
                    r2 = -1; % �����½������ͷ�
                end

                if rate < obj.MSEbest % ��¼���Ž��
                    obj.MSEbest = rate;
                    obj.MapBest = obj.Map;
                    obj.EcBest = obj.MapEc;
                    obj.EdBest = obj.MapEd;
                    obj.bestT = obj.Ts(index(id)); % �������ܶ�Ӧ��ֵ
                end
            else
                r1 = -1; % �������������󣺸��ͷ�
            end
            
            terminal = false; % �Ƿ���ֹ
            if obj.state == obj.max_state
                terminal = true;
            end
            
            % ��ʱ��������
            reward = r1 + r2;
            
            % ������һ��������״̬λ��
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