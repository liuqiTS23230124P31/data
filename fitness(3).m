function [c,result,L]=fitness(x)





%% 以下部分是为了绘制结果图和显示中间变量
num_wt=20000;  %风机数量
num_pv=2168000;  %光伏板数量
num_ec=18000;   %电解槽数量
for i=1:2
num_b=x(1);  %蓄电池数量
num_c=x(2);
end
Load=zeros(1,8640);
for i=1:8640

Load(i)=10*num_ec;%全年负荷数据
end
load matlab6;

Speed_WT=unnamed1(1,:);%全年风速数据
Solar_PV=unnamed1(2,:);%全年光照强度数据 
T_c=unnamed1(3,:);%光伏板表面温度





%% 参数区
%1.风机
single_WT=10;%单台风机的额定功率/kW
v_ci=2.5;%切入风速
v_co=17;%切出风速
v_n=12;%额定风速
P_wt=zeros(1,8640);%单台风机的年功率曲线


%2.光伏
single_PV=0.083;%单个光伏板额定功率/kW
T_r=25;%太阳能电池温度为25℃
namd=-0.0047;%温度条件系数
G_n=1;%光谱辐照度为1000W/m2
P_pv=zeros(1,8640);%单片光伏板的年功率曲线


Eb=zeros(1,8640);
Ec=zeros(1,8640);

%4.蓄电池
E_b=1.2*60;%单台蓄电池容量kwmin
P_cha_max=0.12*num_b;%蓄电池总共最大充电功率
P_dis_max=0.12*num_b;%蓄电池总共最大放电功率
c_cha=0.8;%充电效率
c_dis=0.4;%放电效率
Soc_max=0.9;%荷电状态上限
Soc_min=0.1;%荷电状态下限
Soc_0=0.5;%荷电状态初始值
E_bmax=num_b*E_b*Soc_max;
E_bmin=num_b*E_b*Soc_min;
E_bo=num_b*E_b*Soc_0;

%5.超级电容
E_c=0.00354375*60;%单台超级电容容量

P_cha_maxc=4.05*num_c;%单台超级电容容量最大充电功率
P_dis_maxc=4.05*num_c;%单台超级电容容量最大放电功率
c_chac=0.98;%充电效率
c_disc=0.98;%放电效率
Soc_maxc=0.9;%荷电状态上限
Soc_minc=0.1;%荷电状态下限
Soc_0c=0.5;%荷电状态初始值
E_cmax=num_c*E_c*Soc_maxc;
E_cmin=num_c*E_c*Soc_minc;
E_co=num_c*E_c*Soc_0c;



%6.电解槽
P_ec=zeros(1,8640);%总的电解槽的年功率曲线
td=zeros(1,8640);
tnum=zeros(1,8640);%停机次数计算
%% 变量区

P_char=zeros(1,8640);%蓄电池充电功率
P_disr=zeros(1,8640);%蓄电池放电功率
P_chacr=zeros(1,8640);%超级电容充电功率
P_discr=zeros(1,8640);%超级电容放电功率
P_cha=zeros(1,8640);%蓄电池充电功率
P_dis=zeros(1,8640);%蓄电池放电功率
P_chac=zeros(1,8640);%超级电容充电功率
P_disc=zeros(1,8640);%超级电容放电功率
Q_was=zeros(1,8640);%弃风弃光能
Q_bre=zeros(1,8640);%切负荷能量
SOC=zeros(1,8640);%蓄电池荷电状态
SOCc=zeros(1,8640);%蓄电池荷电状态
mH2=zeros(1,8640);%每一时刻产生的氢气的物质的量
mH2T=zeros(1,8640);%每一时刻产生的氢气总量
mO2T=zeros(1,8640);%每一时刻产生的氧气总量
tb=zeros(1,8640);
tc=zeros(1,8640);
Qb=zeros(1,8640);
Qc=zeros(1,8640);
P_num=zeros(1,8640);
pub1=zeros(1,8640);
T=90;%全年风速数据

DOD=zeros(1,8640);
Arep=zeros(1,8640);
A1=zeros(1,8640);
A2=zeros(1,8640);
nr=zeros(1,8640);
Na=zeros(1,8640);






