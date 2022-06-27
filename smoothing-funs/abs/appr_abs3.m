function f=appr_abs3(x,mu)
% upper bouned
% a smooth approx to absolute function on R.
% parameter mu>0

%% if x is a vector or matrix, it applies elementwise.

f=zeros(size(x));

index=find(x >= 0);
for i=index
    f(i)= 2*mu*log(1+exp(-x(i)/mu) ) + x(i); %for x >=0
end

leftindex=setdiff(1:numel(x),index);
for i=leftindex
    f(i)= 2*mu*log(1+exp(x(i)/mu) ) - x(i); % for x <=0
end


end

