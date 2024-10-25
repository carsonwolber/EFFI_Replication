function simulate = simulateExpectations(RealDataVars)
    trueRho = RealDataVars.rho;
    truePi = RealDataVars.pi;
    trueSigma = RealDataVars.sigma;
    
    simulations = struct('alpha', {}, 'rho', {}, 'pi', {});
    
    for i = 1:1000
        simData = zeros(50, 1);
        simData(1) = truePi;
        
        for t = 2:50
            simData(t) = (1-trueRho)*truePi + trueRho*simData(t-1) + ...
                         normrnd(0, trueSigma);
        end
        
        Y = simData(2:end);
        X = simData(1:end-1);
        augmented_X = [ones(length(X), 1), X];
        beta = regress(Y, augmented_X);
        
        simulations(i).alpha = beta(1);
        simulations(i).rho = beta(2);
        simulations(i).pi = beta(1)/(1-beta(2));
    end
    
    summary = struct();
    summary.means = struct();
    summary.means.alpha = mean([simulations.alpha]);
    summary.means.rho = mean([simulations.rho]);
    summary.means.pi = mean([simulations.pi]);
    
    summary.std = struct();
    summary.std.alpha = std([simulations.alpha]);
    summary.std.rho = std([simulations.rho]);
    summary.std.pi = std([simulations.pi]); 
    
    summary.bias = struct();
    summary.bias.rho = summary.means.rho - trueRho;
    summary.bias.pi = summary.means.pi - truePi; 
    
    simulate = struct();
    simulate.simulations = simulations;
    simulate.summary = summary;
end