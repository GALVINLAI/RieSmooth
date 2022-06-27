tic


%% sec4.1 Result_CPfact_random_1point5  
clear;clc;close all;

newfolder='Result_CPfact_random_1point5';
mkdir(newfolder);
cd(newfolder);

p=1.5;
n_size=[20 30 40 100 200 400 600 800]; % 
RESULTE=Boss_CPfact_random(n_size,p);
save('RESULTE.mat','RESULTE');
cd ..\  % back to parent


%% sect4.1 Result_CPfact_random_3
clear;clc;close all;

newfolder='Result_CPfact_random_3';
mkdir(newfolder);
cd(newfolder);

p=3;
n_size=[20 30 40 100 200 400 600 800]; % 
RESULTE=Boss_CPfact_random(n_size,p);
save('RESULTE.mat','RESULTE');
cd ..\  % back to parent


%% sect4.2 Result_CPfact_special

clear;clc;close all;

newfolder='Result_CPfact_special';
mkdir(newfolder);
cd(newfolder);
RESULTE=Boss_CPfact_special();
save('RESULTE.mat','RESULTE');
cd ..\  % back to parent


%% sect4.4 Result_CPfact_hard

newfolder='Result_CPfact_hard';
mkdir(newfolder);
cd(newfolder);
RESULTE=Boss_CPfact_hard();
save('RESULTE.mat','RESULTE');
cd ..\  % back to parent

%%

t=toc;











