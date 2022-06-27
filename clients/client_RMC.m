function [X,Xcost,all_info,options]=client_RMC(m,n,r,A,lambda,observed_indices,X0,A0, ...
    appr_abs,subalgorithm,upper_iter,upper_time,RMSEtolerance)

% f(X) = || Pomega.*(X-A) ||_{1} + lambda*|| Pc_omega.*(X) ||_{2}^2
% M = fixedrankembeddedfactory(m,n,r)
% upper_iter is upper limit of total iterations;
% upper_time is upper limit of total time [s];
% lambda=0 as usual

%% main

observed_num= length(observed_indices);
[observed_row, observed_col] =  ind2sub([m,n],observed_indices);
Aobserved = A(observed_indices);

grad_appr_abs=str2func(append('grad_',func2str(appr_abs)));

problem.M = fixedrankembeddedfactory(m,n,r);

problem.actualcost = @erorr_RMSE;
    function f = erorr_RMSE(X)
        Xmat = X.U*X.S*X.V';
        f=RMSE(Xmat,A0);
    end

problem.smoothcost = @smoothRMC;
    function f=smoothRMC(X,mu)
        Xmat = X.U*X.S*X.V';
        Xobserved=Xmat(observed_indices);
        % appr_abs is applied poointwise for vector input.
        f1 = sum(appr_abs(Xobserved-Aobserved,mu)-lambda*Xobserved.^2); 
        f2=lambda*norm(diag(X.S))^2;
        f=f1+f2;
    end

problem.gradsmoothcost = @grad_smoothRMC;
    function G = grad_smoothRMC(X,mu)
        Xmat = X.U*X.S*X.V';
        Xobserved=Xmat(observed_indices);
        vec_s=zeros(observed_num,1);
        for i = 1:observed_num
            % grad_appr_abs only for the real input.
            vec_s(i) = grad_appr_abs(Xobserved(i)-Aobserved(i),mu) - 2*lambda*Xobserved(i); 
        end
        Mid_S = sparse(observed_row, observed_col,vec_s,m,n);
        G.M  = X.U'*Mid_S*X.V + 2*lambda*X.S;
        G.Up = Mid_S*X.V -  X.U*X.U'* Mid_S*X.V;
        G.Vp = Mid_S'*X.U -  X.V*X.V'* Mid_S'*X.U;
    end

problem.tolerance=RMSEtolerance;
problem.my_allmaxtime=upper_time;
problem.my_allmaxiter=upper_iter;
options.stopfun = @myinnerstopfun;
options.outerstopfun = @myouterstopfun;

%% options

options.subalgorithm=subalgorithm; 

options.GradNormThresholdCriteria=1;

% (display)
options.verbosity = 0;

options.mu=100;
options.rate_mu=0.05;

options.maxiter=40;

% Disable RieSmooth's built-in maximum number of iterations
options.all_maxiter=Inf; 

%% solve

[X,Xcost,all_info,options]=RieSmooth(problem,X0,options);

end


function stopnow = myinnerstopfun(problem, ~, info, last)
    stopnow = (info(last).actual_cost <= problem.tolerance);
end

function stopnow = myouterstopfun(problem, ~, info, totoal_iter)
    stopnow = (info(end).actual_cost <= problem.tolerance) || ...
        (info(end).time >= problem.my_allmaxtime && ...
          totoal_iter >=problem.my_allmaxiter );
end


