tic

%% Boss_FSV_5
clear;clc;close all;

newfolder='Boss_FSV_5';
mkdir(newfolder); % cerate new folder
cd(newfolder); % go to folder

n=5; m_set=[4*n 6*n 8*n 10*n];
appr_abs=@appr_abs1;
Result_5= Boss_FSV(n,m_set,appr_abs);

save('Boss_FSV_5_data.mat');
cd ..\  % back to parent

%% Boss_FSV_10
clear;clc;close all;

newfolder='Boss_FSV_10';
mkdir(newfolder); % cerate new folder
cd(newfolder); % go to folder

n=10; m_set=[6*n 8*n 10*n 12*n];
appr_abs=@appr_abs1;
Result_10= Boss_FSV(n,m_set,appr_abs);

save('Boss_FSV_10_data.mat');
cd ..\  % back to parent


%%

t=toc;

