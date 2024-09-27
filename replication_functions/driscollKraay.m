%{ 
function to compute Driscoll-Kraay Standard Errors for a panel regression
by 
1. Multiply residuals by the design matrix (X) to capture the influence of
   predictor variables across time periods.
2. Sum these values for each time period to create a compressed summary
   of how errors and predictors interact over time (ht).
3. Compute the variance-covariance matrix (S_hat) using a weighted sum of 
   time-lagged error interactions. This accounts for autocorrelation over time.
4. Use S_hat to adjust standard errors, correcting for both heteroskedasticity 
   and autocorrelation across time periods.
%}
function StdErr = driscollKraay(X, residuals, time)
    T = length(unique(time));
    k = size(X, 2);
    lag = floor(4 * (T/100)^(2/9));
    
    Xte = X .* residuals;
    
    ht = zeros(T, k);
    for t = 1:T
        ht(t,:) = sum(Xte(time == t, :), 1);
    end
    
    S_hat = zeros(k, k);
    for l = 0:lag
        Gamma_hat_l = zeros(k, k);
        for t = l+1:T
            Gamma_hat_l = Gamma_hat_l + ht(t,:)' * ht(t-l,:);
        end
        Gamma_hat_l = Gamma_hat_l / T;
        weight = kernelWeight(l, lag);
        if l == 0
            S_hat = S_hat + Gamma_hat_l;
        else
            S_hat = S_hat + weight * (Gamma_hat_l + Gamma_hat_l');
        end
    end
    
    X_X_inv = inv(X' * X);
    V = T * X_X_inv * S_hat * X_X_inv;
    
    StdErr = sqrt(diag(V));
end



%{ 
helper function to compute the Bartlett kernal weight
this function reduces the weight of a prediction based on from
how far apart it is from the time being measured [l], 
as we assume predictions made farther apart are less related.
%}
function w = kernelWeight(l, lag)
    w = 1 - l / (lag + 1);
end

