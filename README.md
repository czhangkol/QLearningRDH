
基于Q学习的成对PEE方法
=======


论文名： "[Reversible data hiding based on adaptive pairwise prediction-error expansion and reinforcement learning](https://github.com/czhangkol)" (在投).


## 方法简介

提出了一个基于强化学习（Q学习）的自适应2D映射的生成方法，为基于高维映射的预测误差扩展方法提供了一个优化方案


## 如何运行

```
进入code文件夹
运行 main.m文件
```
注意：在运行前请准备数据集，并修改main.m文件中的数据集地址，即：
```
imgfile = ['D:\Data\BOWS2OrigEp3\']; % 修改地址后再运行！
imgdir = dir([imgfile,'\*.pgm']);
```
## 代码文件结构
```
code
|
|-actions.m: 独立文件，用于生成动作空间（Actions.mat）
|-Actions.mat: 生成的动作空间，第一列为映射动作，第二列为单位容量，第三列为单位失真
|-AI_RDH.m: 嵌入方法实现
|-appraise.m: 计算PSNR
|-arith07.m: 算术编码压缩，用于Location Map的压缩
|-BaseMap.m: 生成初始2D映射
|-BoSW2_1k.mat: BOSW2图像库的实验结果（前1000张）
|-BoSW2_1w.mat: BOSW2图像库的实验结果（全10000张，仅1w与2w容量）
|-Embedding.m: 数据嵌入
|-Env1.m: 构造的环境类
|-Env.m：构造的环境类（弃用）
|-H2Da.m:生成2D直方图
|-kodak.mat: kodak图像库实验结果
|-LocationMap.m: 溢出像素预处理并生成Location Map
|-main.m: 主文件
|-map.mat: 2D映射相关结果
|-Mapping.m: Q学习算法实现
|-Prediction.m: 像素预测与配对
|-QLearning.m: 构造的Agent类
|-sorting.m: 排序算法，返回阈值T

```

## 实验结果

待更新...

## 实验环境
Matlab 2019 <br>


## 致谢
待更新...



## 引用格式
待更新...

## 版权声明
本项目已开源 (详见 ``` MIT LICENSE ``` ).