Urev=1.229;
Ucell=zeros(1,8640);
Uec=zeros(1,8640);
f1=zeros(1,8640);
f2=zeros(1,8640);
nF=zeros(1,8640);
qH2=zeros(1,8640);
Utn=zeros(1,8640);
nu=zeros(1,8640);
ne1=zeros(1,8640);
ni=zeros(1,8640);
Imidu=zeros(1,8640);
ne2=zeros(1,8640);
Iec=zeros(1,8640);
MH2=zeros(1,8640);
kT1=1.002;
kT2=8.424;          
kT3=247.3;
A=2.18;
s=0.185;
dertas=0.16;
r2=-2.5e-7;
r1=8.05e-5;
f11=2.5;
f12=50;
f21=-6.25e-6;
F=96486;
nec=328;
tnum=zeros(1,8640);%停机次数计算
t=zeros(1,8640);
Pe=zeros(1,8640);
%% 计算区
%根据风速求单台风机的年功率曲线
for i=1:8640
    if Speed_WT(i)>=0 && Speed_WT(i)<=v_ci
        P_wt(i)=0;
    elseif Speed_WT(i)>=v_ci && Speed_WT(i)<=v_n
        P_wt(i)=single_WT*(Speed_WT(i)-v_ci)/(v_n-v_ci);
    elseif Speed_WT(i)>=v_n && Speed_WT(i)<=v_co
        P_wt(i)=single_WT;
    else
        P_wt(i)=0;
    end
end
%根据光照强度和温度求单块光伏板的年功率曲线
for i=1:8640
    P_pv(i)=(single_PV*Solar_PV(i)/G_n)*(1+namd*(T_c(i)-T_r));
end

%% 功率分配
 
