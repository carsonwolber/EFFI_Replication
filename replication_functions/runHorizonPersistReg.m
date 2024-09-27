%{
function to perform a panel-data regression on the relationship between 
forecasters predictions of the CPI at horizon h+1 on horizon h. Where CPI 
data at each horizon is given by the table [data] parameter

Intuitively,this function is interested in finding how a forecasters
prediction at period h is effecting their later prediction at period h+1. 
Where h is in [1,5]. 

This function returns a struct containing data on the 
slope of the coefficient for "persistence", the R^2, and the Driscoll-Kraay
90% confidence interval thresholds, for each h. 
%}
function horizonPersistRegData = runHorizonPersistReg(data)
    forecastColumns = {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'};
    results = struct();

    for h = 1:5
        Y = data.(forecastColumns{h+1});
        X = [ones(size(data, 1), 1), data.(forecastColumns{h})];
        
        beta = (X' * X) \ (X' * Y);
        
        residuals = Y - X * beta;
        
        stdErr = driscollKraay(X, residuals, data.timeIndex);
        
        criticalValue = 2.96;
        CI_lower = beta(2) - criticalValue * stdErr(2);
        CI_upper = beta(2) + criticalValue * stdErr(2);
        
        SST = sum((Y - mean(Y)).^2);
        SSR = sum((X * beta - mean(Y)).^2);
        rsqred = SSR / SST;
        
        results(h).horizon = h;
        results(h).beta = beta(2);
        results(h).CI_lower = CI_lower;
        results(h).CI_upper = CI_upper;
        results(h).rsqred = rsqred;
    end
    
    horizonPersistRegData = results;
end