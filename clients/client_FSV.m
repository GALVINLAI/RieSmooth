function [x,xcost,all_info,options]=client_FSV(n,m,tao,Q,x0,appr_abs,subalgorithm)

% f = L1 norm of Q*x
% M = sphere(n)
% smoothing fuction: appr_abs(1~6)

%% If no input is provided, we generate a quick demo.
if nargin == 0
    n=5;
    m=10*n;
    tao=1e-8;
    e=[ones(n,1);zeros(m-n,1)];
    [Q, ~] = mgson([rand(m,n-1),e]);
    M=spherefactory(n);
    x0=abs(M.rand());
    subalgorithm=@barzilaiborwein;
    options.plotresult=true;
    appr_abs=@appr_abs1;
end

%% main

grad_appr_abs=str2func(append('grad_',func2str(appr_abs)));

problem.M = spherefactory(n);

problem.actualcost = @tao_l0norm;
    function count = tao_l0norm(x)
        y = abs(Q*x);
        count=0;
        for i=1:m
            if y(i) >= tao
                count = count +1;
            end
        end
    end

% problem.actualcost = @(x) norm(Q*x,1);

problem.smoothcost = @fsv_cost;
    function f=fsv_cost(x,mu)
        f= sum(appr_abs(Q*x,mu));
    end

problem.egradsmoothcost = @fsv_gradient;
    function G = fsv_gradient(x,mu)
        y = arrayfun(@(t) grad_appr_abs(t,mu),Q*x);
        G= Q'*y;
    end

problem.n=n;
options.stopfun = @myinnerstopfun;
options.outerstopfun = @myouterstopfun;

%% options

% Numerically check whether smoothcost is a smoothing function (optional).
% RieSmooth_checksmoothingfuns(problem);
% pause;
% 
% Numerically check gradient consistency (optional).
% RieSmooth_checkgradient(problem);
% pause;

options.adjustmueachtime=true;

% (optional)
options.subalgorithm=subalgorithm;

%(optional)
options.mu=1;
options.rate_mu=0.5;

options.GradNormThresholdCriteria=2;
options.delta=0.1; 
options.rate_delta=0.5;

%(display optional)
options.verbosity = 0;

options.all_maxiter = 1000;

%% solve and plot result

[x,xcost,all_info,options]=RieSmooth(problem,x0,options);

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
    stopnow = (info(last).actual_cost <= problem.n);
end

function stopnow = myouterstopfun(problem, ~, info,~)
    stopnow = (info(end).actual_cost <= problem.n);
end


