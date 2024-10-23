function cleanedRealCPI = cleanRealCPI(file)
    opts = detectImportOptions(file);
    opts.VariableNamingRule = 'preserve';
    data = readtable(file, opts);
    
    dateColName = data.Properties.VariableNames{1};
    data.(dateColName) = datetime(data.(dateColName), 'InputFormat', 'yyyy-MM-dd');
    
    cpiColName = data.Properties.VariableNames{2};
    
    startDate = datetime(1981, 7, 1);
    endDate = datetime(2017, 10, 1);
    
    data = data(data.(dateColName) >= startDate & data.(dateColName) <= endDate, :);
    
    data.Properties.VariableNames{2} = 'CPI';
    data = rmmissing(data, 'DataVariables', 'CPI');
    
    data.timeIndex = (year(data.(dateColName)) - 1981) * 4 + quarter(data.(dateColName)) - 2;
    
    cleanedRealCPI = data;
end