for i=1:8640
    Pfg(i)=num_wt*P_wt(i)+num_pv*P_pv(i);
    if i==1
         P_exc(i)=10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
      if P_exc(i)>0.5*Load(i) %负荷功率缺额
                
                    if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                      
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                        Eb(i)=E_bo-P_dis(i)/c_dis;
                        tb(i)=(E_bo-E_bmin)*c_dis/P_dis(i);%不超过容量限制的蓄电池最长放电时间
                        Ec(i)=E_co;
                        
                        if Eb(i)<E_bmin
                           Q_bre(i)=(E_bmin-Eb(i))*c_dis;
                           Eb(i)=E_bmin;
                           Qb(i)=tb(i)*P_exc(i);
                        else
                           Q_bre(i)=0; 
                            Qb(i)=P_exc(i);
                        end
                        Qc(i)=0;
                        Q_was(i)=0;
                 
                   elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                        tb(i)=(E_bo-E_bmin)*c_dis/P_dis(i);%不超过容量限制的蓄电池最长放电时间
                        tc(i)=(E_co-E_cmin)*0.98/P_disc(i);%不超过容量限制的超级电容最长放电时间
                        Eb(i)=E_bo-P_dis(i)/c_dis;%不考虑容量限制，放电一个小时后的容量
                        Ec(i)=E_co-P_disc(i)/0.98; %不考虑容量限制，放电一个小时后的容量
                        Q_was(i)=0;
                        if tb(i)>=1&&tc(i)>=1
                            Q_bre(i)=0;
                            Qb(i)=P_dis(i);
                            Qc(i)=P_disc(i);
                        elseif tb(i)<1%蓄电池先放电至最小容量
                            
                            Qb(i)=(E_bo-E_bmin)*c_dis;
                            if tc(i)<=1
                               
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(E_cmin-Ec(i))*0.98+(E_bmin-Eb(i))*c_dis;
                                 Eb(i)=E_bmin;  
                                  Ec(i)=E_cmin;%不考虑容量限制，放电一个小时后的容量
                               else       %超级电容容量达下限
                                   Q_bre(i)=(E_bmin-Eb(i))*c_dis;
                                   Qc(i)=P_disc(i);
                                  Eb(i)=E_bmin; 
                               end
                        elseif  tb(i)>=1&&tc(i)<1%功率缺额小于超级电容最大功率
                               
                               Qc(i)=(E_co-E_cmin)*c_disc; 
                                Qb(i)=P_dis(i);
                               Q_bre(i)=(E_cmin-Ec(i))*0.98;
                                   
                                 Ec(i)=E_cmin;  
                         end 
                           
                      
                    elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                         tb(i)=(E_bo-E_bmin)*c_dis/P_dis(i);
                         tc(i)=(E_co-E_cmin)*0.98/P_disc(i);
                         Eb(i)=E_bo-P_dis(i)/c_dis;
                         Ec(i)=E_co-P_disc(i)/0.98; 
                         Q_was(i)=0;
                         if Eb(i)<=E_bmin%%蓄电池达到容量下限
                            
                            Qb(i)=(E_bo-E_bmin)*c_dis;
                            if Ec(i)<=E_cmin%%超级电容达到容量下限
                                
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_bmin-Eb(i))*c_dis+(E_cmin-Ec(i))*c_disc;
                                Eb(i)=E_bmin;
                                Ec(i)=E_cmin;
                            else %%超级电容未达到容量下限
                                Qc(i)=P_dis_maxc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_bmin-Eb(i))*c_dis;
                                Eb(i)=E_bmin;
                            end
                         else      %%蓄电池未达到容量下限
                            Qb(i)=P_dis_max;   
                            if Ec(i)<=E_cmin%%超级电容达到容量下限
                                
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_cmin-Ec(i))*c_disc;
                                
                                Ec(i)=E_cmin;
                            else %%超级电容未达到容量下限
                               Qc(i)=P_dis_maxc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc);
                            end   
                         end
                    end

                               
                            
                         
                         
                         
                         
             elseif P_exc(i)<0    %负荷功率盈余
                Q_bre(i)=0;
                    
                    if abs(P_exc(i))<=P_cha_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                      
                         P_cha(i)=abs(P_exc(i));
                        P_chac(i)=0;
                       Eb(i)=E_bo+P_cha(i)*c_cha;
                       tb(i)=(E_bmax-E_bo)/(P_cha(i)*c_cha);%不超过容量限制的蓄电池最长放电时间
                        Ec(i)=E_co;
                        
                        if Eb(i)>E_bmax
                           Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                           Eb(i)=E_bmax;
                           Qb(i)=tb(i)*P_exc(i);
                        else
                           Q_was(i)=0; 
                            Qb(i)=P_exc(i);
                        end
                        Qc(i)=0;
                      
                        
                 
                   elseif abs(P_exc(i))>P_cha_max && abs(P_exc(i))<=(P_cha_max+P_cha_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_cha(i)=P_cha_max;
                        P_chac(i)=abs(P_exc(i))-P_cha(i);
                        
                      

                        tb(i)=(E_bmax-E_bo)/(P_cha(i)*c_cha);%不超过容量限制的蓄电池最长放电时间
                        tc(i)=(E_cmax-E_co)/(P_chac(i)*c_chac);%不超过容量限制的超级电容最长放电时间
                        Eb(i)=E_bo+P_cha(i)*c_cha;%不考虑容量限制，放电一个小时后的容量
                        Ec(i)=E_co+P_chac(i)*c_chac; %不考虑容量限制，放电一个小时后的容量
                        if tb(i)>=1&&tc(i)>=1
                            Q_was(i)=0;
                            Qb(i)=-P_cha(i);
                            Qc(i)=-P_chac(i);
                      
                        elseif tb(i)<1%蓄电池先放电至最小容量
                           Eb(i)=E_bmax;
                           Qb(i)=(E_bo-E_bmax)/c_cha;
                            if tc(i)<=1
                                Ec(i)=E_cmax;%不考虑容量限制，放电一个小时后的容量
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(Ec(i)-E_cmax)/0.98+(Eb(i)-E_bmax)/c_cha;
                                   
                               else       %超级电容容量达下限
                                   Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                                   Qc(i)=-P_chac(i);
                                   
                               end
                        elseif tb(i)>=1&&tc(i)<1%功率缺额小于超级电容最大功率
                               Ec(i)=E_cmax;
                               Qc(i)=(E_co-E_cmax)/c_chac;
                                Qb(i)=-P_cha(i);
                               Q_was(i)=(Ec(i)-E_cmax)/0.98;
                                   
                                   
                         end 
                       
                       
                       
                     
                    
                    elseif abs(P_exc(i))>(P_cha_max+P_cha_maxc)  
                         P_cha(i)=P_cha_max;
                         P_chac(i)=P_cha_maxc;
                         tb(i)=(E_bmax-E_bo)/(P_cha(i)*c_cha);
                         tc(i)=(E_cmax-E_co)/(P_chac(i)*c_chac);
                         Eb(i)=E_bo+P_cha(i)*c_cha;
                         Ec(i)=E_co+P_chac(i)*0.98; 
                         if Eb(i)>=E_bmax%%蓄电池达到容量下限
                            
                            Qb(i)=(E_bo-E_bmax)/c_cha;
                            if Ec(i)>=E_cmax%%超级电容达到容量下限
                                
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha+(Ec(i)-E_cmax)/c_chac;
                                Eb(i)=E_bmax;
                                Ec(i)=E_cmax;
                            else %%超级电容未达到容量下限
                                Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha;
                                Eb(i)=E_bmax;
                            end
                         else      %%蓄电池未达到容量下限
                            Qb(i)=-P_cha_max;   
                            if Ec(i)>=E_cmax%%超级电容达到容量下限
                                
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Ec(i)-E_cmax)/c_chac;
                                
                                Ec(i)=E_cmax;
                            else %%超级电容未达到容量下限
                               Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc);
                            end   
                         end
                    end
  else
          Ec(i)=E_co;
          Eb(i)=E_bo; 
          Q_bre(i)=P_exc(i);
            end
           
            
            
       P_ec(i)=10*num_ec-Q_bre(i);%第i小时内，总的电解槽的平均输入功率
            mH2(i)=(10*num_ec-Q_bre(i))*0.72*0.0252;%氢气的质量/kg
            mH2T(i)=mH2(i);
            mO2T(i)=mH2T(i)*9.496;%%氧气的质量/kg
   
         
       elseif i>1

           if Pfg(i)<10*num_ec
           
           if Pfg(i)<0.2*num_ec*10  %如果储能不放电则停机，目标是保证不停机
               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%两种储能均可放电
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
               elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%只有蓄电池可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
                elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%只有超级电容可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
               else
                  P_exc(i)=0.5*num_ec*10-Pfg(i);
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end
           
          
           
           
           
           
           
           
           elseif Pfg(i)>=0.2*num_ec*10&&Pfg(i)<0.5*num_ec*10

                if SOC(i-1)>0.5&&SOCc(i-1)>0.5%两种储能均可放电
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
               elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%只有蓄电池可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
                elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%只有超级电容可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
               else
                  P_exc(i)=0.5*num_ec*10-Pfg(i);
               if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end

          
           
           
           
           elseif Pfg(i)>=0.7*num_ec*10&&Pfg(i)<1*num_ec*10

               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%两种储能均可放电
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
          elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%只有蓄电池可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
        elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%只有超级电容可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
           else
                  P_exc(i)=0;
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end

           elseif Pfg(i)>=0.5*num_ec*10&&Pfg(i)<0.7*num_ec*10

               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%两种储能均可放电
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
          elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%只有蓄电池可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
        elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%只有超级电容可放电

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
           else
                  P_exc(i)=0.7*num_ec*10-Pfg(i);
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end




           end
         if P_exc(i)<0
              if SOCc(i-1)>0.1&&SOC(i-1)<=0.9
                          P_cha(i)=min(P_cha_max,P_dis_maxc);
                          P_disc(i)=P_cha(i);
                tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);
           tc(i)=(Ec(i-1)-E_cmin)*0.98/P_disc(i);
              if tb(i)>1&&tc(i)>1
                    Qb(i)=-P_cha(i);
                    Qc(i)=P_cha(i);
                Ec(i)=Ec(i-1)-P_disc(i)/0.98; 
                Eb(i)=Eb(i-1)+P_cha(i)*c_cha; 
              else
                    Qb(i)=-P_cha(i)*min(tb(i),tc(i));
                    Qc(i)=P_cha(i)*min(tb(i),tc(i));
                Ec(i)=Ec(i-1)-min(tb(i),tc(i))*P_disc(i)/0.98; 
                Eb(i)=Eb(i-1)+min(tb(i),tc(i))*P_cha(i)*c_cha;
              end
                       
         
                          else
                              Ec(i)=Ec(i-1);
                              Eb(i)=Eb(i-1);
                              Qb(i)=0;
                              Qc(i)=0;
              end
               Q_bre(i)=10*num_ec-Pfg(i); 
          
         else               
             if    P_dis(i)==0
                   tb(i)=0;
              else
                 tb(i)=(Eb(i-1)-E_bmin)*c_dis/P_dis(i);
              end
                if    P_disc(i)==0   
                    tc(i)=0;
                else
                  tc(i)=(Ec(i-1)-E_cmin)*0.98/P_disc(i);%不超过容量限制的超级电容最长放电时间
                end
                        Eb(i)=Eb(i-1)-P_dis(i)/c_dis;%不考虑容量限制，放电一个小时后的容量
                        Ec(i)=Ec(i-1)-P_disc(i)/0.98; %不考虑容量限制，放电一个小时后的容量
                        Q_was(i)=0;
                        if tb(i)>=1&&tc(i)>=1
                            Qb(i)=P_dis(i);
                            Qc(i)=P_disc(i);
                        elseif tb(i)<1%蓄电池先放电至最小容量
                            
                            Qb(i)=(Eb(i-1)-E_bmin)*c_dis;
                            if tc(i)<=1
                                
                                Qc(i)=(Ec(i-1)-E_cmin)*c_disc;
                                Eb(i)=E_bmin;  
                                 Ec(i)=E_cmin;
                               else       %超级电容容量达下限
                                   
                                   Qc(i)=P_disc(i);
                                    Eb(i)=E_bmin;
                               end
                        elseif  tb(i)>=1&&tc(i)<1%功率缺额小于超级电容最大功率
                                Qc(i)=(Ec(i-1)-E_cmin)*c_disc; 
                                Qb(i)=P_dis(i);
                             
                                  Ec(i)=E_cmin; 
                                   
                        end 
                    if tb(i)==0
                        Qb(i)=0;
                        Eb(i)=Eb(i-1);
                    end
                    if tc(i)==0
                        Qc(i)=0;
                        Ec(i)=Ec(i-1);
                    end

                    P_ec(i)=Pfg(i)+Qb(i)+Qc(i);       
                   Q_bre(i)=1*num_ec*10-P_ec(i); 
         end      
           
           elseif Pfg(i)>10*num_ec    %负荷功率盈余
               P_exc(i)=10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
             if  (SOC(i-1)==0.9||SOCc(i-1)==0.9)&&(10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i))<-400000
                   P_exc(i)=12*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
               end
                Q_bre(i)=0;
                  if abs(P_exc(i))<=P_cha_max  %case1:净负荷小于蓄电池最大功率且soc允许，由蓄电池补充缺额
                      
                         P_cha(i)=abs(P_exc(i));
                        P_chac(i)=0;
                       Eb(i)= Eb(i-1)+P_cha(i)*c_cha;
                       tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);%不超过容量限制的蓄电池最长放电时间
                        Ec(i)=Ec(i-1);
                        
                        if Eb(i)>E_bmax
                           Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                           Eb(i)=E_bmax;
                           Qb(i)=tb(i)*P_exc(i);
                        else
                           Q_was(i)=0; 
                            Qb(i)=P_exc(i);
                        end
                        Qc(i)=0;
                      
                 
                   elseif abs(P_exc(i))>P_cha_max && abs(P_exc(i))<=(P_cha_max+P_cha_maxc) %case2：净负荷大于蓄电池最大功率，小于蓄电池和主网售电最大功率了之和，蓄电池以最大功率放电，剩余不足由主网补充
                       P_cha(i)=P_cha_max;
                        P_chac(i)=abs(P_exc(i))-P_cha(i);
                        
                      

                        tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);%不超过容量限制的蓄电池最长放电时间
                        tc(i)=(E_cmax-Ec(i-1))/(P_chac(i)*c_chac);%不超过容量限制的超级电容最长放电时间
                        Eb(i)=Eb(i-1)+P_cha(i)*c_cha;%不考虑容量限制，放电一个小时后的容量
                        Ec(i)=Ec(i-1)+P_chac(i)*c_chac; %不考虑容量限制，放电一个小时后的容量
                        if tb(i)>=1&&tc(i)>=1
                            Q_was(i)=0;
                            Qb(i)=-P_cha(i);
                            Qc(i)=-P_chac(i);
                      
                        elseif tb(i)<1%蓄电池先放电至最小容量
                           
                           Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                            if tc(i)<=1
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(Ec(i)-E_cmax)/0.98+(Eb(i)-E_bmax)/c_cha;
                                 Eb(i)=E_bmax;  
                                 Ec(i)=E_cmax;%不考虑容量限制，放电一个小时后的容量
                               else       %超级电容容量达下限
                                   Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                                   Qc(i)=-P_chac(i);
                                   Eb(i)=E_bmax;
                               end
                        elseif  tb(i)>=1&&tc(i)<1%功率缺额小于超级电容最大功率
                              
                               Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Qb(i)=-P_cha(i);
                               Q_was(i)=(Ec(i)-E_cmax)/0.98;
                                 Ec(i)=E_cmax;   
                                   
                         end 
                       
                      
                    elseif abs(P_exc(i))>(P_cha_max+P_cha_maxc)  
                         P_cha(i)=P_cha_max;
                         P_chac(i)=P_cha_maxc;
                         tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);
                         tc(i)=(E_cmax-Ec(i-1))/(P_chac(i)*c_chac);
                         Eb(i)=Eb(i-1)+P_cha(i)*c_cha;
                         Ec(i)=Ec(i-1)+P_chac(i)*0.98; 
                         if Eb(i)>=E_bmax%%蓄电池达到容量下限
                            
                            Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                            if Ec(i)>=E_cmax%%超级电容达到容量下限
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha+(Ec(i)-E_cmax)/c_chac;
                                Eb(i)=E_bmax;
                                Ec(i)=E_cmax;
                            else %%超级电容未达到容量下限
                                Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha;
                                Eb(i)=E_bmax;
                            end
                         else      %%蓄电池未达到容量下限
                            Qb(i)=-P_cha_max;   
                            if Ec(i)>=E_cmax%%超级电容达到容量下限
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Ec(i)-E_cmax)/c_chac;
                                
                                Ec(i)=E_cmax;
                            else %%超级电容未达到容量下限
                               Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc);
                            end   
                         end
                    if Eb(i-1)<E_bmax&&Ec(i-1)>=E_cmax%%只有蓄电池能放电
                               Ec(i)=E_cmax;
                               Qc(i)=0;
                               if tb(i)<=1%蓄电池容量达到上限
                                  Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                                  Q_was(i)=(abs(P_exc(i))-P_cha_max)+((Eb(i-1)+P_cha(i)*c_cha)-E_bmax)/c_cha;
                                  Eb(i)=E_bmax;
                               else
                                  
                                  Q_was(i)=(abs(P_exc(i))-P_cha_max);
                               end
                            elseif Eb(i-1)>=E_bmax&&Ec(i-1)<E_cmax%%只有超级电容能放电
                               Eb(i)=E_bmax;
                               Qb(i)=0;
                               if tc(i)<=1%超级电容容量达到上限
                                  Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                  Q_was(i)=(abs(P_exc(i))-P_cha_maxc)+((Ec(i-1)+P_chac(i)*c_chac)-E_cmax)/c_chac;
                                  Ec(i)=E_cmax;
                               else
                                  
                                  Q_was(i)=(abs(P_exc(i))-P_cha_maxc);
                               end
                            end
                         end
                         if Eb(i-1)>=E_bmax&&Ec(i-1)>=E_cmax%%混合储能系统无法放电
                            Qb(i)=0;
                            Eb(i)=E_bmax;
                            Qc(i)=0;
                            Ec(i)=E_cmax;
                            Q_was(i)=abs(P_exc(i));
                         end
                        P_ec(i)=10*num_ec;
           else
    
                          if SOCc(i-1)>0.1&&SOC(i-1)<=0.9
                          P_cha(i)=min(P_cha_max,P_dis_maxc);
                          P_disc(i)=P_cha(i);
                tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);
           tc(i)=(Ec(i-1)-E_cmin)*0.98/P_disc(i);
              if tb(i)>1&&tc(i)>1
                    Qb(i)=-P_cha(i);
                    Qc(i)=P_cha(i);
                Ec(i)=Ec(i-1)-P_disc(i)/0.98; 
                Eb(i)=Eb(i-1)+P_cha(i)*c_cha; 
              else
                    Qb(i)=-P_cha(i)*min(tb(i),tc(i));
                    Qc(i)=P_cha(i)*min(tb(i),tc(i));
                Ec(i)=Ec(i-1)-min(tb(i),tc(i))*P_disc(i)/0.98; 
                Eb(i)=Eb(i-1)+min(tb(i),tc(i))*P_cha(i)*c_cha;
              end
                         
         
                          else
                              Ec(i)=Ec(i-1);
                              Eb(i)=Eb(i-1);
                              Qb(i)=0;
                              Qc(i)=0;
                          end
          Q_bre(i)=10*num_ec-Pfg(i);
          
            end
            
            
                  
           
            
            
          
            
            
                  
           
          


           end
           
       SOC(i)=Eb(i)/(E_b*num_b);
       DOD(i)=1-SOC(i);
       SOCc(i)=Ec(i)/(E_c*num_c); 
