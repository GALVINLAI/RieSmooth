function f=appr_abs2(x,mu)
% upper bouned
% a smooth approx to absolute function on R.
% parameter mu>0

%% if x is a vector or matrix, it applies elementwise.

f=sqrt(x.^2+mu^2);
end
