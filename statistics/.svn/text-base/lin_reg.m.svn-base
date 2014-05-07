%***********************************************************
% To determine the slope of a function whose
% values are the input.
%
% T. Stiefmeier
% ETH Zurich
% 18-Oct-2004
%***********************************************************

function [slope,offset] = lin_reg(x_in,y_in);

n = length(x_in);
sum_x = 0;
sum_y = 0;
sum_xy = 0;
sum_x2 = 0;
for i=1:n
    sum_x = sum_x + x_in(i);
    sum_y = sum_y + y_in(i);
    sum_xy = sum_xy + x_in(i)*y_in(i);
    sum_x2 = sum_x2 + (x_in(i))^2;
end

slope = (n*sum_xy - sum_x*sum_y) / (n*sum_x2 - (sum_x)^2);
offset = (sum_y - slope*sum_x) / n;