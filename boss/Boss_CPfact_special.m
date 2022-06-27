function RESULTE=Boss_CPfact_special()

% Codes for Section 4.2 A specifically structured instance

RESULTE=[];
orderset=[10 20 50 75 100 150];

%subalgorithm_set = {@steepestdescent, @conjugategradient, @trustregions};

for n=orderset
    r=n;
    A=gen_specialCP(n);
    B=get_init_fact(A,r);
    num_instance=50;
    
    Count.SM_SD=zeros(num_instance,3);
    Count.SM_CG=zeros(num_instance,3);
    Count.SM_RTR=zeros(num_instance,3);
    Count.SpFeasDC_ls=zeros(num_instance,3);
    Count.RIPG_mod=zeros(num_instance,3);
    Count.APM_mod=zeros(num_instance,3);

    for i=1:num_instance
        % randomly starting points
        X0=RandOrthMat(r);

        % show progress
        [n,r,i]

        %%%%%%% Methods %%%%%%%
        % Riemannian Smoothing Method
        % SM_SD
        [~,~,~,options]=client_CPfact(r,B,@steepestdescent,X0);
        time=options.all_time;no_itrs=options.num_iter;Success=options.success;
        Count.SM_SD(i,:)=[Success,time,no_itrs];

        % SM_CG
        [~,~,~,options]=client_CPfact(r,B,@conjugategradient,X0);
        time=options.all_time;no_itrs=options.num_iter;Success=options.success;
        Count.SM_CG(i,:)=[Success,time,no_itrs];

        % SM_RTR
        [~,~,~,options]=client_CPfact(r,B,@trustregions,X0);
        time=options.all_time;no_itrs=options.num_iter;Success=options.success;
        Count.SM_RTR(i,:)=[Success,time,no_itrs];

        % CC_SpFeasDC_ls 
        [~,Success,time,no_itrs]=CC_SpFeasDC_ls(A,B,r,X0);
        Count.SpFeasDC_ls(i,:)=[Success,time,no_itrs];

        % Bot_RIPG_mod 
        [~,Success,time,no_itrs]=Bot_RIPG_mod(A,r);
        Count.RIPG_mod(i,:)=[Success,time,no_itrs];

        % Gro_APM_mod 
        [~,Success,time,no_itrs]=Gro_APM_mod(B,r,X0);
        Count.APM_mod(i,:)=[Success,time,no_itrs];
        
        %%%%%%%%%%%%%%%%%%%%%%
    end

    Count_mean=zeros(1,20);
    Count_mean(1:2)=[n,r];

    fields = fieldnames(Count);
    
    i=0;
    for fieldname=fields'
        i=i+1;
        count=Count.(fieldname{1});
        Count_mean(3*i:3*i+2) = [mean(count(:,1)),mean(count(count(:,1) == 1,2:3),1)];
    end

    RESULTE=[RESULTE; Count_mean];
    
end

end