function  [x,cost,all_info,options]=RieSmooth(problem,x,options)
% Riemannian smoothing algorithm
% The code is based on matalb solver 'Manopt', see https://www.manopt.org/tutorial.html

% These codes are supplementary materials for the paper below.
% title={Completely Positive Factorization by a Riemannian Smoothing Method},
% author={LAI, ZHIJIAN and YOSHISE, AKIKO},
% year={2021}

% function [x,cost,all_info,options]=RieSmooth(problem,x0,options)
% function [x,cost,all_info,options]=RieSmooth(problem,[],options)

%%%%%%%%%%%%%%%% Request for input structure variable
% problem.M % manifold
% problem.actualcost = @(x) % actual cost function
% problem.smoothcost  = @(x,mu) % smoothed cost function
% problem.egradsmoothcost = @(x,mu) % Euclidean gradient of smoothed cost function
% or problem.gradsmoothcost = @(x,mu) % Riemannian gradient of smoothed cost function
% options.outerstopfun(problem, x, info, totoal_iter)


% Apply the Riemannian smoothing algorithm to the problem defined in the
% problem structure, starting at x0 if it is provided (otherwise, at a
% random point on the manifold). To specify options whilst not specifying
% an initial guess, give x0 as [] (the empty matrix).

%%%%%%%%%%%%%%%%

% Brief description of the Riemannian smoothing algorithm:
% We use a smoothed cost function to replace the actual (but not smoothed)
% cost function. Parameter mu (positive) controls the degree of approximation.
% We must ensure that
% lim_{mu \to 0} smoothcost(x,mu) = cost(x) for any point x.
% see RieSmooth_checksmoothingfuns.m

% With fixed initial mu, we frist minimize smoothcost(x,mu) on M as usual.
% This is called inner itertaions under the fixed mu.
% When inner itertaions meet some condition, e.g., tolgradnorm <=
% 0.5*mu, we start outer iterations, i.e., shrinking mu. Theorem 3.6 in
% paper above show convergence to a stationary point of the original problem.

%%%%%%%%%%%%%%%%

