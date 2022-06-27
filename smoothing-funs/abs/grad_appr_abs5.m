function g=grad_appr_abs5(x,mu)
% Euclidean gradient of appr_abs5

%% only for x is real.

t=x./mu;
g=erf(t)+t.*(2/sqrt(pi))*exp(-t.^2);
end