%{
function to plot persistence across forecasting horizons 
%}
function plotHorizonPersistReg(results, filename, showLegend)
    horizons = [results.horizon] - 1;
    betas = [results.beta];
    CI_lowers = [results.CI_lower];
    CI_uppers = [results.CI_upper];
    rsquareds = [results.rsqred];
    
    figure('Position', [100, 100, 800, 600]);
    ax = axes('Position', [0.15, 0.15, 0.75, 0.75]);
    hold on;
    
    for i = 1:length(horizons)
        ci_plot = plot([horizons(i), horizons(i)], [CI_lowers(i), betas(i) - 0.01], 'k-', 'LineWidth', 1.5);
        plot([horizons(i), horizons(i)], [betas(i) + 0.01, CI_uppers(i)], 'k-', 'LineWidth', 1.5);
        plot([horizons(i) - 0.1, horizons(i) + 0.1], [CI_lowers(i), CI_lowers(i)], 'k-', 'LineWidth', 1.5);
        plot([horizons(i) - 0.1, horizons(i) + 0.1], [CI_uppers(i), CI_uppers(i)], 'k-', 'LineWidth', 1.5);
    end
    
    beta_plot = scatter(horizons, betas, 100, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineWidth', 1.5);
    rsq_line = plot(horizons, rsquareds, 'r-', 'LineWidth', 3);
    
    xlabel('Forecast Horizon');
    title('Persistence Across Forecast Horizons');
    ylim([0 1]);
    yticks(0:0.2:1);
    xlim([-0.5, 4.5]);
    xticks(0:1:4)
    
    yGridLines = 0:0.2:1;
    for y = yGridLines
        plot(xlim, [y, y], 'color', [0.5, 0.5, 0.5], 'LineStyle', '-', 'LineWidth', 0.5);
    end
    
    if showLegend
        legend([ci_plot, beta_plot, rsq_line], {'90% confidence interval', 'Estimated coefficient', 'R-squared'}, 'Location', 'best');
    end
    
    ax.YLim = [min(CI_lowers) - 0.1, max(CI_uppers) + 0.1];
    ax.YTick = 0:0.2:1;
    ax.YTickLabel = {'0', '0.2', '0.4', '0.6', '0.8', '1'};
    
    hold off;
    
    if ~exist('figures', 'dir')
        mkdir('figures');
    end
    saveas(gcf, fullfile('figures', filename));
end

