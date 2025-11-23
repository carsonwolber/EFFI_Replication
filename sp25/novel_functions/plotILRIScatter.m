function plotILRIScatter(data)
    for h = 2:5
        figure;
        hold on;
        
        pi_h0_vals = [];
        pi_h_vals = [];
        
        for f = 1:length(data)
            if length(data(f).horizons) >= h && isfield(data(f).horizons(1), 'pi') && isfield(data(f).horizons(h), 'pi')
                pi_h0 = data(f).horizons(1).pi;
                pi_h = data(f).horizons(h).pi;
                if isequal(size(pi_h0), size(pi_h)) && all(~isnan(pi_h0)) && all(~isnan(pi_h))
                    pi_h0_vals = [pi_h0_vals, pi_h0(:)'];  
                    pi_h_vals = [pi_h_vals, pi_h(:)'];
                end
            end
        end
        
        if ~isempty(pi_h0_vals) && ~isempty(pi_h_vals)
             scatter(pi_h0_vals, pi_h_vals, 40, 'blue', 'filled', 'o', ...
                        'MarkerEdgeColor', 'black', 'LineWidth', 0.5, ...
                        'MarkerFaceAlpha', 0.7);
                
            coeffs = polyfit(pi_h0_vals, pi_h_vals, 1);
            slope = coeffs(1);
            intercept = coeffs(2);
            
            xFit = linspace(min(pi_h0_vals), max(pi_h0_vals), 100);
            yFit = slope * xFit + intercept;
            
            plot(xFit, yFit, 'r-', 'LineWidth', 2);
            
        end

        hold off;

        hStr = num2str(h-1);
        filename = sprintf('%s_%s', 'ILRI_Scatter_', hStr);
        xlabel('h=0 ILRI');
        ylabel(['h = ', hStr, ' ILRI']);
        title(['ILRI at h = 0 vs. h = ', hStr]);
        legend('Data Points', sprintf('Trend Line (Slope: %.2f)', slope), 'Location', 'best');
        saveas(gcf, fullfile('figures', filename));
    end 
end