% The options structure is used to overwrite the default values. All
% options have a default value and are hence optional. To force an option
% value, pass an options structure with a field options.optionname, where
% optionname is one of the following and the default value is indicated
% between parentheses:
%
% all_maxiter (1000)
%     The algorithm terminates if maxiter iterations have been executed.
% maxiter (50)
%     The inner iteration terminates if maxiter iterations have been executed.
% maxtime (Inf)
%     The inner iteration terminates if maxtime seconds elapsed.
% mu (1)
%     Parameter mu (usual positive) controls the degree of approximation.
% rate_mu (0.5)
%     Parameters controlling the reduction of mu in outer iteration.
% GradNormThresholdCriteria(1)
%     our method 1; chen method 2
% gamma (0.5)
%     Parameters  controlling the inner iteration stop; used if
%     GradNormThresholdCriteria = 1
% delta (0.1)
%     Parameter mu (usual positive) controls the degree of approximation;
%     used if GradNormThresholdCriteria = 2
% rate_delta (0.5)
%     Parameters controlling the reduction of delta in outer iteration;
%     used if GradNormThresholdCriteria = 2
% adjustmueachtime (true)
%     Ajust value of mu before inner iterations every time, if true. If the
%     value of mu is too large relative to the corrent x, it will lead to
%     successive [outer iterations + 0 times inner iterations]. We directly
%     adjust mu so that this problem is avoided. This is very much needed
%     before the first outer iteration (otherwise, with a smaller initial
%     mu), but afterwards it can be eliminated.
% subalgorithm (@trustregions)
%     Chose a Riemmanin subalgorithm (Any available solvers in Maniopt, see
%     https://www.manopt.org/tutorial.html#solvers)
% statsfun (@val_mu and @actual_cost)
%     For Riemannian smoothing algorithm, It is necessary to record the
%     values of mu and cost. It is not recommended to remove the default
%     option. Additional functions can be added to the metric.
% stopfun (@val_mu_stopfun)
%     The default is to stop when mu is less than 1e-4.
% verbosity (2)
%     Integer number used to tune the amount of output the algorithm
%     generates during execution (mostly as text in the command window).
%     The higher, the more output. 0 means silent.




%%


%__________ Rename __________

M=problem.M;
smoothcost=@problem.smoothcost;

if isfield(problem,'gradsmoothcost')
    gradsmoothcost=@problem.gradsmoothcost;
elseif isfield(problem,'egradsmoothcost')
    egradsmoothcost=@problem.egradsmoothcost;
    gradsmoothcost=@(x,mu) M.egrad2rgrad(x, egradsmoothcost(x,mu));
end
gradsmoothcostnorm=@(x,mu) M.norm(x, gradsmoothcost(x,mu));

%__________ Merge options __________

% Set defaults for inner iteration.
innerdefaults.verbosity=2; % dispaly
innerdefaults.maxiter = 50; % max iters num in each inner iteration
innerdefaults.maxtime = Inf; % max time in each inner iteration

% Set defaults for outer iteration.
outerdefaults.mu=1;
outerdefaults.rate_mu=0.5; % reduction rate of mu

% GradNormThresholdCriteria
outerdefaults.GradNormThresholdCriteria = 1; % our method if 1, chen's method if 2
outerdefaults.gamma=0.8; % used if GradNormThresholdCriteria = 1

outerdefaults.delta=0.1; % used if GradNormThresholdCriteria = 2
outerdefaults.rate_delta=0.5; % reduction rate of delta; used if GradNormThresholdCriteria = 2

% others
outerdefaults.all_maxiter = 1000; % max total iters num
outerdefaults.adjustmueachtime=true; % ajust value of mu before inner iterations if true

% Merge inner and outer defaults, then merge with user options, if any.
% mergeOptions is a Manopt tool.
defaults = mergeOptions(outerdefaults, innerdefaults);
if ~exist('options', 'var') || isempty(options)
    options = struct();
end
options = mergeOptions(defaults, options);

%__________ initialization __________

% initial x
if ~exist('x', 'var') || isempty(x)
    x = M.rand();
end

delta=options.delta;

mu=options.mu;

% choose trust regions solver if uers don't offer
if ~isfield(options, 'subalgorithm')
    options.subalgorithm= @trustregions;
end

warning('off', 'manopt:getHessian:approx');

% record value of mu and actual cost at each iter. metrics=options.metrics;
metrics.mu = @val_mu;
    function r=val_mu(~, ~)
        r=mu;
    end
metrics.actual_cost = @(problem, x) problem.actualcost(x);
options.statsfun = statsfunhelper(metrics);

% The default is to stop when mu is less than 1e-2.
if ~isfield(options, 'stopfun')
    options.stopfun = @val_mu_stopfun;
end

% outer iteration counter
out_iter=0;

timestart=tic;

% Execute the main algorithm.
while true
    % If the value of mu is too large relative to the corrent x, it will
    % lead to successive [outer iterations + 0 times inner iterations]. We
    % directly adjust mu so that this problem is avoided. This is very much
    % needed before the first outer iteration (otherwise, with a smaller
    % initial mu), but afterwards it can be eliminated.
    if out_iter == 0 || options.adjustmueachtime
        while  gradsmoothcostnorm(x,mu) <= getTolGradNorm(options)
            mu=options.rate_mu*mu;
        end
    end

    % update cost function and gradient
    problem.cost  = @(x) smoothcost(x,mu);
    if isfield(problem,'gradsmoothcost')
        problem.grad = @(x) gradsmoothcost(x,mu);
    elseif isfield(problem,'egradsmoothcost')
        problem.egrad = @(x) egradsmoothcost(x,mu);
    end

    % Stopping criteria in each inner iteration
    options.tolgradnorm = getTolGradNorm(options);

    % Solve by sub-algorithm
    [x, cost, info, ~] = options.subalgorithm(problem,x,options);

    % stack all infos and adjust info.time
    if out_iter == 0
        all_info=info;
        totoal_iter=length(info);
        all_info(min(10000, options.all_maxiter+1)).iter = [];
        accum_time=info(end).time;
    else % out_iter >= 1
        % single_iter = once outer iteration + inner iterations
        single_iter=length(info); 
        % adjust info.time, let them add the time accumulated before
        newtime= num2cell([info.time]+accum_time);
        [info.time]=newtime{:};
        %alternatively
        %         for j=1:single_iter 
        %             info(j).time=info(j).time+accum_time;
        %         end

        % update accumulated time
        accum_time=info(end).time;

        all_info(totoal_iter+1:totoal_iter+single_iter)=info;% stack info
        totoal_iter=totoal_iter+single_iter;
    end

    % exit loop of while if user defined outerstopfun criterion triggered
    % To avoid modifying manopt's documentation, we set our own criteria 
    % for exiting the entire loop.
    if options.outerstopfun(problem, x, info, totoal_iter)
        options.success=1;
        sprintf('Success!!')
        break
    end
    % all_infolength = all outer iter num + all inner iter num
    if totoal_iter >= options.all_maxiter
        options.success=0;
        sprintf(' Max total iterations have been executed.!')
        break
    end

    % update
    mu = options.rate_mu*mu;
    delta = options.rate_delta*delta; % if GradNormThresholdCriteria=1, it makes no sence.
    out_iter=out_iter+1;
end

%%%%%%%%%%%%%% loop over

if out_iter == 0 && isempty(all_info)
    sprintf('Initial point stasfies the uer''s stop function')
else
    all_info = all_info(1:totoal_iter);
    options.num_iter=totoal_iter;
    options.out_iter=out_iter;
    options.all_time=toc(timestart);
end

    function tol=getTolGradNorm(options)
        switch options.GradNormThresholdCriteria
            case 1 % our
                tol=options.gamma*mu;
            case 2 % chen
                tol=delta;
        end
    end

end

%% sub function
function stopnow = val_mu_stopfun(~, ~, info, last)
stopnow = info(last).mu < 1e-4;
end





