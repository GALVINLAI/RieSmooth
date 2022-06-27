function f=appr_abs5(x,mu)
% lower bouned
% a smooth approx to absolute function on R.
% parameter mu>0

%% if x is a vector or matrix, it applies elementwise.
f=x.*erf(x./mu);
end