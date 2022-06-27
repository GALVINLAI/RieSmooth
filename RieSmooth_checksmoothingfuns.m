function RieSmooth_checksmoothingfuns(problem)
% input
% problem.M
% problem.actualcost=@(x) % f
% problem.smoothcost=@(x,mu) % tilde f

maxtol=1e-10;

fprintf('It must hold lim_{mu approches 0} [ smoothcost(x,mu) - actualcost(x) ] = 0 for any point x.\n');

checktimes=10;
errs=zeros(1,checktimes);

for i=1:checktimes
    x=problem.M.rand();
    fx_mu=@(mu) problem.smoothcost(x,mu);
    small_mu_set=1e-12; %
    for smallmu=small_mu_set
        err=abs(fx_mu(smallmu)-problem.actualcost(x));
        errs(i)=err;
        if err >maxtol
            warning('checksmoothingfuns: problem.smoothcost may not be a smoothing function.');
            return
        end
    end
end
maxerr=max(errs);

% if correct
fprintf('We checked above euqality for %g randon points x on M with sufficient samll mu = %g. \n', checktimes,small_mu_set);
fprintf('We find that maximun error of ''abs(smoothcost(small mu)-actualcost(x))'' is %g.\n', maxerr);

end