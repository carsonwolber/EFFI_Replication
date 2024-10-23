function simulate = simulateExpectations(RealDataVars)
    pi_hats = zeros(1000, 1);

    for sim = 1:1000
        pi_t = zeros(50, 1);
        pi_t(1) = RealDataVars.pi;
        for t = 2:50
            e_t = RealDataVars.sigma * randn();
            pi_t(t) = (1 - RealDataVars.rho) * RealDataVars.pi + RealDataVars.rho * pi_t(t - 1) + e_t;
        end

        Y = pi_t(2:end);
        X = [ones(49, 1), pi_t(1:end - 1)];

        beta = regress(Y, X);
        alpha_hat = beta(1);
        rho_hat = beta(2);
        pi_hats(sim) = alpha_hat / (1 - rho_hat);

    end

    simulate.mean_pi_hat = mean(pi_hats);
    simulate.true_pi = RealDataVars.pi;
    simulate.bias = simulate.mean_pi_hat - RealDataVars.pi;
end
