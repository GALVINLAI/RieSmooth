function RESULTE=Boss_CPfact_hard()

% Codes for Section 4.2 A specifically structured instance please load data
% file 'testdate_perturbation.mat'


load 'Boss_CPfact_hard_data.mat';

RESULTE=[];

% range of lamda
lamdaset1=[.6 .65 .7 .75 .8];
lamdaset2=[.82 .84 .86 .88 .9];
lamdaset3=[.9 .91 .92 .93 .94 .95 .96 .97 .98 .99];
lamdaset4=[.999 .9999];

lamdaset=[lamdaset1,lamdaset2,lamdaset3,lamdaset4];

%subalgorithm_set = {@steepestdescent, @conjugategradient, @trustregions};

for lamda = lamdaset
    A_lamda=lamda*A+(1-lamda)*C;
    r=12;
    B=get_init_fact(A_lamda,r);
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
        [lamda, i]

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
        [~,Success,time,no_itrs]=CC_SpFeasDC_ls(A_lamda,B,r,X0);
        Count.SpFeasDC_ls(i,:)=[Success,time,no_itrs];

        % Bot_RIPG_mod 
        [~,Success,time,no_itrs]=Bot_RIPG_mod(A_lamda,r);
        Count.RIPG_mod(i,:)=[Success,time,no_itrs];

        % Gro_APM_mod 
        [~,Success,time,no_itrs]=Gro_APM_mod(B,r,X0);
        Count.APM_mod(i,:)=[Success,time,no_itrs];

    end

    Count_mean=zeros(1,7);
    Count_mean(1)=lamda;

    fields = fieldnames(Count);
    
    i=1;
    for fieldname=fields'
        i=i+1;
        count=Count.(fieldname{1});
        Count_mean(i) = mean(count(:,1));
    end

    RESULTE=[RESULTE; Count_mean];

end

end