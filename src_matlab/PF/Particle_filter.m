%Particle filter
%粒子滤波演示代码
%x(i)=sin(x(i-1))+5*x(i-1)/(x(i-1)^2+1)+Q 状态方程
%y(i)=x(i)^2+R 观测方程
%滤波前一定要写成状态方程与观测方程的形式 x(k)=f(x(k-1))

%%%%%生成信号(100个)%%%%%
t = 0.01:0.01:1;
L = length(t);
%初始化 x预测值 y 观测值
x = zeros(1,L);
y = zeros(1,L);
%x y 初值给定
x(1) = 0.1;
y(1) = 0.1^2;
%生成预测数据与观测数据
for i=2:L
    x(i) = sin(x(i-1))+5*x(i-1)/(x(i-1)^2+1);
    y(i) = x(i)^2+normrnd(0,1);
end
%预测值与观测值图像 红：预测值 绿：观测值
%plot(t,x,'r',t,y,'g',LineWidth=2)

%%%%%PF start%%%%%
%初始化粒子集合 xold旧粒子位置 xnew新粒子位置 xplus滤波值 w权重
xold = zeros(1,L);
xnew = zeros(1,L);
xplus = zeros(1,L);
w = zeros(1,L);
%设置x0(i)如果对初值有自信可直接设置为期望
for i = 1:L
    xold(i) = 0.1;
    w(i) = 1/L;
end

%%%%%PF核心代码%%%%%
for i = 2:L
    %预测步 改变例子位置
    for j = 1:L
        xold(j) = sin(xold(j))+5*xold(j)/(xold(j)^2+1)+normrnd(0,0.1);
    end
    %更新步 改变例子权重
    for j = 1:L
        %w1(i) = fR(y1-h(x1(i)))w0(i)
        %此处fR假设为正态分布 R~(0,0.1)
        %fR = (2*pi*R)^(-0.5)*exp(-((y(i)-xold(j)^2)^2/(2*R)))
        w(j) = exp(-((y(i)-xold(j)^2)^2/(2*0.1)));
    end
    %归一化 此处我使用两种方法进行w的归一化，方法二得到的w最终整体的滤波效果更好，why?
    %%方法一
    % for j = 1:L
    %     w(j) = w(j)/sum(w);
    % end
    %%方法二
    w = w/sum(w);
    % plot(t,w,'y',LineWidth=2)
    %重采样
    c = zeros(1,L);%每个粒子权重区间
    c(1) = w(1);
    for j = 2:L
        c(j) = c(j-1)+w(j);
    end
    for j=1:L
        a = unifrnd(0,1);%随机生成
        for k = 1:L
            if a<c(k)
                xnew(j) = xold(k);
                break
            end
        end
    end
    xold = xnew;%新粒子赋值给旧粒子，为下一轮递推做准备
    for j = 1:L
        w(j) = 1/L;
    end
    %计算滤波后值
    xplus(i) = sum(xnew)/L;
end

%绘图 PF滤波后
plot(t,x,'r',t,y,'g',t,xplus,'b',LineWidth=2)

