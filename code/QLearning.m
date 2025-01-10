classdef QLearning < handle
    properties
        Qtable; % Q表格
        actions;
        alpha; gamma; % 参数
    end
    
    methods
        
        function obj = QLearning(alpha,gamma,max_state,actions)
            obj.Qtable = zeros([max_state,actions]);
            obj.alpha = alpha;
            obj.gamma = gamma;
            obj.actions = actions;
        end
        
        function probility = epsilon(obj,num_episode)
            % probility = 20/(num_episode+100);
            probility = 0.1;
        end
        
        function action = take_action(obj,state,num_episode)
            if rand(1) < obj.epsilon(num_episode) % 随机探索
                action = randi([1,obj.actions]);
            else
                [~,action] = max(obj.Qtable(state,:));
            end       
        end
        
        function update(obj,state,action,reward,next_state,is_terminated)
            predict = obj.Qtable(state,action);
            
            if ~is_terminated
                target = reward + obj.gamma * max(obj.Qtable(next_state,:));
            else
                target = reward;
            end
            td_error = target - predict;
            obj.Qtable(state,action) = predict + obj.alpha * td_error;
        end
        
        function action = best_action(obj, state)
            [~,action] = max(obj.Qtable(state,:));
        end
    end
end