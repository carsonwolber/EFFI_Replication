%{
function to clean the [Individual_CPI.xlsx] file for analysis. This file
contains historical data for individual SPF forecasters predictions of the
CPI. To clean for analysis, we
1. limit the set of data to between Q1 1981 and Q4 2017
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
    
    % decade indicator for 1980s-2010s
    data.decade = floor(data.YEAR / 10) * 10;
    
    cleanedIndividualCPI = data;
end

