function [X,Xcost,all_info,options] =client_CPfact_easyCP(r,B,subalgorithm,X0,all_maxiter)
% f= min(BX) = max(-BX)
% M=stiefelfactory(r,r)
% smoothing fuction: lse
% B constain negative element, find X such that C=BX nonnegative.
% moreover, C*C'=B*B' since X is orthogonal.
%% main
problem.M = stiefelfactory(r, r);
problem.actualcost = @(X)  max(-B*X,[],'all');
problem.smoothcost  = @(X,mu) lse(-B*X,mu);
problem.egradsmoothcost  = @(X,mu) -B'*grad_lse(-B*X,mu);
problem.tolerance = -1e-15;
options.stopfun = @myinnerstopfun;
options.outerstopfun = @myouterstopfun;
%% options
options.subalgorithm=subalgorithm;
options.all_maxiter = all_maxiter;
options.verbosity=1;
options.mu=100;
%options.maxiter=Inf; % Remove the default single maximum iteration limit

%% solve
[X,Xcost,all_info,options]=RieSmooth(problem,X0,options);
end

function stopnow = myinnerstopfun(problem, options, info, last)
stopnow = 0;
end

function stopnow = myouterstopfun(problem, options, info,all_iter)
stopnow = 0;
end



