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
        X = [ones(size(data, 1), 1), data.(forecastColumns{h})];
        Y = data.(forecastColumns{h+1});
        regress = fitlm(X,Y);

        disp(regress.Coefficients)
        
    
        
        results(h).horizon = h;
        results(h).beta = regress.Coefficients.Estimate(3);
        results(h).rsqred = regress.Rsquared.Ordinary;
    end
    
    horizonPersistRegData = results;
end

IndivCpiSpfData = cleanIndivCpiSpf("data/Individual_CPI.xlsx");
IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData);




