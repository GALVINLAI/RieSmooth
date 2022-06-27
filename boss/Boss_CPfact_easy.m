% Codes for Section 4.3 An easy instance on the boundary of CP cone
clear;clc;close all;

A=[41	43	80	56	50
    43	62	89	78	51
    80	89	162	120	93
    56	78	120	104	62
    50	51	93	62	65];

%Note that cp(A)=rank(A)=3.

r=3;B=get_init_fact(A,r);

X0=RandOrthMat(r);

%%%%%%% Methods %%%%%%%
% Riemannian Smoothing Method
subalgorithm=@trustregions;
all_maxiter=1000;
[X,Xcost,all_info,options]=client_CPfact_easyCP(r,B,subalgorithm,X0,all_maxiter);


% CC_SpFeasDC_ls 
% [~,Success,time,no_itrs]=CC_SpFeasDC_ls(A,B,r,X0);

% Bot_RIPG_mod 
% [~,Success,time,no_itrs]=Bot_RIPG_mod(A,r);

% Gro_APM_mod 
% [~,Success,time,no_itrs]=Gro_APM_mod(B,r,X0);

%%%%%%%%%%%%%%%%%%%%%%

%check solution
fprintf('The smallest value of B*X is %g.\n', min(B*X,[], 'all'));