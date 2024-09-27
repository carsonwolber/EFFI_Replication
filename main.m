addpath(genpath('.'));

IndivCpiSpfData = cleanIndivCpiSpf("data/Individual_CPI.xlsx");


options = {'plot all analyses', ...
           'plot persistence across forecast horizons (figure 1)', ...
           'plot full sample persistence across forecast horizons (figure 1 panel A)', ...
           'plot persistence across forecast horizons by decade (figure 1 panel B)', ...
           'exit'};

while true
    [choice, ~] = listdlg('PromptString', 'select an analysis to display:', ...
                          'SelectionMode', 'single', ...
                          'ListString', options, ...
                          'ListSize', [500 300]);             
    
    switch choice
        case 1
            disp('ploted everything');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData);
            plotHorizonPersistReg(IndivCpiSpfRegData, 'figure1panelA', true);
            plotHorizonPersistRegByDecade(IndivCpiSpfData, 'figure1panelB', false);
            
        case 2
            disp('ploted figure 1');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData);
            disp(IndivCpiSpfRegData);
            
        case 3
            disp('ploted figure 1 panel A');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData);
            plotHorizonPersistReg(IndivCpiSpfRegData, 'figure1panelA', true);
            
        case 4
            disp('ploted figure 1 panel B');
            plotHorizonPersistRegByDecade(IndivCpiSpfData, 'figure1panelB', false);
            
        case 5
            disp('exited');
            break;

    end
end