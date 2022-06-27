function [ALL_INFO,options] = Boss_RMC_outliers(m,r,par,upper_iter,upper_time)

% Low-rank matrix completion with outliers.
% use client_RMC.m

% for m=n=500 or 5000; mu=sigma=0.1 or 1;
% r=10 as usual;
% mu=sigma=0.1 if par=1, mu=sigma=1 if par=2 for creating outliers;
% upper_iter is upper limit of total iterations;
% upper_time is upper limit of total time [s];
% this fun obtain iterplot and timeplot at the same.

RMSEtolerance=1e-8; % tolerance for erorr_RMSE

%% data setting
n=m;
Name=append('outliers_',num2str(m),'_musiga_',num2str(par),'_');

% get original low-rank matrix M0
while true
    U = randn(m, r); V = randn(n, r); M0 =  U*V';
    rankM0 = rank(M0);
    if rankM0 == r
        break
    end
end

% get M with outliers.
M=M0;

% sampling
rho=5; % oversampling factor
k=rho*r*(m+n-r); % observed sample number
observed_indices = sort(randperm(m*n, k));% Generate a random mask for observed entries. observed_indices is linear indix of omega.
unobserved_indices=setdiff(1:numel(M),observed_indices);

% get mu(mean) and sigma(SD)
switch par
    case 1
        mu=0.1;sigma=0.1;
    case 2
        mu=1;sigma=1;
end

% create outliers
ratio_outliers=0.05;
outliers_indices=observed_indices(randperm(k,ceil(ratio_outliers*k)));
outliers_indices = sort(outliers_indices);
for i=outliers_indices
    M(i)=M(i)+rand_11()*normrnd(mu,sigma);
end

% initial point
PM=M;PM(unobserved_indices)=0;[X0.U,X0.S,X0.V]=svds(PM,r);

%% test set

% In total, 5 x 6 = 30 cases.
smoothingfuns_set = {@appr_abs1,@appr_abs2,@appr_abs3, ...
    @appr_abs4,@appr_abs5};

subalgorithm_set = {@steepestdescent, @barzilaiborwein, @conjugategradient, ...
    @trustregions, @rlbfgs, @arc};


%% test begins

length_sf=length(smoothingfuns_set);
alliterplot=gobjects(1,length_sf);
alltimeplot=gobjects(1,length_sf);

i=0;
for appr_abs=smoothingfuns_set

    i=i+1;

    % fix a smoothing funs and test six solvers
    for subalgorithm=subalgorithm_set
        [~,~,all_info,options]= ...
            client_RMC(m,n,r,M,0,observed_indices,X0,M0, ...
            appr_abs{1},subalgorithm{1}, ...
            upper_iter,upper_time,RMSEtolerance);

        % record all info of 6 solvers
        all_info_abs.(func2str(subalgorithm{1}))=all_info;
    end

    % ALL_INFO stores every info of smoothing funs
    ALL_INFO.(func2str(appr_abs{1}))=all_info_abs;

    % plot six results in one figure
    iterplot=RMC_get_iterplot(all_info_abs,subalgorithm_set,upper_iter);
    timeplot=RMC_get_timeplot(all_info_abs,subalgorithm_set,upper_time);
    iterplot.Name=append('iter_',func2str(appr_abs{1}));
    timeplot.Name=append('time_',func2str(appr_abs{1}));
    alliterplot(i)=iterplot;
    alltimeplot(i)=timeplot;
end

%% optional; plot again from ALL_INFO if needed

% load('Data.mat');close all;
% i=0;
% for appr_abs=smoothingfuns_set
% all_info_abs=ALL_INFO.(func2str(appr_abs{1}));
% i=i+1;
% iterplot=RMC_get_iterplot(all_info_abs,subalgorithm_set,upper_iter);
% timeplot=RMC_get_timeplot(all_info_abs,subalgorithm_set,upper_time);
% iterplot.Name=append('iter_',func2str(appr_abs{1}));
% timeplot.Name=append('time_',func2str(appr_abs{1}));
% alliterplot(i)=iterplot;
% alltimeplot(i)=timeplot;
% end

%% optional; adjust all figs again if needed

% load('Data.mat');close all;
% alliterplot=openfig('outliers_500_musiga_1_iterplot_allfigs.fig');
% alltimeplot=openfig('outliers_500_musiga_1_timeplot_allfigs.fig');


%% adjust ALL ITER PLOT and export as pdf

ax=gobjects(1,length_sf);
i=0;
for appr_abs=smoothingfuns_set
    i=i+1;

    figure(alliterplot(i));

    xlim([0 upper_iter*1.05]);

    lgd=legend;
    lgd.FontSize = 12;
    legend('Location','northeast');

    xlabel('Iteration','FontSize', 12)
    ylabel('RMSE','FontSize', 12)

    ax(i) = gca;ax(i).FontSize = 16;
    ax(i).YLim = [RMSEtolerance 10];
    ax(i).YTick = 10.^(log10(RMSEtolerance):2:0);

    f = gcf;
    exportgraphics(f,append(Name,'iterplot_',func2str(appr_abs{1}),'.pdf'),'Resolution',300)
end

savefig(alliterplot,append(Name,'iterplot_allfigs.fig'));

% only for overview
overview_iter=RMC_mergefigs(ax,append(Name,'iterplot_overview.pdf'));
savefig(overview_iter,append(Name,'iterplot_overview.fig'));

%
close(alliterplot);



%% adjust ALL TIME PLOT and export as pdf

ax=gobjects(1,length_sf);
i=0;
for appr_abs=smoothingfuns_set
    i=i+1;

    figure(alltimeplot(i));

    xlim([0 upper_time*1.05]);

    lgd=legend;
    lgd.FontSize = 12;
    legend('Location','northeast');

    xlabel('Time [s]','FontSize', 12)
    ylabel('RMSE','FontSize', 12)

    ax(i) = gca;ax(i).FontSize = 16;
    ax(i).YLim = [RMSEtolerance 10];
    ax(i).YTick = 10.^(log10(RMSEtolerance):2:0);

    f = gcf;
    exportgraphics(f,append(Name,'timeplot_',func2str(appr_abs{1}),'.pdf'),'Resolution',300)
end

savefig(alltimeplot,append(Name,'timeplot_allfigs.fig'));

% only for overview
overview_time=RMC_mergefigs(ax,append(Name,'timeplot_overview.pdf'));
savefig(overview_time,append(Name,'timeplot_overview.fig'));


close(alltimeplot);

%% save some data
save('Data.mat');
close all;

end



%% local funs

function select=rand_11()
% a random variable with equal probability of being equal to +1 or -1
x=rand();
if x<0.5
    select=1;
else
    select=-1;
end
end

