function cleanedRealCPI = cleanRealCPI(file)
   opts = detectImportOptions(file);
   opts.VariableNamingRule = 'preserve';
   data = readtable(file, opts);
   
   dateColName = data.Properties.VariableNames{1};
   data.(dateColName) = datetime(data.(dateColName), 'InputFormat', 'yyyy:mm');
   
   startDate = datetime(1981, 7, 1);
   endDate = datetime(2016, 12, 1);
   data = data(data.(dateColName) >= startDate & data.(dateColName) <= endDate, :);
   
   startCol = find(strcmp(data.Properties.VariableNames, 'CPI94Q3'));
   endCol = find(strcmp(data.Properties.VariableNames, 'CPI16Q4')); 
   validCols = startCol:endCol;
   
   values = table2array(data(:, validCols));
   
   qoqChanges = zeros(size(values, 1)-1, size(values, 2));
   % columns need to be adjusted to annualized percentage points to match
   % SPF
   for i = 1:size(values, 2)
       for j = 2:size(values, 1)
           qoqChanges(j-1,i) = ((values(j,i)/values(j-1,i)) - 1) * 100 * 4;
       end
   end
   
   dates = data.(dateColName)(2:end);
   timeIndex = (year(dates) - 1981) * 4 + quarter(dates) - 2;
   
   cleanedRealCPI = array2table(qoqChanges, 'VariableNames', data.Properties.VariableNames(validCols));
   cleanedRealCPI.Date = dates;
   cleanedRealCPI.timeIndex = timeIndex;
   
   cleanedRealCPI = rmmissing(cleanedRealCPI);
end