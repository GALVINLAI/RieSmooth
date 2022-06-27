function B=get_init_fact(A,r)
    %input: an (n x n) CP matrix A
    %output: an (n x r) initial factorization B such that A=B*B'
    
    Rank = rank(A);
    n=size(A,1);
    
    %check rank
    if r<Rank
        disp('Error!! : r < rank of given matrix !! Cannot have a decompositon.');
        return
    end
    
    if Rank == n %in this case, A must be positive definite (PD)
        B=(chol(A))';%Note that Cholesk decmoposition only for PD matrix
        B=expand(B,r);%expand to r columns
    else
        text=['Caution!!: Rank is ',num2str(Rank),' Not full rank.'];
        disp(text);
    
        %use the spectral decomposition
        [V,U]=eig(A);
        U(U<1e-15)=0;
        B = V*realsqrt(U);
        if r >= n
            B=expand(B,r);
        else
            disp('Caution!! : r < n.');
            B(:,1:n-r)=[];
        end
    end

end


function X = expand(B,r)
    %expand columns of matrix B by 'column replication'
    %Output: an n x r matrix X such that B*B'=X*X'
    [row,cloumn]=size(B);
    if r>cloumn
        s=r-cloumn+1;
        Z=zeros(row,s);
        for i= 1:s
            Z(:,i)=B(:,cloumn)/realsqrt(s);
        end
        B=[B(:,1:cloumn-1), Z];
    end
    X=B;
end

