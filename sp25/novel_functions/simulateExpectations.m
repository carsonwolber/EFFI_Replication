function simulate = simulateExpectations(RealDataVars)
    trueRho = RealDataVars.rho;
    truePi = RealDataVars.pi;
    trueSigma = RealDataVars.sigma;
    simulations = struct('alpha', {}, 'rho', {}, 'pi', {}, 'rhoTerm', {});

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
        simulations(i).rhoTerm = 1/(1-beta(2));
        simulations(i).pi = simulations(i).alpha * simulations(i).rhoTerm;
    end

    alphas = [simulations.alpha];
    rhoTerms = [simulations.rhoTerm];
    
    summary = struct();
    summary.means = struct();
    summary.means.alpha = mean(alphas);
    summary.means.rho = mean([simulations.rho]);
    summary.means.rhoTerm = mean(rhoTerms);
    covMatrix = cov(alphas, rhoTerms, 1);
    summary.means.pi = summary.means.alpha * summary.means.rhoTerm + ...
        2 * covMatrix(1,2);
    
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