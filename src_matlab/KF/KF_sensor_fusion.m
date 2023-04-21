%Kalman Filter实例
%问题：用计算机生成一个含正态噪声的信号，使用KF滤波
%状态信号：x=t^2
%问题分析:
%X(k)=F*X(k-1)+Q 状态方程   Q:建模误差
%Y1(k)=H*X(k)+R1   观测方程   R:传感器误差
%Y2(k)=H*X(k)+R2
%%%KF滤波5大公式%%%
%%%预测步%%%
%Xminus(k)=F*Xplus(k-1)
%Pminus(k)=F*Pplus(k-1)*F'+Q
%%%更新步%%%
%K=Pminus(k)*H'*inv(H*Pminus(k)*H'+R)
%Xplus(k)=Xminus(k)+K*(Y(k)-H*Xminus(k))
%Pplus(k)=(I-K*H)Pminus(k)
%%%初始条件%%%
%Y(k) F H Q R

%生成一段时间t
t=0.1:0.01:1;
L=length(t);
%生成真实信号x(t)-->观测信号y(t)
%首先初始化
x=ones(1,L);
y=ones(2,L);
%生成信号
for i=1:L
    x(i)=t(i)^2;
    y(1,i)=x(i)+normrnd(0,0.1);
    y(2,i)=x(i)+normrnd(0,0.1);
end
%%%%信号生成完毕%%%%
plot(t,x,'r',t,y(1,:),'g',t,y(2,:),'b','LineWidth',2);
%红色：准确信号  绿色：传感器1观测信号 蓝色；传感器2观测信号
%实际初始只有观测信号
%%%%滤波算法%%%%
%根据状态方程以及观测方程 设定F,H,Q,R
%x(k)=x(k-1)+x'(k-1)*dt+x''(k-1)*dt^2*(1/2!)+Q
%y(k)=x(k)+R R~(0,1)
%此时状态变量X=[x(k),x'(k),x''(k)]' 列向量 
%x(k)=x(k-1)+x'(k-1)*dt+x''(k-1)*dt^2*(1/2!)+Q2
%x'(k)=0*x(k-1)+x'(k-1)+x''(k-1)*dt^2+Q3
%x''(k)=0*x(k-1)+0*x'(k-1)+x''(k-1)+Q4
%得F=[1    dt 0.5*dt^2
%     0    1    dt
%     0    0    1     ]
%H=[1,0,0
%   1,0,0] 
%Q=[Q2,0,0
%   0,Q3,0
%   0,0,Q4]
%R=[R1,0
%   0，R2]协方差矩阵，置信度低
dt=t(2)-t(1);
F=[1,dt,0.5*dt^2;0,1,dt;0,0,1];
H=[1,0,0;1,0,0];
Q=[1,0,0;0,0.01,0;0,0,0.0001];%导数阶数越高，置信度越高，算是一个在不清楚信号规律的情况下较为精细的模型了
R=[20,0;0,20];
%%%设置初值%%%
Xplus=zeros(3,L);%Xplus即为更新步之后KF最终得到的结果，因此写成数组存储
Xplus(1,1)=0.1^2;
Xplus(2,1)=0;%初值不重要，随便赋为0
Xplus(3,1)=0;
Pplus=[0.01,0,0;0,0.01,0;0,0,0.0001];%初始协方差，之后会不断的更新，没必要设为数组徒增烦恼
for i=2:L
    %%%预测步%%%
    Xminus=F*Xplus(:,i-1); %取出i-1列所有元素
    Pminus=F*Pplus*F'+Q;
    %%%更新步%%%
    K=(Pminus*H')*inv(H*Pminus*H'+R);
    Xplus(:,i)=Xminus+K*(y(:,i)-H*Xminus);
    Pplus=(eye(3)-K*H)*Pminus;
end
plot(t,x,'r',t,y(1,:),'g',t,y(2,:),'b',t,Xplus(1,:),'y','LineWidth',2);
%黄色：滤波后



