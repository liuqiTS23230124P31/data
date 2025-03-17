function [c,result,L]=fitness(x)





%% ���²�����Ϊ�˻��ƽ��ͼ����ʾ�м����
num_wt=20000;  %�������
num_pv=2168000;  %���������
num_ec=18000;   %��������
for i=1:2
num_b=x(1);  %��������
num_c=x(2);
end
Load=zeros(1,8640);
for i=1:8640

Load(i)=10*num_ec;%ȫ�긺������
end
load matlab6;

Speed_WT=unnamed1(1,:);%ȫ���������
Solar_PV=unnamed1(2,:);%ȫ�����ǿ������ 
T_c=unnamed1(3,:);%���������¶�





%% ������
%1.���
single_WT=10;%��̨����Ķ����/kW
v_ci=2.5;%�������
v_co=17;%�г�����
v_n=12;%�����
P_wt=zeros(1,8640);%��̨������깦������


%2.���
single_PV=0.083;%�������������/kW
T_r=25;%̫���ܵ���¶�Ϊ25��
namd=-0.0047;%�¶�����ϵ��
G_n=1;%���׷��ն�Ϊ1000W/m2
P_pv=zeros(1,8640);%��Ƭ�������깦������


Eb=zeros(1,8640);
Ec=zeros(1,8640);

%4.����
E_b=1.2*60;%��̨��������kwmin
P_cha_max=0.12*num_b;%�����ܹ�����繦��
P_dis_max=0.12*num_b;%�����ܹ����ŵ繦��
c_cha=0.8;%���Ч��
c_dis=0.4;%�ŵ�Ч��
Soc_max=0.9;%�ɵ�״̬����
Soc_min=0.1;%�ɵ�״̬����
Soc_0=0.5;%�ɵ�״̬��ʼֵ
E_bmax=num_b*E_b*Soc_max;
E_bmin=num_b*E_b*Soc_min;
E_bo=num_b*E_b*Soc_0;

%5.��������
E_c=0.00354375*60;%��̨������������

P_cha_maxc=4.05*num_c;%��̨����������������繦��
P_dis_maxc=4.05*num_c;%��̨���������������ŵ繦��
c_chac=0.98;%���Ч��
c_disc=0.98;%�ŵ�Ч��
Soc_maxc=0.9;%�ɵ�״̬����
Soc_minc=0.1;%�ɵ�״̬����
Soc_0c=0.5;%�ɵ�״̬��ʼֵ
E_cmax=num_c*E_c*Soc_maxc;
E_cmin=num_c*E_c*Soc_minc;
E_co=num_c*E_c*Soc_0c;



%6.����
P_ec=zeros(1,8640);%�ܵĵ��۵��깦������
td=zeros(1,8640);
tnum=zeros(1,8640);%ͣ����������
%% ������

P_char=zeros(1,8640);%���س�繦��
P_disr=zeros(1,8640);%���طŵ繦��
P_chacr=zeros(1,8640);%�������ݳ�繦��
P_discr=zeros(1,8640);%�������ݷŵ繦��
P_cha=zeros(1,8640);%���س�繦��
P_dis=zeros(1,8640);%���طŵ繦��
P_chac=zeros(1,8640);%�������ݳ�繦��
P_disc=zeros(1,8640);%�������ݷŵ繦��
Q_was=zeros(1,8640);%����������
Q_bre=zeros(1,8640);%�и�������
SOC=zeros(1,8640);%���غɵ�״̬
SOCc=zeros(1,8640);%���غɵ�״̬
mH2=zeros(1,8640);%ÿһʱ�̲��������������ʵ���
mH2T=zeros(1,8640);%ÿһʱ�̲�������������
mO2T=zeros(1,8640);%ÿһʱ�̲�������������
tb=zeros(1,8640);
tc=zeros(1,8640);
Qb=zeros(1,8640);
Qc=zeros(1,8640);
P_num=zeros(1,8640);
pub1=zeros(1,8640);
T=90;%ȫ���������

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
tnum=zeros(1,8640);%ͣ����������
t=zeros(1,8640);
Pe=zeros(1,8640);
%% ������
%���ݷ�����̨������깦������
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
%���ݹ���ǿ�Ⱥ��¶��󵥿�������깦������
for i=1:8640
    P_pv(i)=(single_PV*Solar_PV(i)/G_n)*(1+namd*(T_c(i)-T_r));
