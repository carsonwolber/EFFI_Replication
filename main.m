addpath(genpath('.'));

IndivCpiSpfData = cleanIndivCpiSpf("data/Individual_CPI.xlsx");
IndivTBillSpfData = cleanIndivTBillSpf("data/Individual_TBILL.xlsx");
IndivUnempSpfData = cleanIndivUnempSpf("data/Individual_UNEMP.xlsx");


options = {'plot all analyses', ...
           'plot persistence across forecast horizons (figure 1)', ...
           'plot full sample persistence across forecast horizons (figure 1 panel A)', ...
           'plot persistence across forecast horizons by decade (figure 1 panel B)', ...
           'plot implied long run inflation histrogram', ...
           'plot implied long run inflation scatter plot', ...
           'simulate bias', ... 
           'plot persistence across forecast horizons (TBill & Unemp)', ...
           'exit'};

while true
    [choice, ~] = listdlg('PromptString', 'select an analysis to display:', ...
                          'SelectionMode', 'single', ...
                          'ListString', options, ...
                          'ListSize', [500 300]);             
    
    switch choice
        case 1
            disp('ploted everything');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData,  {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'});
            plotHorizonPersistReg(IndivCpiSpfRegData, 'figure1panelA', true, 'CPI');
            plotHorizonPersistRegByDecade(IndivCpiSpfData, 'figure1panelB', false, 'CPI');
            
        case 2
            disp('ploted figure 1');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData, {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'});
            disp(IndivCpiSpfRegData);
            
        case 3
            disp('ploted figure 1 panel A');
            IndivCpiSpfRegData = runHorizonPersistReg(IndivCpiSpfData,  {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'});
            plotHorizonPersistReg(IndivCpiSpfRegData, 'figure1panelA', true, 'CPI');
            
        case 4
            disp('ploted figure 1 panel B');
            plotHorizonPersistRegByDecade(IndivCpiSpfData, 'figure1panelB', false, 'CPI', {'CPI1', 'CPI2', 'CPI3', 'CPI4', 'CPI5', 'CPI6'});

        case 5
            disp('ploted ILRI Histogram');
            IRLIData = findILRIVars(IndivCpiSpfData);
            plotILRIHist(IRLIData);
        
        case 6
            disp('ploted ILRI Scatter');
            IRLIData = findILRIVars(IndivCpiSpfData);
            plotILRIScatter(IRLIData);

        case 7
            disp('simulating bias')
            RealCPIData = cleanRealCPI("data/Vintage_CPI.xlsx");
            RealDataVars = findRealPersistence(RealCPIData);
            SimulationData = simulateExpectations(RealDataVars);
        
        case 8
            disp('plot persistence across forecast horizons (TBill & Unemp)')
            IndivTBillSpfRegData = runHorizonPersistReg(IndivTBillSpfData, {'TBILL1', 'TBILL2', 'TBILL3', 'TBILL4', 'TBILL5', 'TBILL6'});
            IndivUnempSpfRegData = runHorizonPersistReg(IndivUnempSpfData, {'UNEMP1', 'UNEMP2', 'UNEMP3', 'UNEMP4', 'UNEMP5', 'UNEMP6'});
            plotHorizonPersistReg(IndivTBillSpfRegData, 'figure1panelA 3 Month TBill', true, 'Treasury Bills');
            plotHorizonPersistReg(IndivUnempSpfRegData, 'figure1panelA Unemp', true, 'Unemployment Rate');
            plotHorizonPersistRegByDecade(IndivTBillSpfData, 'figure1panelB 3 Month TBill', false, 'Treasury Bills',  {'TBILL1', 'TBILL2', 'TBILL3', 'TBILL4', 'TBILL5', 'TBILL6'});
            plotHorizonPersistRegByDecade(IndivUnempSpfData, 'figure1panelB Unemp', false, 'Unemployment Rate', {'UNEMP1', 'UNEMP2', 'UNEMP3', 'UNEMP4', 'UNEMP5', 'UNEMP6'});

        case 9
            disp('exited');
            break;

    end
end