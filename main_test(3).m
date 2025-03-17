%程序初始化
clear;
clc;
close all;
%定义全局变量


%% 调用mopso函数
mm=mopso; %调用mopso函数
nn=length(mm.swarm); %非支配解数目

%% 比较不同目标函数寻优对调度结果的影响
%% 第1种.将两个目标函数值归一化相加，取相加后最小的目标值的粒子，即寻找折衷解并画图
%将非支配解中的运行成本和环境保护成本分别赋值给yyy,xxx
 for m=1:nn
    yyy(m)= mm.swarm(1,m).cost(1);
    xxx(m)= mm.swarm(1,m).cost(2);
 end
 m1=max(yyy);
 m2=max(xxx);

 for m=1:nn
     object(m)= 0.1*mm.swarm(1,m).cost(1)./m1+0.9* mm.swarm(1,m).cost(2)./m2;
     f1(m)=mm.swarm(1,m).cost(1)./m1;
     f2(m)=mm.swarm(1,m).cost(2)./m2;
end
[m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
 pg=mm.swarm(1,p).x; %pg为折衷解
 Title = sprintf('折衷解情况下');
%% 第2种寻找总成本最低时的解并画图
%for i=1:nn
    %object(i)= mm.swarm(1,i).cost(1)+mm.swarm(1,i).cost(2);
%end
%[m,p]=max(object); %得到有着最小目标值的微粒所在的行数P
%pg=mm.swarm(1,p).x; %pg为总成本最低时的解
%Title = sprintf('总利润最高情况下');
%% 第3种寻找运行成本最低时的解并画图
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(1);
% end
% [m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
% pg=mm.swarm(1,p).x; %pg为运行成本最低时的解
% Title = sprintf('运行成本最低情况下');
%% 第4种寻找环境保护成本最低时的解并画图
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(2);
% end
% [m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
% pg=mm.swarm(1,p).x; %pg为环境保护成本最低时的解
% Title = sprintf('环境保护成本最低情况下');

%% 不同情况下的解赋值
 for m=1:2
   pg_N(m)=pg(m);
   num_b=pg(1);
    num_c=pg(2);
 end  
 
 

%% 画图




disp(['蓄电池数量为：',num2str(num_b)]);
disp(['超级电容数量为：',num2str(num_c)]);