Na(i)=1500*((1/DOD(i))^0.19)*exp(1.69*(1-DOD(i)));
if Qb(i)==0
     Arep(i)=0;

else
 Arep(i)=1/(Na(i));
end
if i==1
    A1(i)=1-Arep(i);
else
    A1(i)=1-(A2(i-1)+Arep(i));
end
if  A1(i)<=0
    A2(i)=0;
    nr(i)=1;
else 
   A2(i)=A1(i);
   nr(i)=0;
end

          

    
       






















 
       P_char(i)=P_cha(i);%蓄电池充电功率
P_disr(i)=P_dis(i);%蓄电池放电功率
P_chacr(i)=P_chac(i);%超级电容充电功率
P_discr(i)=P_disc(i);%超级电容放电功率
if Qb(i)==0
P_char(i)=0;%蓄电池充电功率
P_disr(i)=0;%蓄电池放电功率
end
if Qc(i)==0
   P_chacr(i)=0;%蓄电池充电功率
P_discr(i)=0;%蓄电池放电功率 
end
    if Qb(i)==0
        P_num(i)=0;
    else
        P_num(i)=1;
    end
 
end
  for i=2:8640
 if  (SOC(i-1)==0.9||SOCc(i-1)==0.9)&&(10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i))<-400000
    P_ec(i)=num_ec*12;
 end
