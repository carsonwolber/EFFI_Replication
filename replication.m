%{
function to clean the [Individual_CPI.xlsx] file for analysis. This file
contains historical data for individual SPF forecasters predictions of the
CPI. To clean for analysis, we
1. limit the set of data to between Q1 1981 and Q4 1984 
2. limit the forecast horizon data to [CPI1, CPI5] for 5 discrete horizons
3. remove any rows with null forecast entries
4. insert a [timeIndex] column to allow for better grouping of panel data
%}
function cleanedIndividualCPI = cleanIndivCpiSpf(file)
    data = readtable(file);
    data.Date = datetime(data.YEAR, 1, 1) + calquarters(data.QUARTER - 1);

    startDate = datetime(1981, 7, 1);
    endDate = datetime(2017, 10, 1);

    data = data(data.Date >= startDate & data.Date <= endDate, :);

    forecastColumns = {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'};

    % Convert CPI columns to numeric values
    for col = forecastColumns
        colData = data.(col{1});
        data.(col{1}) = str2double(string(colData));
    end

    data = standardizeMissing(data, '#N/A');
    data = data(~any(ismissing(data(:, forecastColumns)), 2), :);
    
    % this equation makes the first time index for Q3 of '81 = 1 and each
    % subsequent quarter increments by 1
    timeIndex = (data.YEAR - 1981) * 4 + data.QUARTER - 2;
    data.timeIndex = timeIndex;
    
    cleanedIndividualCPI = data;
end

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
        
        df = 3;
        % tinv is a built in function for finding the inverse cdf of the
        % t-statistic (i.e. the critical value)
        criticalValue = tinv(0.95, df); 
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
    
    Xte = X .* repmat(residuals, 1, k);
    
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
        S_hat = S_hat + kernelWeight(l, lag) * (Gamma_hat_l + Gamma_hat_l');
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

IndivCpiSpfData = cleanIndivCpiSpf("data/Individual_CPI.xlsx");
IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData);

%{
function to plot persistence across forecasting horizons 
%}
function plotHorizonPersistReg(results, filename)
    horizons = [results.horizon] - 1;
    betas = [results.beta];
    CI_lowers = [results.CI_lower];
    CI_uppers = [results.CI_upper];
    rsquareds = [results.rsqred];
    
    figure;
    hold on;
    
    ci_plot = plot([horizons; horizons], [CI_lowers; CI_uppers], 'k-', 'LineWidth', 1.5);
    for i = 1:length(horizons)
        plot([horizons(i) - 0.1, horizons(i) + 0.1], [CI_lowers(i), CI_lowers(i)], 'k-', 'LineWidth', 1.5);
        plot([horizons(i) - 0.1, horizons(i) + 0.1], [CI_uppers(i), CI_uppers(i)], 'k-', 'LineWidth', 1.5);
    end
    
    beta_plot = scatter(horizons, betas, 100, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineWidth', 1.5);
    
    rsq_line = plot(horizons, rsquareds, 'r-', 'LineWidth', 1.5);
    rsq_scatter = scatter(horizons, rsquareds, 50, 'r', 'filled');
    
    xlabel('Forecast Horizon');
    title('Persistence Across Forecast Horizons');
    ylim([0 1]);
    yticks(0:0.2:1);
    yGridLines = 0:0.2:1;
    for y = yGridLines
        plot(xlim, [y, y], 'color', [0.5, 0.5, 0.5], 'LineStyle', '-', 'LineWidth', 0.5);
    end
    xlim([-0.5 4.5]);
    
    legend([ci_plot(1), beta_plot, rsq_line], {'90% confidence interval', 'Estimated coefficient', 'R-squared'}, 'Location', 'best');
    
    hold off;
    
    if ~exist('figures', 'dir')
        mkdir('figures');
    end
    saveas(gcf, fullfile('figures', filename));
end

plotHorizonPersistReg(IndivCpiSpfRegData, 'figure1panelA');

