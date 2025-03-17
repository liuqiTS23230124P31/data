%得到多目标问题的解

function [y,c] = p(x)  %c=1则x为非可行解

[c,y(1),L] = fitness(x);  %得出粒子的适应度  %%运行成本赋值给y（1）

y(2)=L;

end