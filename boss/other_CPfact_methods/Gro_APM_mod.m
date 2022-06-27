function [X,...
    Success,time,no_itrs]=Gro_APM_mod(B,r,X0)

    % A modified alternating projection method for CP factorization
    % it is mentioned in Section 2.3.
    
    k = 0;
    O=zeros(size(B));
    E=eye(r);
    tolerance=-1e-15;
    X=X0;
    
    tic
    while 1
        W_k=max(B*X,O);
        B_plus=pinv(B);% main computation --> svd
        P_k=B_plus*W_k+(E-B_plus*B)*X;
        X=proj_C(P_k);% main computation --> svd
        
        minBX=min(B*X,[],'all');

        % stopping check 
        if minBX >= tolerance
            sprintf('Success!!')
            Success=1;
            break
        elseif k== 5000
            sprintf('Failed!!')
            Success=0;
            break
        end
        k = k + 1;
    end
    
    %record results
    time = toc;
    no_itrs=k;
end

function Z=proj_C(X)
    % projection onto Orthogonal gruop
    [U,~,V]=svd(X); %A = U*S*V' 
    Z=U*V';
end



