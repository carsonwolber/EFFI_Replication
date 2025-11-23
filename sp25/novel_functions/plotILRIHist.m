function plotILRIHist(data)
    num_forecasters = length(data);
    
    for h = 1:5
        
        hStr = num2str(h);
        filename = sprintf('%s_%s', 'ILRI_Hist_', hStr);

        pi_vals = [];

        for f = 1:num_forecasters
            if length(data(f).horizons) >= h && isfield(data(f).horizons(h), 'pi')
                pi_vals = [pi_vals, data(f).horizons(h).pi];
            end  
        end

        
        figure;
        % this means the histogram will only distinguish up to the first
        % decimal
        histogram(pi_vals, 'BinWidth', 0.1);
        title(['ILRI Expectations For h = ', num2str(h-1)])
        xlabel('ILRI Rate')
        ylabel('Frequency')
        saveas(gcf, fullfile('figures', filename));
    end
end
