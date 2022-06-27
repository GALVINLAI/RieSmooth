function g=grad_appr_abs4(x,mu)
% Euclidean gradient of appr_abs4

%% only for x is real.

t=x/mu;
g=(t).*(sech(t)).^2+tanh(t);

end