end 
for i=1:8640

if P_ec(i)<0.2*num_ec*10
    P_ec(i)=0;
end
Iec(i)=P_ec(i)*33.3333/780;  
Ucell(i)=s*log10((Iec(i)*(kT1+kT2/T+kT3/(T^2))/A)+1)+Urev+(r1+r2*T)*Iec(i)/A;%电解单元电压
Uec(i)=Ucell(i)*nec;%电解槽工作电压
nF(i)=0.96*((Iec(i)/A)^2)/(2.5e4+(Iec(i)/A)^2);
qH2(i)=nF(i)*nec*Iec(i)/(2*F);%制氢速率
Utn(i)=1.481+T*dertas/(2*F);
nu(i)=Utn(i)/Ucell(i);
ne1(i)=nF(i)*nu(i);%制氢效率
Imidu(i)=Iec(i)/A;
ni(i)=0.965*(2.718281828^(0.09/Iec(i)-75.5/Iec(i)));
MH2(i)=P_ec(i)*ne1(i)*0.0252/60;%每分钟产生氢气的质量
end

sum_Q_bre=0;
sum_Q_was=0;
sum_cishu=0;
s=0;
sum_pv=0;
sum_wt=0;
MH=0;
YMH2=0;

nrep=0;
for i=1:8640
  
    nrep=nrep+nr(i)/60;
