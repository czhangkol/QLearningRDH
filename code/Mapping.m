function [Map,bestT,MapEc,MapEd,Tag] = Mapping(H,Ts,ecAux,edAux,Payload,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch)

Tag = 0;

% ״̬�ռ�������
max_state = (Q+1)*(Q+1);
state_space = cell(1,max_state);
id = 1;
for i = 0:2*Q
    for x = 0:i
        y = -1*x+i;
        if x > Q || y > Q
            continue;
        end   
        state_space{id} = [x+1,y+1];
        id = id + 1;
    end
end
% �����ռ�
load Actions.mat; % ����action_space��ʹ��actions.m���ɣ�
actions = 15;

% ����ѵ��������agent
env = Env1(MapBase,EcBase,EdBase,Input,H,Ts,ecAux,edAux,Payload,state_space,action_space,max_state);
agent = QLearning(alpha,gamma,max_state,actions);

% ��ʼѵ��
reward_list = zeros(epoch);
for num_episode = 1:epoch
    episode_reward = 0; % Ƭ���ۻ��ر�
    state = env.reset(); % ��������
    
    done = false;
    
    while ~done
        action = agent.take_action(state,num_episode); % ��ȡ�ж�
        
        [reward,next_state,done] = env.step(action); % �뻷������
        episode_reward = episode_reward + reward;
        
        agent.update(state,action,reward,next_state,done); % ����Q��
        state = next_state; % ������һ״̬
    end
    
    reward_list(num_episode) = episode_reward;
    if mod(num_episode,100) == 0
        fprintf('Episode: %d, Score: %d\n', num_episode, episode_reward)
    end
end

% ��ȡ����2Dӳ��
Map = env.MapBest;
MapEc = env.EcBest;
MapEd = env.EdBest;

ECs = sum(sum(H .* MapEc))+ecAux;
EDs = sum(sum(H .* MapEd))+edAux;

index = find(ECs >= Payload);
[minRate, id] = min(EDs(index)./ECs(index));

Ec = ECs(index(id));
bestT = Ts(index(id));


if Ec >= Payload
    Tag = 1;
end


end