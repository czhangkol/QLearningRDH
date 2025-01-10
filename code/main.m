clc;clear;

%% ���ݼ�

% 
% imgfile = ['D:\Data\Kodak-gray\'];
% imgdir = dir([imgfile,'\*.png']);

imgfile = ['D:\Data\BOWS2OrigEp3\'];
imgdir = dir([imgfile,'\*.pgm']);


fid = fopen('fileName.txt','wt');
data_n = length(imgdir);

%% ��������
Q = 7; % �Ż�����([0-Q]*[0-Q])
alpha = 0.1; % ѧϰ��
gamma = 0.8; % �ۿ�����
epoch = 3000; % ��������

[MapBase,EcBase,EdBase,Input] = BaseMap(Q); % ���ɳ�ʼӳ��

%% Ƕ��
performance = zeros(data_n*2,100); % ���ܽ��
data_n = 1000;

for i_img = 1:1 % ����ͼ��
    
    I = double(imread([imgfile,'\',imgdir(i_img).name]));
    
    ii = 2*(i_img - 1) + 1;
    jj = 1; % ����У���Ӧ����

    for Capacity = 5000:5000:100000 % ��������
        tic
        [J,Tag] =  AI_RDH(I,Capacity,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch); % Ƕ����
        
        if Tag == 0
            break;
        end
        
        jj = jj + 5;
        psnr = appraise(J,I)
        performance(ii,jj) = Capacity;
        performance(ii+1,jj) = psnr;
        fprintf('The %d test image,embedding %d bits, %d%%\n',i_img,Capacity,fix((i_img/data_n)*100));
%         save BOSW2_1k.mat performance;
        t = 1;
        toc
    end
end