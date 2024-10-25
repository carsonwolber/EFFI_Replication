function realPersistence = findRealPersistence(data)
    results = struct();
    colNames = data.Properties.VariableNames;
    cpiCols = colNames(startsWith(colNames, 'CPI'));
    lastCol = cpiCols{end};
    
    Y = data.(lastCol)(2:end);
    X = data.(lastCol)(1:end-1);
    augmented_X = [ones(length(X), 1), X];
    beta = regress(Y, augmented_X);
    residuals = Y - augmented_X * beta;
    sigma = std(residuals);
    rho = beta(2);
    
    results.rho = rho;
    results.pi = mean(data.(lastCol));
    results.sigma = sigma;
    realPersistence = results;
end