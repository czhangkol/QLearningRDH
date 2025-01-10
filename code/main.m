clc;clear;

%% 数据集

% 
% imgfile = ['D:\Data\Kodak-gray\'];
% imgdir = dir([imgfile,'\*.png']);

imgfile = ['D:\Data\BOWS2OrigEp3\'];
imgdir = dir([imgfile,'\*.pgm']);


fid = fopen('fileName.txt','wt');
data_n = length(imgdir);

%% 参数设置
Q = 7; % 优化区域([0-Q]*[0-Q])
alpha = 0.1; % 学习率
gamma = 0.8; % 折扣因子
epoch = 3000; % 迭代次数

[MapBase,EcBase,EdBase,Input] = BaseMap(Q); % 生成初始映射

%% 嵌入
performance = zeros(data_n*2,100); % 性能结果
data_n = 1000;

for i_img = 1:1 % 遍历图像
    
    I = double(imread([imgfile,'\',imgdir(i_img).name]));
    
    ii = 2*(i_img - 1) + 1;
    jj = 1; % 结果列：对应容量

    for Capacity = 5000:5000:100000 % 容量需求
        tic
        [J,Tag] =  AI_RDH(I,Capacity,Q,MapBase,EcBase,EdBase,Input,alpha,gamma,epoch); % 嵌入结果
        
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