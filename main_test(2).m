%�����ʼ��
clear;
clc;
close all;
%����ȫ�ֱ���


%% ����mopso����
mm=mopso; %����mopso����
nn=length(mm.swarm); %��֧�����Ŀ

%% �Ƚϲ�ͬĿ�꺯��Ѱ�ŶԵ��Ƚ����Ӱ��
%% ��1��.������Ŀ�꺯��ֵ��һ����ӣ�ȡ��Ӻ���С��Ŀ��ֵ�����ӣ���Ѱ�����ԽⲢ��ͼ
%����֧����е����гɱ��ͻ��������ɱ��ֱ�ֵ��yyy,xxx
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
[m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
 pg=mm.swarm(1,p).x; %pgΪ���Խ�
 Title = sprintf('���Խ������');
%% ��2��Ѱ���ܳɱ����ʱ�ĽⲢ��ͼ
%for i=1:nn
    %object(i)= mm.swarm(1,i).cost(1)+mm.swarm(1,i).cost(2);
%end
%[m,p]=max(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
%pg=mm.swarm(1,p).x; %pgΪ�ܳɱ����ʱ�Ľ�
%Title = sprintf('��������������');
%% ��3��Ѱ�����гɱ����ʱ�ĽⲢ��ͼ
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(1);
% end
% [m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
% pg=mm.swarm(1,p).x; %pgΪ���гɱ����ʱ�Ľ�
% Title = sprintf('���гɱ���������');
%% ��4��Ѱ�һ��������ɱ����ʱ�ĽⲢ��ͼ
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(2);
% end
% [m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
% pg=mm.swarm(1,p).x; %pgΪ���������ɱ����ʱ�Ľ�
% Title = sprintf('���������ɱ���������');

%% ��ͬ����µĽ⸳ֵ
 for m=1:2
   pg_N(m)=pg(m);
   num_b=pg(1);
    num_c=pg(2);
 end  
 
 

%% ��ͼ




disp(['��������Ϊ��',num2str(num_b)]);
disp(['������������Ϊ��',num2str(num_c)]);


