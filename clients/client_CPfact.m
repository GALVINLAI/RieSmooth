function [X,Xcost,all_info,options] =client_CPfact(r,B,subalgorithm,X0)

% f= min(BX) = max(-BX)
% M=stiefelfactory(r,r)
% smoothing fuction: lse
% B constain negative element, find X such that C=BX nonnegative.
% moreover, C*C'=B*B' since X is orthogonal.

%% If no input is provided, we generate a quick demo.
if nargin == 0
    n=10;
    A=gen_specialCP(n);% generate a CP matrix
    r=1.5*n;
    B=get_init_fact(A,r);% get (n x r) initial factorization B such that A=B*B';
    M= stiefelfactory(r, r);
    X0=M.rand();
    subalgorithm=@conjugategradient;
    options.plotresult=true;
end

%% main

problem.M = stiefelfactory(r, r);
problem.actualcost = @(X)  max(-B*X,[],'all');% actual cost function
problem.smoothcost  = @(X,mu) lse(-B*X,mu);% smoothed cost function
problem.egradsmoothcost  = @(X,mu) -B'*grad_lse(-B*X,mu);% Euclidean gradient of smoothed cost function

problem.tolerance = -1e-15;
options.stopfun = @myinnerstopfun;
options.outerstopfun = @myouterstopfun;

%% options

%Numerically check whether smoothcost is a smoothing function (optional).
% RieSmooth_checksmoothingfuns(problem);
% pause;
 
% Numerically check gradient consistency (optional).
% RieSmooth_checkgradient(problem);
% pause;

% (optional)
% options.subalgorithm=@conjugategradient;
% options.subalgorithm=@trustregions;
% options.subalgorithm=@steepestdescent;

% (optional)
options.subalgorithm=subalgorithm;
options.all_maxiter = 5000;
options.verbosity=0;

options.mu=100;
options.gamma=0.5;
options.rate_mu=0.8;
options.GradNormThresholdCriteria=1;

options.maxiter=Inf; % Remove the default single maximum iteration limit

%% solve and plot result

 [X,Xcost,all_info,options]=RieSmooth(problem,X0,options);

% Plot the details of each iteration.
if isfield(options,'plotresult') && options.plotresult
    subplot(2,2,1)
    semilogy([all_info.gradnorm], '.-');
    xlabel('Iteration number');
    ylabel('Norm of gradient of smoothed cost');

    subplot(2,2,2)
    plot([all_info.cost], '.-');
    xlabel('Iteration number');
    ylabel('Cost of smoothed cost');

    subplot(2,2,3)
    semilogy([all_info.mu], '.-');
    xlabel('Iteration number');
    ylabel('mu');

    subplot(2,2,4)
    plot([all_info.actual_cost], '.-');
    xlabel('Iteration number');
    ylabel('actual cost');
end


end

function stopnow = myinnerstopfun(problem, ~, info, last)
    stopnow = -info(last).actual_cost > problem.tolerance;
end

function stopnow = myouterstopfun(problem, ~, info,~)
    stopnow = -info(end).actual_cost > problem.tolerance;
end


