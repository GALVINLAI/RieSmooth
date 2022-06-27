function G = grad_lse(x,mu)
% (Euclidean) gradient of LogSumExp function
% we have to avoid numerical underflow and overflow
G = exp((x- lse(x,mu))/mu);
end


