function realPersistence = findRealPersistence(data)
    results = struct();
    
    Y = data.CPI(2:end);       
    X = data.CPI(1:end-1);    

    augmented_X = [ones(length(X), 1), X];

    beta = regress(Y, augmented_X); 
    
    residuals = Y - augmented_X * beta;
    sigma = std(residuals);

    rho = beta(2);

    results.rho = rho;
    results.pi = mean(data.CPI);
    results.sigma = sigma;

    realPersistence = results;
end
