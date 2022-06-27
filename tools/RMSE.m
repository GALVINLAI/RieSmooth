function erorr=RMSE(X,M0)
% Root mean square error (RMSE) with respect to the original matrix M0.
[m,n]=size(M0);
erorr=norm(X-M0,"fro")/sqrt(m*n);
end