end
for i=1:1440
    sum_Q_bre=sum_Q_bre+Q_bre(i)*13;
    sum_Q_was=sum_Q_was+Q_was(i)*13;
    sum_cishu=sum_cishu+ P_num(i)*13;
   sum_pv=sum_pv+P_pv(i)*13;
    sum_wt=sum_wt+P_wt(i)*13;
    YMH2=YMH2+MH2(i)*13;
    MH=MH+MH2(i);
end
H1=MH;%第一个典型日一天产氢质量
for i=1441:2880
    sum_Q_bre=sum_Q_bre+Q_bre(i)*222;
    sum_Q_was=sum_Q_was+Q_was(i)*222;
    sum_cishu=sum_cishu+ P_num(i)*222;
    sum_pv=sum_pv+P_pv(i)*222;
    sum_wt=sum_wt+P_wt(i)*222;
    YMH2=YMH2+MH2(i)*222;
    MH=MH+MH2(i);
end
H11=MH-H1;%第二个典型日一天产氢质量
for i=2881:4320
    sum_Q_bre=sum_Q_bre+Q_bre(i)*67;
    sum_Q_was=sum_Q_was+Q_was(i)*67;
    sum_cishu=sum_cishu+ P_num(i)*67;
    sum_pv=sum_pv+P_pv(i)*67;
    sum_wt=sum_wt+P_wt(i)*67;
    YMH2=YMH2+MH2(i)*67;
    MH=MH+MH2(i);
