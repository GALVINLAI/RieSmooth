% input all_info_abs = ALL_INFO.appr_abs1~5
% get plot in terms of number of iterations

function iterplot=RMC_get_iterplot(all_info_abs,subalgorithm_set,upper_iter)
iterplot=figure();
for subalg=subalgorithm_set
    INFO=all_info_abs.(func2str(subalg{1}));

    if length(INFO)>upper_iter
        INFO=INFO(1:upper_iter);
    end

    semilogy([INFO.actual_cost], ...
        '-','LineWidth',2, ...
        'DisplayName',func2str(subalg{1}));
    legend;
    hold on
end
end