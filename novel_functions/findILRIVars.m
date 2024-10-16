function ILRIData = findILRIVars(data)

    results = struct();
    % ID is the indicator for each forecaster
    forecastors = unique(data.ID);
    forecastColumns = {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'};

    for f = 1:length(forecastors)
        ID = forecastors(f);
        forecasterData = data(data.ID == ID, :);

        results(f).ID = ID;
        results(f).horizons = struct();

        for h = 1:5
            Y = forecasterData.(forecastColumns{h+1});  
            X = forecasterData.(forecastColumns{h});
           
            validIdx = ~isnan(Y) & ~isnan(X);
            Y_valid = Y(validIdx);
            X_valid = X(validIdx);
            
            %{
            this is an arbitrary invariant that the forecaster has made
            at least 5 observations at the future horizon, this mainly
            serves to eliminate forecasters who's set of observations is
            limited to the ends of our timeline. Removing this
            invariant does seem to break the regression for some horizons
            hence it's existance. 
            %}
            if length(Y_valid) >= 5
                augmented_X = [ones(length(X_valid), 1), X_valid];
                beta = regress(Y_valid, augmented_X);
                %{
                values very close to 1 like .9993 give very
                inflated estimates so I set a threshold to .99. 
                %}
                if .95 >= beta(2) 
                    alpha_h_i_hat = beta(1);
                    rho_h_i_hat = beta(2);
                    pi_h_i_hat = alpha_h_i_hat / (1 - rho_h_i_hat);
                    results(f).horizons(h).horizon = h;
                    results(f).horizons(h).alpha = alpha_h_i_hat;
                    results(f).horizons(h).rho = rho_h_i_hat;
                    results(f).horizons(h).pi = pi_h_i_hat;
                end
            end
         
        end
    end
    ILRIData = results;
end
