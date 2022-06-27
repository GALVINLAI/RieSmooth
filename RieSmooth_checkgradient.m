function RieSmooth_checkgradient(problem)
% INPUT
% problem.M
% problem.smoothcost  = @(x,mu) % smoothed cost function
% problem.egradsmoothcost  = @(x,mu) % Euclidean gradient of smoothed cost function or,
% problem.gradsmoothcost  = @(x,mu) % Riemannian gradient of smoothed cost function

mu=rand();
problem.cost  = @(x) problem.smoothcost(x,mu);

if isfield(problem,'gradsmoothcost')
    problem.grad = @(x) problem.gradsmoothcost(x,mu);
elseif isfield(problem,'egradsmoothcost')
    problem.egrad = @(x) problem.egradsmoothcost(x,mu);
end

checkgradient(problem);
end