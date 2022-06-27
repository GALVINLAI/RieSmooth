function [X,...
    Success,time,no_itrs]=Bot_RIPG_mod(A,r)

    % This is a projected gradient method with relaxation and inertia parameters for solving (2). 
    % As shown in [12, Section 4.2], RIPG_mod is the best among many strategies of choosing parameters.
    % (the relaxed versions of IPG-sFISTA)
    % We do not need X0, B.
    
    % Let D = R^{n x r}_{+} \cap B_{F}(0,\sqrt{trace(A)})
    % D is determined by trace of A.

    n=size(A,1);
    traceA=trace(A);
    norm2A=norm(A,2); % spectral norm (l2 norm): the largest singular value
    f_normAsq=norm(A,'fro')^2;
    lamdaA=eigs(A,1,'smallestabs'); % returns the smallest magnitude eigenvalues.
    LF_aplus=@(a_plus) 2*( (3+8*a_plus+6*a_plus^2)* traceA-lamdaA);
    
    % letter a denotes alpha; a in [0,1].
    a=0.967; 
    % see #(73) in [12]
    while a < sqrt( LF_aplus(a) / (LF_aplus(a) + 2*norm2A) )  
        a=(3*a+1)/4;
    end
    a=(4*a-1)/3;% the last one satisfying (73) in his paper.
    
    a_plus=(a+3)/4; %the final a_plus a^3
    % a_plus=(a+1)/2; %the final a_plus a^2
  
    % a_plus=1;
    kappa=a_plus;
    
    % Starting point in D
    X0=proj_D(rand(n,r),traceA);
    X_k=X0;
    
    % choose the relaxation parameter rho in (0,1] such that rho_l<rho<rho_u
    LF=LF_aplus(a_plus);
    rho_l= sqrt(LF+2*norm2A) / ( sqrt(LF+2*norm2A) + sqrt(LF)   );
    rho_u=sqrt(LF+2*norm2A) / ( (1+a_plus)*sqrt(LF+2*norm2A) - sqrt(LF)  );
    w=0.999999;
    rho=(1-w)*rho_l+w*rho_u;
    %rho=1
    %rho=0.9661;
    
    Nabla_E =@(X) -2*(A-X*X')*X;
    k=1;
    
    tic
    % main route
    while 1
        a_k=kappa*k/(k+3); % sequence of inertial parameters
        
        if k==1
            Y_k=X_k+a_k*(X_k-X0);
        else
            Y_k=X_k+a_k*(X_k-X_1k);
        end
        
        Z_k1=proj_D(Y_k-Nabla_E(Y_k)/LF,traceA);
        
        X_k1= (1-rho)*X_k +  rho*Z_k1 ;
        
        sc= norm(A- X_k1*X_k1','fro')^2 / f_normAsq;      
        
         if sc < 1e-15
            sprintf('Success!!')
            Success=1;
            break
        elseif k==10000
            % set 10,000 iterations for n < 100, and
            % set 50,000 iterations in all other cases.
            sprintf('Failed!!')
            Success=0;
            break
         end
         
        k=k+1;
        X_1k=X_k;
        X_k=X_k1;
    end

    %record results
    time=toc;
    no_itrs=k;
    X=X_k1;
end


function Z=proj_D(X,trace_A)
    % D = R^{n x r}_{+} \cap B_{F}(0,\sqrt{trace(A)})
    % note that D is closed convex set.
    X1=max(X,zeros(size(X)));
    c=sqrt(trace_A)/(max( norm(X1,'fro'), sqrt(trace_A) ));
    Z=c*X1;
end






