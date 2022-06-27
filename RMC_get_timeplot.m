% input all_info_abs = ALL_INFO.appr_abs1~5
% get plot in terms of time

function timeplot=RMC_get_timeplot(all_info_abs,subalgorithm_set,upper_time)
timeplot=figure();
for subalg=subalgorithm_set
    INFO=all_info_abs.(func2str(subalg{1}));

    indx=find([INFO.time]>upper_time,1);
    if ~isempty(indx)
        INFO = INFO(1:indx);
    end

    semilogy([INFO.time],[INFO.actual_cost], ...
        '-','LineWidth',2, 'DisplayName',func2str(subalg{1}));
    legend;
    hold on
end
end