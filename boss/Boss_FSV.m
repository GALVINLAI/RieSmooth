function Result= Boss_FSV(n,m_set,appr_abs)

% appr_abs=@appr_abs1;
% n=5 and m_set=[4*n 6*n 8*n 10*n];
% n=10 and m_set=[6*n 8*n 10*n 12*n];

%%
subalgorithm_set = {@steepestdescent, @barzilaiborwein, @conjugategradient, ...
    @trustregions, @rlbfgs, @arc};

M=spherefactory(n);

tao_set=[1e-5 1e-6 1e-7 1e-8 1e-9 1e-10 1e-11 1e-12]; 

num_instance=50;
randomdata.Q=[];
randomdata.x0=[];
randomdata(num_instance).Q = [];


j=0;
info=record();
Result(1)=info;
Result(10000).size=[];

for m=m_set

    for i=1:num_instance
        e=[ones(n,1);zeros(m-n,1)];
        [Q, ~] = mgson([rand(m,n-1),e]);% Gram-Schmidt orthonormalization
        x0=abs(M.rand());
        randomdata(i).Q=Q;
        randomdata(i).x0=x0;
    end

    for subalgorithm=subalgorithm_set

        for tao=tao_set
            
            j=j+1;count=0;

            for i=1:num_instance

                [~,~,~,options]=client_FSV(n,m,tao, ...
                    randomdata(i).Q,randomdata(i).x0, ...
                    appr_abs,subalgorithm{1});

                count=count+options.success;

                {n m subalgorithm{1}  tao i }

            end

            info=record();
            Result(j)=info;
        end

    end

end

Result = Result(1:j);

function info=record()
    if j==0
        info.size=[];
        info.tao=[];
        info.appr_abs=[];
        info.subalgorithm=[];
        info.success=[];
    else
        info.size=[n,m];
        info.tao=tao;
        info.appr_abs=func2str(appr_abs);
        info.subalgorithm=func2str(subalgorithm{1});
        info.success=count;
    end
end


end




