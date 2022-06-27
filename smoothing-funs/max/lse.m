function result = lse(x,mu)
    % LogSumExp, a smooth approximation to max/min function.
    % the input x can be matrix or vector.
    
    % parameter mu cannot be zero

    % when mu is positive, lse(x,mu) approximates max function.
    % The littler mu is, the better approximation is.
    
    % when mu is negative, lse(x,mu) approximates min function.
    % The lagger mu is, the better approximation is.
    
    % we have to avoid numerical underflow and overflow.
    if mu >0
        % for max function
        maxval = max(x,[],'all');
        result = mu * log( sum( exp(  ( x - maxval ) /mu), 'all' ) ) + maxval;
    else
        % for min function
        minval = min(x,[],'all');
        result = mu * log( sum( exp( ( x - minval ) /mu), 'all' ) ) + minval;  
    end

end