end

%% ���ʷ���
 
for i=1:8640
    Pfg(i)=num_wt*P_wt(i)+num_pv*P_pv(i);
    if i==1
         P_exc(i)=10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
      if P_exc(i)>0.5*Load(i) %���ɹ���ȱ��
                
                    if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                      
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                        Eb(i)=E_bo-P_dis(i)/c_dis;
                        tb(i)=(E_bo-E_bmin)*c_dis/P_dis(i);%�������������Ƶ�������ŵ�ʱ��
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
                 
                   elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                        tb(i)=(E_bo-E_bmin)*c_dis/P_dis(i);%�������������Ƶ�������ŵ�ʱ��
                        tc(i)=(E_co-E_cmin)*0.98/P_disc(i);%�������������Ƶĳ���������ŵ�ʱ��
                        Eb(i)=E_bo-P_dis(i)/c_dis;%�������������ƣ��ŵ�һ��Сʱ�������
                        Ec(i)=E_co-P_disc(i)/0.98; %�������������ƣ��ŵ�һ��Сʱ�������
                        Q_was(i)=0;
                        if tb(i)>=1&&tc(i)>=1
                            Q_bre(i)=0;
                            Qb(i)=P_dis(i);
                            Qc(i)=P_disc(i);
                        elseif tb(i)<1%�����ȷŵ�����С����
                            
                            Qb(i)=(E_bo-E_bmin)*c_dis;
                            if tc(i)<=1
                               
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(E_cmin-Ec(i))*0.98+(E_bmin-Eb(i))*c_dis;
                                 Eb(i)=E_bmin;  
                                  Ec(i)=E_cmin;%�������������ƣ��ŵ�һ��Сʱ�������
                               else       %������������������
                                   Q_bre(i)=(E_bmin-Eb(i))*c_dis;
                                   Qc(i)=P_disc(i);
                                  Eb(i)=E_bmin; 
                               end
                        elseif  tb(i)>=1&&tc(i)<1%����ȱ��С�ڳ������������
                               
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
                         if Eb(i)<=E_bmin%%���شﵽ��������
                            
                            Qb(i)=(E_bo-E_bmin)*c_dis;
                            if Ec(i)<=E_cmin%%�������ݴﵽ��������
                                
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_bmin-Eb(i))*c_dis+(E_cmin-Ec(i))*c_disc;
                                Eb(i)=E_bmin;
                                Ec(i)=E_cmin;
                            else %%��������δ�ﵽ��������
                                Qc(i)=P_dis_maxc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_bmin-Eb(i))*c_dis;
                                Eb(i)=E_bmin;
                            end
                         else      %%����δ�ﵽ��������
                            Qb(i)=P_dis_max;   
                            if Ec(i)<=E_cmin%%�������ݴﵽ��������
                                
                                Qc(i)=(E_co-E_cmin)*c_disc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc)+(E_cmin-Ec(i))*c_disc;
                                
                                Ec(i)=E_cmin;
                            else %%��������δ�ﵽ��������
                               Qc(i)=P_dis_maxc;
                                Q_bre(i)=(P_exc(i)-P_dis_max-P_dis_maxc);
                            end   
                         end
                    end

                               
                            
                         
                         
                         
                         
             elseif P_exc(i)<0    %���ɹ���ӯ��
                Q_bre(i)=0;
                    
                    if abs(P_exc(i))<=P_cha_max  %case1:������С�������������soc���������ز���ȱ��
                      
                         P_cha(i)=abs(P_exc(i));
                        P_chac(i)=0;
                       Eb(i)=E_bo+P_cha(i)*c_cha;
                       tb(i)=(E_bmax-E_bo)/(P_cha(i)*c_cha);%�������������Ƶ�������ŵ�ʱ��
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
                      
                        
                 
                   elseif abs(P_exc(i))>P_cha_max && abs(P_exc(i))<=(P_cha_max+P_cha_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_cha(i)=P_cha_max;
                        P_chac(i)=abs(P_exc(i))-P_cha(i);
                        
                      

                        tb(i)=(E_bmax-E_bo)/(P_cha(i)*c_cha);%�������������Ƶ�������ŵ�ʱ��
                        tc(i)=(E_cmax-E_co)/(P_chac(i)*c_chac);%�������������Ƶĳ���������ŵ�ʱ��
                        Eb(i)=E_bo+P_cha(i)*c_cha;%�������������ƣ��ŵ�һ��Сʱ�������
                        Ec(i)=E_co+P_chac(i)*c_chac; %�������������ƣ��ŵ�һ��Сʱ�������
                        if tb(i)>=1&&tc(i)>=1
                            Q_was(i)=0;
                            Qb(i)=-P_cha(i);
                            Qc(i)=-P_chac(i);
                      
                        elseif tb(i)<1%�����ȷŵ�����С����
                           Eb(i)=E_bmax;
                           Qb(i)=(E_bo-E_bmax)/c_cha;
                            if tc(i)<=1
                                Ec(i)=E_cmax;%�������������ƣ��ŵ�һ��Сʱ�������
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(Ec(i)-E_cmax)/0.98+(Eb(i)-E_bmax)/c_cha;
                                   
                               else       %������������������
                                   Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                                   Qc(i)=-P_chac(i);
                                   
                               end
                        elseif tb(i)>=1&&tc(i)<1%����ȱ��С�ڳ������������
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
                         if Eb(i)>=E_bmax%%���شﵽ��������
                            
                            Qb(i)=(E_bo-E_bmax)/c_cha;
                            if Ec(i)>=E_cmax%%�������ݴﵽ��������
                                
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha+(Ec(i)-E_cmax)/c_chac;
                                Eb(i)=E_bmax;
                                Ec(i)=E_cmax;
                            else %%��������δ�ﵽ��������
                                Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha;
                                Eb(i)=E_bmax;
                            end
                         else      %%����δ�ﵽ��������
                            Qb(i)=-P_cha_max;   
                            if Ec(i)>=E_cmax%%�������ݴﵽ��������
                                
                                Qc(i)=(E_co-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Ec(i)-E_cmax)/c_chac;
                                
                                Ec(i)=E_cmax;
                            else %%��������δ�ﵽ��������
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
           
            
            
       P_ec(i)=10*num_ec-Q_bre(i);%��iСʱ�ڣ��ܵĵ��۵�ƽ�����빦��
            mH2(i)=(10*num_ec-Q_bre(i))*0.72*0.0252;%����������/kg
            mH2T(i)=mH2(i);
            mO2T(i)=mH2T(i)*9.496;%%����������/kg
   
         
       elseif i>1

           if Pfg(i)<10*num_ec
           
           if Pfg(i)<0.2*num_ec*10  %������ܲ��ŵ���ͣ����Ŀ���Ǳ�֤��ͣ��
               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%���ִ��ܾ��ɷŵ�
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
               elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%ֻ�����ؿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
                elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%ֻ�г������ݿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
               else
                  P_exc(i)=0.5*num_ec*10-Pfg(i);
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end
           
          
           
           
           
           
           
           
           elseif Pfg(i)>=0.2*num_ec*10&&Pfg(i)<0.5*num_ec*10

                if SOC(i-1)>0.5&&SOCc(i-1)>0.5%���ִ��ܾ��ɷŵ�
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
               elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%ֻ�����ؿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
                elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%ֻ�г������ݿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
               else
                  P_exc(i)=0.5*num_ec*10-Pfg(i);
               if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end

          
           
           
           
           elseif Pfg(i)>=0.7*num_ec*10&&Pfg(i)<1*num_ec*10

               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%���ִ��ܾ��ɷŵ�
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
          elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%ֻ�����ؿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
        elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%ֻ�г������ݿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
           else
                  P_exc(i)=0;
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
              else
                        P_disc(i)=P_dis_maxc;
                       

              end
              end
               end

           elseif Pfg(i)>=0.5*num_ec*10&&Pfg(i)<0.7*num_ec*10

               if SOC(i-1)>0.5&&SOCc(i-1)>0.5%���ִ��ܾ��ɷŵ�
                     P_exc(i)=1*num_ec*10-Pfg(i);
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
          elseif  SOC(i-1)>0.5&&SOCc(i-1)<=0.5%ֻ�����ؿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_disc(i)=0;
                if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
                else
                        P_dis(i)=P_dis_max;
                end
        elseif  SOC(i-1)<=0.5&&SOCc(i-1)>0.5%ֻ�г������ݿɷŵ�

                        P_exc(i)=1*num_ec*10-Pfg(i);
                        P_dis(i)=0;
                if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
                        P_disc(i)=P_exc(i);
                        
                else
                        P_disc(i)=P_dis_maxc;
                end
           
           else
                  P_exc(i)=0.7*num_ec*10-Pfg(i);
              if SOC(i-1)>0.1&&SOCc(i-1)>0.1
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        P_disc(i)=0;
                elseif P_exc(i)>P_dis_max && P_exc(i)<=(P_dis_max+P_dis_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                        P_dis(i)=P_dis_max;
                        P_disc(i)=P_exc(i)-P_dis(i);
                elseif P_exc(i)>(P_dis_max+P_dis_maxc)  
                         P_dis(i)=P_dis_max;
                         P_disc(i)=P_dis_maxc;
                end
              elseif SOC(i-1)>0.1&&SOCc(i-1)<=0.1
                  P_disc(i)=0;
              if P_exc(i)<=P_dis_max  %case1:������С�������������soc���������ز���ȱ��
                        P_dis(i)=P_exc(i);
                        
              else
                        P_dis(i)=P_dis_max;
                       

               end
    elseif SOC(i-1)<=0.1&&SOCc(i-1)>0.1
                  P_dis(i)=0;
              if P_exc(i)<=P_dis_maxc  %case1:������С�������������soc���������ز���ȱ��
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
                  tc(i)=(Ec(i-1)-E_cmin)*0.98/P_disc(i);%�������������Ƶĳ���������ŵ�ʱ��
                end
                        Eb(i)=Eb(i-1)-P_dis(i)/c_dis;%�������������ƣ��ŵ�һ��Сʱ�������
                        Ec(i)=Ec(i-1)-P_disc(i)/0.98; %�������������ƣ��ŵ�һ��Сʱ�������
                        Q_was(i)=0;
                        if tb(i)>=1&&tc(i)>=1
                            Qb(i)=P_dis(i);
                            Qc(i)=P_disc(i);
                        elseif tb(i)<1%�����ȷŵ�����С����
                            
                            Qb(i)=(Eb(i-1)-E_bmin)*c_dis;
                            if tc(i)<=1
                                
                                Qc(i)=(Ec(i-1)-E_cmin)*c_disc;
                                Eb(i)=E_bmin;  
                                 Ec(i)=E_cmin;
                               else       %������������������
                                   
                                   Qc(i)=P_disc(i);
                                    Eb(i)=E_bmin;
                               end
                        elseif  tb(i)>=1&&tc(i)<1%����ȱ��С�ڳ������������
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
           
           elseif Pfg(i)>10*num_ec    %���ɹ���ӯ��
               P_exc(i)=10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
             if  (SOC(i-1)==0.9||SOCc(i-1)==0.9)&&(10*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i))<-400000
                   P_exc(i)=12*num_ec-num_wt*P_wt(i)-num_pv*P_pv(i);
               end
                Q_bre(i)=0;
                  if abs(P_exc(i))<=P_cha_max  %case1:������С�������������soc���������ز���ȱ��
                      
                         P_cha(i)=abs(P_exc(i));
                        P_chac(i)=0;
                       Eb(i)= Eb(i-1)+P_cha(i)*c_cha;
                       tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);%�������������Ƶ�������ŵ�ʱ��
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
                      
                 
                   elseif abs(P_exc(i))>P_cha_max && abs(P_exc(i))<=(P_cha_max+P_cha_maxc) %case2�������ɴ�����������ʣ�С�����غ������۵��������֮�ͣ�����������ʷŵ磬ʣ�಻������������
                       P_cha(i)=P_cha_max;
                        P_chac(i)=abs(P_exc(i))-P_cha(i);
                        
                      

                        tb(i)=(E_bmax-Eb(i-1))/(P_cha(i)*c_cha);%�������������Ƶ�������ŵ�ʱ��
                        tc(i)=(E_cmax-Ec(i-1))/(P_chac(i)*c_chac);%�������������Ƶĳ���������ŵ�ʱ��
                        Eb(i)=Eb(i-1)+P_cha(i)*c_cha;%�������������ƣ��ŵ�һ��Сʱ�������
                        Ec(i)=Ec(i-1)+P_chac(i)*c_chac; %�������������ƣ��ŵ�һ��Сʱ�������
                        if tb(i)>=1&&tc(i)>=1
                            Q_was(i)=0;
                            Qb(i)=-P_cha(i);
                            Qc(i)=-P_chac(i);
                      
                        elseif tb(i)<1%�����ȷŵ�����С����
                           
                           Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                            if tc(i)<=1
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(Ec(i)-E_cmax)/0.98+(Eb(i)-E_bmax)/c_cha;
                                 Eb(i)=E_bmax;  
                                 Ec(i)=E_cmax;%�������������ƣ��ŵ�һ��Сʱ�������
                               else       %������������������
                                   Q_was(i)=(Eb(i)-E_bmax)/c_cha;
                                   Qc(i)=-P_chac(i);
                                   Eb(i)=E_bmax;
                               end
                        elseif  tb(i)>=1&&tc(i)<1%����ȱ��С�ڳ������������
                              
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
                         if Eb(i)>=E_bmax%%���شﵽ��������
                            
                            Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                            if Ec(i)>=E_cmax%%�������ݴﵽ��������
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha+(Ec(i)-E_cmax)/c_chac;
                                Eb(i)=E_bmax;
                                Ec(i)=E_cmax;
                            else %%��������δ�ﵽ��������
                                Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Eb(i)-E_bmax)/c_cha;
                                Eb(i)=E_bmax;
                            end
                         else      %%����δ�ﵽ��������
                            Qb(i)=-P_cha_max;   
                            if Ec(i)>=E_cmax%%�������ݴﵽ��������
                                
                                Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc)+(Ec(i)-E_cmax)/c_chac;
                                
                                Ec(i)=E_cmax;
                            else %%��������δ�ﵽ��������
                               Qc(i)=-P_cha_maxc;
                                Q_was(i)=(abs(P_exc(i))-P_cha_max-P_cha_maxc);
                            end   
                         end
                    if Eb(i-1)<E_bmax&&Ec(i-1)>=E_cmax%%ֻ�������ܷŵ�
                               Ec(i)=E_cmax;
                               Qc(i)=0;
                               if tb(i)<=1%���������ﵽ����
                                  Qb(i)=(Eb(i-1)-E_bmax)/c_cha;
                                  Q_was(i)=(abs(P_exc(i))-P_cha_max)+((Eb(i-1)+P_cha(i)*c_cha)-E_bmax)/c_cha;
                                  Eb(i)=E_bmax;
                               else
                                  
                                  Q_was(i)=(abs(P_exc(i))-P_cha_max);
                               end
                            elseif Eb(i-1)>=E_bmax&&Ec(i-1)<E_cmax%%ֻ�г��������ܷŵ�
                               Eb(i)=E_bmax;
                               Qb(i)=0;
                               if tc(i)<=1%�������������ﵽ����
                                  Qc(i)=(Ec(i-1)-E_cmax)/c_chac;
                                  Q_was(i)=(abs(P_exc(i))-P_cha_maxc)+((Ec(i-1)+P_chac(i)*c_chac)-E_cmax)/c_chac;
                                  Ec(i)=E_cmax;
                               else
                                  
                                  Q_was(i)=(abs(P_exc(i))-P_cha_maxc);
                               end
                            end
                         end
                         if Eb(i-1)>=E_bmax&&Ec(i-1)>=E_cmax%%��ϴ���ϵͳ�޷��ŵ�
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

          

    
       






















 
       P_char(i)=P_cha(i);%���س�繦��
