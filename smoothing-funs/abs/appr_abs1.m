function f=appr_abs1(x,mu)
% upper bouned
% uniform smoothing function.

% <A riemannian smoothing steepest descent method for non-lipschitz
% optimization on submanifold.>

% example 2.8

% upper bouned
% a smooth approx to absolute function on R.
% parameter mu>0

%% if x is a vector or matrix, it applies elementwise.

f=abs(x);

index=find(f < mu/2);
for i=index
    f(i)=x(i).^2/(mu) + mu/4;
end

end


% y = arrayfun(@appr_abs1_for_real,x);
% 
% function f = appr_abs1_for_real(t)
%     if abs(t) <= mu/2
%         f= (t.^2)/mu + mu/4; % for abs(x)<=mu/2
%     else
%         f= abs(t); % for abs(x)>=mu/2
%     end
% end