end
H3=MH-H1-H11;
for i=4321:5760
    sum_Q_bre=sum_Q_bre+Q_bre(i)*54;
    sum_Q_was=sum_Q_was+Q_was(i)*54;
    sum_cishu=sum_cishu+ P_num(i)*54;
    sum_pv=sum_pv+P_pv(i)*54;
    sum_wt=sum_wt+P_wt(i)*54;
 YMH2=YMH2+MH2(i)*54;
    MH=MH+MH2(i);
end
H4=MH-H1-H11-H3;
for i=5761:7200
    sum_Q_bre=sum_Q_bre+Q_bre(i)*7;
    sum_Q_was=sum_Q_was+Q_was(i)*7;
    sum_cishu=sum_cishu+ P_num(i)*7;
    sum_pv=sum_pv+P_pv(i)*7;
    sum_wt=sum_wt+P_wt(i)*7;
YMH2=YMH2+MH2(i)*7;
    MH=MH+MH2(i);
end
H5=MH-H1-H11-H3-H4;
for i=7201:8640
    sum_Q_bre=sum_Q_bre+Q_bre(i)*2;
    sum_Q_was=sum_Q_was+Q_was(i)*2;
    sum_cishu=sum_cishu+ P_num(i)*2;
    sum_pv=sum_pv+P_pv(i)*2;
    sum_wt=sum_wt+P_wt(i)*2;
