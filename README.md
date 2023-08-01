# General-Riemannian-Smoothing-Method
General smoothing method on Riemannian manifold, for solving the general nonsmooth Riemannian optimization problem:
$$\min _{x \in \mathcal{M}} f(x),$$
where $\mathcal{M}$ is any available manifold in Manopt and $f:\mathcal{M} \to \mathbb{R}$ is nonsmooth. 


Reference: Lai, Z., Yoshise, A. Completely positive factorization by a Riemannian smoothing method. Comput Optim Appl 83, 933–966 (2022). https://doi.org/10.1007/s10589-022-00417-4


The code is based on matalb solver 'Manopt'.\
Before running the codes, you must install the solver ['Manopt'](https://www.manopt.org/tutorial.html)!\
Notice that we do not modify any of the functions given by the solver Manopt.

# Introduction to solver RieSmooth.m

sovler of general Riemannian smoothing algorithm

* function [x,cost,all_info,options]=RieSmooth(problem,x0,options)
* function [x,cost,all_info,options]=RieSmooth(problem,[],options)

----------- Request for input structure variable 

**problem** structure:

- problem.M % manifold
- problem.actualcost = @(x) % actual cost function, or other functions used to evaluate the goodness of the solution.
- problem.smoothcost  = @(x,mu) % smoothed cost function
- problem.egradsmoothcost = @(x,mu) % Euclidean gradient of smoothed cost function
- or, problem.gradsmoothcost = @(x,mu) % Riemannian gradient of smoothed cost function

**options** structure:

- options.outerstopfun(problem, x, info, totoal_iter) % A required user-specified method of exiting the RieSmooth

----------- Brief description of Riemannian smoothing algorithm

We use a smoothed cost function to replace the actual (but not smoothed) cost function. \
Parameter mu (positive) controls the degree of approximation.\
With fixed initial mu, we frist minimize smoothcost(x,mu) on M as usual.\
This is called inner itertaions under the fixed mu.\
When inner itertaions meet some condition, e.g., tolgradnorm <=0.5*mu, we start outer iterations, i.e., shrinking mu. \
Theorem 3.6 in paper above show convergence to a stationary point of the original problem.\

# Introduction to smoothing funs

(1) one smoothing function of maximum function

result = lse(X,mu)	

    lse, a smooth approximation to the max-function that obtains the largest element of matrix or vector X.
    Parameter mu must be positive, cannot be zero. The littler mu is, the better approximation is.

result = grad_lse(X,mu) 

    Euclidean gradient of lse function.

(2) five smoothing functions of absolute value function and their Euclidean gradients.

    appr_abs1.m
    appr_abs2.m       
    appr_abs3.m  
    appr_abs4.m       
    appr_abs5.m       
    grad_appr_abs1.m
    grad_appr_abs2.m  
    grad_appr_abs3.m
    grad_appr_abs4.m
    grad_appr_abs5.m  
      
# Introduction to problems, clients and bosses

List of problem:
1. Completely positive matrix factorization problem (CPfact)
2. Finding the sparsest vector in a subspace (FSV)
3. Robust low-rank matrix completion (RMC) 

All the clients are base on the solver RieSmooth.m.

## (1) client_CPfact.m 
If no input is provided, we generate a quick demo.\
This function is called by:

    Boss_CPfact_random.m --- Numerical experiments of section 4.1 
    
    Boss_CPfact_special.m --- Numerical experiments of section 4.2 
    
    Boss_CPfact_hard.m.m --- Numerical experiments of section 4.4 
    
    cmd_CPfact.m --- Command to execute all experiments above

## (2) client_CPfact_easyCP.m
This function is called by:

    Boss_CPfact_easy.m  --- Numerical experiments of section 4.3 
    
## (3) client_FSV.m 
If no input is provided, we generate a quick demo.\
This function is called by:

    Boss_FSV.m  --- Numerical experiments of section 5.1
    
    cmd_FSV.m --- Command to execute all experiments above

## (4) client_RMC.m

This function is called by:

    Boss_RMC_perfect.m  --- Numerical experiments of section 5.2.1
    
    Boss_RMC_outliers.m  --- Numerical experiments of section 5.2.1
    
    cmd_RMC --- Command to execute all experiments above

# Introduction to tools

## (1) Used for CP factorization problem

A = gen_specialCP(n) 

    Generate a specifically structured n x n completely positive (CP) matrix.

B = get_init_fact(A,r)

    Get an n x r initial factorization B of given n x n CP matrix A such that A= BB^T.
    Please ensure that matrix A is square, symmetric, entry-wise nonnegative, and positive semidefinite.

M = RandOrthMat(n, tol)

    Generate a random n x n orthogonal real matrix. This open-source is provided by Ofek Shilon (2022). 
    https://www.mathworks.com/matlabcentral/fileexchange/11783-randorthmat 
    MATLAB Central File Exchange. Retrieved April 20, 2022.

## (2) Used for FSV problem

mgson.m 

    Modified Gram-Schmidt orthonormalization (numerical stable version of Gram-Schmidt algorithm) 
    This open-source is provided by Mo Chen (2022).
    (https://www.mathworks.com/matlabcentral/fileexchange/55881-gram-schmidt-orthogonalization),
    MATLAB Central File Exchange. Retrieved June 11, 2022.

## (3) Used for RMC problem

erorr=RMSE(X,M0)

    Root mean square error (RMSE) with respect to the original matrix M0.
    For evaluating the distance to the real solution in Robust low-rank matrix completion.

RMC_get_timeplot.m

    plot in terms of number of iterations

RMC_get_iterplot.m 

    plot in terms of time

RMC_mergefigs.m 

    plot six results in one figure

## (4) Used for general problem

RieSmooth_checksmoothingfuns.m 

    Check if problem.smoothcost is an smoothing function of problem.actualcost.
    Invalid if problem.actualcost is other functions used to evaluate the goodness of the solution.

demo_checksmoothingfuns.m 

    demo of above.

RieSmooth_checkgradient.m 

    Check if problem.egradsmoothcost (or, problem.gradsmoothcost) is the correct gradient
    of problem.smoothcost.

----------------------
June. 25, 2022.
----------------------
Contact:
Zhijian Lai, University of Tsukuba, 2022

2130117@s.tsukuba.ac.jp 
or laizhijian100@outlook.com


