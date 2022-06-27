function f=appr_abs4(x,mu)
% lower bouned
% a smooth approx to absolute function on R.
% parameter mu>0

%% if x is a vector or matrix, it applies elementwise.
f=x.*tanh(x/mu);
end