P_disr(i)=P_dis(i);%���طŵ繦��
P_chacr(i)=P_chac(i);%�������ݳ�繦��
P_discr(i)=P_disc(i);%�������ݷŵ繦��
if Qb(i)==0
P_char(i)=0;%���س�繦��
P_disr(i)=0;%���طŵ繦��
end
if Qc(i)==0
   P_chacr(i)=0;%���س�繦��
P_discr(i)=0;%���طŵ繦�� 
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
Ucell(i)=s*log10((Iec(i)*(kT1+kT2/T+kT3/(T^2))/A)+1)+Urev+(r1+r2*T)*Iec(i)/A;%��ⵥԪ��ѹ
Uec(i)=Ucell(i)*nec;%���۹�����ѹ
nF(i)=0.96*((Iec(i)/A)^2)/(2.5e4+(Iec(i)/A)^2);
qH2(i)=nF(i)*nec*Iec(i)/(2*F);%��������
Utn(i)=1.481+T*dertas/(2*F);
nu(i)=Utn(i)/Ucell(i);
ne1(i)=nF(i)*nu(i);%����Ч��
Imidu(i)=Iec(i)/A;
ni(i)=0.965*(2.718281828^(0.09/Iec(i)-75.5/Iec(i)));
MH2(i)=P_ec(i)*ne1(i)*0.0252/60;%ÿ���Ӳ�������������
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
H1=MH;%��һ��������һ���������
for i=1441:2880
    sum_Q_bre=sum_Q_bre+Q_bre(i)*222;
    sum_Q_was=sum_Q_was+Q_was(i)*222;
    sum_cishu=sum_cishu+ P_num(i)*222;
    sum_pv=sum_pv+P_pv(i)*222;
    sum_wt=sum_wt+P_wt(i)*222;
    YMH2=YMH2+MH2(i)*222;
    MH=MH+MH2(i);
