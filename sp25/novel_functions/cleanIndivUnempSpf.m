function cleanedIndividualUnemp = cleanIndivUnempSpf(file)
    data = readtable(file);
    data.Date = datetime(data.YEAR, 1, 1) + calquarters(data.QUARTER - 1);

    startDate = datetime(1981, 7, 1);
    endDate = datetime(2017, 10, 1);

    data = data(data.Date >= startDate & data.Date <= endDate, :);

    forecastColumns = {'UNEMP1', 'UNEMP2', 'UNEMP3', 'UNEMP4', 'UNEMP5', 'UNEMP6'};

    for col = forecastColumns
        colData = data.(col{1});
        data.(col{1}) = str2double(string(colData));
    end

    data = standardizeMissing(data, '#N/A');
    data = data(~any(ismissing(data(:, forecastColumns)), 2), :);

    timeIndex = (data.YEAR - 1981) * 4 + data.QUARTER - 2;
    data.timeIndex = timeIndex;
    
    data.decade = floor(data.YEAR / 10) * 10;
    
    cleanedIndividualUnemp = data;
end



