function g=grad_appr_abs1(x,mu)
% Euclidean gradient of appr_abs1

%% only for x is real.

if abs(x)<mu/2
    g= 2*x / mu; %for abs(x)<=mu
else
    g= sign(x); %for abs(x)>=mu
end

end