YMH2=YMH2+MH2(i)*2;
    MH=MH+MH2(i);
end
H6=MH-H1-H11-H3-H4-H5;

mean_Pec=(10*num_ec*525600-sum_Q_bre)/525600;

for i=1:1440
   s=s+((P_ec(i)-mean_Pec)^2)*13;
   
end

for i=1441:2880
   s=s+((P_ec(i)-mean_Pec)^2)*222; 
end
for i=2881:4320
    s=s+((P_ec(i)-mean_Pec)^2)*67;
end

for i=4321:5760
    s=s+((P_ec(i)-mean_Pec)^2)*54;
end

for i=5761:7200
     s=s+((P_ec(i)-mean_Pec)^2)*7;
end

for i=7201:8640
    s=s+((P_ec(i)-mean_Pec)^2)*2;
end
s=((s/525600)^0.5)/mean_Pec;
%% 收益计算
  H2=YMH2;%产生氢气的年总质量
  O2=H2*9.496;%产生氧气的总质量
  
num_hst=max(max(H1,H11),max(max(H3,H6),max(H4,H5)));




  
  
  C_WT=num_wt*5000*10*0.02;
    C_PV=num_pv*4000*0.083*0.02;
    C_ec=num_ec*2500*10*0.01;
    C_b=num_b*400*0.2;
    C_c=num_c*300*0.09;
    C_hst=num_hst*3135*0.01;
    C_K=(C_WT+C_PV+C_ec+C_b+C_hst+C_c);%运维费用
    C_WTt=num_wt*5000*10;
    C_PVv=num_pv*4000*0.083;
    C_ecc=num_ec*2500*10;
    C_bb=num_b*400;
    C_cc=num_c*300;
    C_hstt=num_hst*3135;
    C_Kk=(C_WTt+C_PVv+C_ecc+C_hstt+C_cc);
    C_inv=0.08024*C_Kk+C_bb*0.08024;
   C_rep=num_b*400*nrep*0.08024;
    C_H2=(C_inv+C_K+C_rep)/H2;%年单位制氢成本
    
    
  
f_EWR=sum_Q_was/(sum_pv*num_pv+sum_wt*num_wt);%能源浪费率
f_LPSP=sum_Q_bre/(10*num_ec*525600);%缺电率
C_bre=1*sum_Q_bre;
C_was=sum_Q_was*1;
if f_LPSP>0.2
    pub1=1000000000000000;
else
    pub1=0;
end
if f_EWR>0.3
    pub2=10000000000;
else
    pub2=0;
end
if C_H2>45
    pub4=10000000000;
else
    pub4=0;
end
pub3=0;
for i=1:8640
  if Eb(i) > 1 * max(P_exc(i),0)     %蓄电池当前储能量和缺电量之间的关系（为了确保风光互补储能发电系统的稳定运行，避免蓄电池因长时间使用而损坏，蓄电池的储能量应该小于缺电量）
      pub3=pub3+100;
  end
end
%C_LPSP=0;
%C_EWR=0;

%C_bre=5000000*f_LPSP/10000;
   % C_was=f_EWR*0/10000;
%if f_EWR>0.2
   %C_EWR= (f_EWR-0.2)*1000/10000;%能源浪费惩罚
%end
%if f_LPSP>0.1
 %  C_LPSP= (f_LPSP-0.1)*1000/10000;%切负荷惩罚
%end

L=0*f_EWR+f_LPSP;
f=C_H2;

result=f;




%% 判断是否为可行解



     c=0;




end

