function [X,...
    Success,time,no_itrs]=CC_SpFeasDC_ls(A,B,r,X0)

    % A difference-of-convex functions approach 
    % for solving the split feasibility problem, it can be applied to (FeasCP).
    % All the implementation details regarding the parameters we used 
    % are the same as in the numerical experiments reported in [18, Section 6.1].
    
    % Let D = R^{n x r}_{+}, C = the set of (r x r) orthogonal matrices.

    %n=size(A,1);
    %O=zeros(n,r);
    
    % parameters
    Lmax=1e8;
    Lmin=1e-8;
    tau=2;
    c=1e-4;
    M=4;
    tolerance=-1e-13;
    
    k=0;
    X_k=X0;
    L_k0=1;
    val =[dis_D2(B*X_k)];
    
    %MAX=max( ceil( ( log(norm(B,'fro')+c) - log(Lmin) )/log(tau) ) ,1);
    
    tic
    % main route
    while 1
        eta_k=proj_D(B*X_k);
        W_k=B'*(B*X_k-eta_k);

        % generate L_k0 (see [18, Section 6.1])
        if k>0
            Y_k=W_k-W_1k;
            l=trace(Y_k'*S_k);
            if l >1e-16
                L_k0=min( max( l/norm(S_k,'fro')^2 , Lmin) , Lmax);
            else
                L_k0=min( max( Lbar_k/1.1 , Lmin) , Lmax);
            end
        end
        L_k=L_k0;
        
        % subroute
        while 1             
            u=proj_C( X_k - W_k/ L_k ); % main computation --> svd
            disD2=dis_D2(B*u);
                if disD2 > max( val( max(k-M,0)+1 : k+1) ) - c*norm(u-X_k,'fro')^2
                    L_k=tau*L_k;
                    continue
                end
            break
        end
        
        X_k1=u;
        Lbar_k=L_k;
        minBX=min(B*X_k1,[],'all');
         
        % stopping check 
        if minBX >= tolerance
            sprintf('Success!!')
            Success=1;
            break
        elseif k== 5000 || Lbar_k > 1e10
            sprintf('Failed!!')
            Success=0;
            break
        end
        
        val =[val; disD2];
        S_k=X_k1-X_k;
    
        k=k+1;
        X_k=X_k1;
        W_1k=W_k;
    end

    % record results
    time = toc;
    no_itrs=k;
    X=X_k1;
end


function Z=proj_C(X)
    % projection onto Orthogonal gruop
    [U,~,V]=svd(X); %A = U*S*V' 
    Z=U*V';
end

function Z=proj_D(X)
    % projection onto D
    % Note the D is closed convex, so Z is unique.
    Z=max(X,zeros(size(X)));
end

function d=dis_D2(X)
    % squared distance from point X to set D
    d=norm(X-proj_D(X),'fro')^2;
end