end
H11=MH-H1;%�ڶ���������һ���������
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
%% �������
  H2=YMH2;%������������������
  O2=H2*9.496;%����������������
  
num_hst=max(max(H1,H11),max(max(H3,H6),max(H4,H5)));




  
  
  C_WT=num_wt*5000*10*0.02;
    C_PV=num_pv*4000*0.083*0.02;
    C_ec=num_ec*2500*10*0.01;
    C_b=num_b*400*0.2;
    C_c=num_c*300*0.09;
    C_hst=num_hst*3135*0.01;
    C_K=(C_WT+C_PV+C_ec+C_b+C_hst+C_c);%��ά����
    C_WTt=num_wt*5000*10;
    C_PVv=num_pv*4000*0.083;
    C_ecc=num_ec*2500*10;
    C_bb=num_b*400;
    C_cc=num_c*300;
    C_hstt=num_hst*3135;
    C_Kk=(C_WTt+C_PVv+C_ecc+C_hstt+C_cc);
    C_inv=0.08024*C_Kk+C_bb*0.08024;
   C_rep=num_b*400*nrep*0.08024;
    C_H2=(C_inv+C_K+C_rep)/H2;%�굥λ����ɱ�
    
    
  
f_EWR=sum_Q_was/(sum_pv*num_pv+sum_wt*num_wt);%��Դ�˷���
f_LPSP=sum_Q_bre/(10*num_ec*525600);%ȱ����
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
  if Eb(i) > 1 * max(P_exc(i),0)     %���ص�ǰ��������ȱ����֮��Ĺ�ϵ��Ϊ��ȷ����⻥�����ܷ���ϵͳ���ȶ����У�����������ʱ��ʹ�ö��𻵣����صĴ�����Ӧ��С��ȱ������
      pub3=pub3+100;
  end
end
%C_LPSP=0;
%C_EWR=0;

%C_bre=5000000*f_LPSP/10000;
   % C_was=f_EWR*0/10000;
%if f_EWR>0.2
   %C_EWR= (f_EWR-0.2)*1000/10000;%��Դ�˷ѳͷ�
%end
%if f_LPSP>0.1
 %  C_LPSP= (f_LPSP-0.1)*1000/10000;%�и��ɳͷ�
%end

L=0*f_EWR+f_LPSP;
f=C_H2;

result=f;




%% �ж��Ƿ�Ϊ���н�



     c=0;




end

