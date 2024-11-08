%{
helper function to assist with plotting horizon persistance across the
4 decades from 1980-2010
%}
function plotHorizonPersistRegByDecade(data, baseName, showLegend, variable, forecastColumns)
    decades = [1980, 1990, 2000, 2010];

    for decade = decades
        decadeData = data(data.decade == decade, :);

        startDate = datetime(decade, 1, 1);
        endDate = datetime(decade + 9, 10, 1); 
        
        % timeIndex is a global term by default so we change it to be
        % decade-specific using this map approach. The point here is to
        % ultimately find the intra-decade time lags for each decade to
        % accurately estimate dk std errs
        allQuarters = (startDate:calquarters(1):endDate)';
        timeIndexMapping = containers.Map(datenum(allQuarters), 1:length(allQuarters));
        decadeData.timeIndex = arrayfun(@(x) timeIndexMapping(datenum(x)), decadeData.Date);

        decadeResults = runHorizonPersistReg(decadeData, forecastColumns);
        decadeStr = num2str(decade);
        filename = sprintf('%s_%s', baseName, decadeStr);

        plotHorizonPersistReg(decadeResults, filename, showLegend, variable);
    end
end