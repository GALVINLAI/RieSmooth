

%% New perfect_5000; it spends ?? min.
tic
clear;clc;close all;
newfolder=append('perfect_5000');
mkdir(newfolder); % cerate new folder
cd(newfolder); % go to folder
[~,~] = Boss_RMC_perfect(5000,10,100,180);
cd ..\  % back to parent
toc

%% New outlier_500 for mu,sigma=0.1 and 1; it spends 48min.

tic
clear;clc;close all;
for i=1:2
newfolder=append('musigma',num2str(i));
mkdir(newfolder); % cerate new folder
cd(newfolder); % go to folder
[~,~] = Boss_RMC_outliers(500,10,i,200,20);
cd ..\  % back to parent
end
toc

%% New outlier_5000 for mu,sigma=0.1 and 1; it spends ?? min.
% tic
% clear;clc;close all;
% 
% for i=1:2
% newfolder=append('musigma',num2str(i));
% mkdir(newfolder); % cerate new folder
% cd(newfolder); % go to folder
% [ALL_INFO,options] = Boss_RMC_outliers(50000,10,i,200,300);
% cd ..\  % back to parent
% end

% toc






