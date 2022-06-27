function g=grad_appr_abs3(x,mu)
% Euclidean gradient of appr_abs3

%% only for x is real.

if x >=0
    g= 2 / (1+exp(-x/mu)) - 1;
else
    g= 1 - 2 / (1+exp(x/mu));
end

end