%% SYMURES 1.1 - A Multi-Reservoir MFD-Based Traffic Simulator
%--------------------------------------------------------------------------
%
% Authors
% -------
% Guilhem Mariotte - guilhem.mariotte@univ-eiffel.fr
% (Simulation platform design, traffic flow solvers, pre-processing
% and post-processing modules)
%
% Sergio Batista -  sab21@nyu.edu
% (DTA module, assignment and convergence loop)
%
% Version
% -------
% 1.1, April 2020

clear all
clc

addpath('Utilityfunctions/','FDfunctions/')
addpath('MFDsolver/','Assignment/','UserNetworks/','PostProc/','Route/','Convergence/')


%% Simulation definition
%--------------------------------------------------------------------------

% Choice of a network defined by user
Simulation.Network = 'Grid_9res';

% Choice of the solver
% 1: accbased / 2: tripbased
Simulation.Solver = 1;

% Simulation name
Simulation.Name = 'SC21';


%% Launch simulation
%--------------------------------------------------------------------------
delete(['UserNetworks/' Simulation.Network '/simul_log.txt'])
diary(['UserNetworks/' Simulation.Network '/simul_log.txt'])

try
    
    % Simulation initialization
    %--------------------------
    tic;
    disp ' '
    disp '********************************************'
    disp 'SymuRes V1.1 - network and demand definition'
    
    addpath(['UserNetworks/' Simulation.Network '/'])
    SimulSettings
    
    toc;
    
    % Simulation loop
    %----------------
    tic;
    disp 'Start simulation loop'
    
    Assignment.CurrentPeriodID = 1;
    Assignment.CurrentTime = Assignment.Periods(Assignment.CurrentPeriodID);
    
    % Route calculation
    RouteCalc
    
    while Assignment.CurrentTime < Simulation.Duration % loop on all assignment periods
        disp ' '
        disp(['Assignment period ' int2str(Assignment.CurrentPeriodID) ' - Simulation time: ' int2str(Assignment.CurrentTime)])
        disp '----------------------------------------------------------'
        
        % Convergence parameters
        Assignment.HasConverged = 0;
        Assignment.CurIteration = 1;
        
        while Assignment.HasConverged == 0
            
            disp ' '
            disp(['MSA loop ' int2str(Assignment.CurIteration)])
            
            % Assignment calculation
            AssignCalc
            
            % MFD solving
            if Simulation.Solver == 1
                MFDsolver_accbased
            elseif Simulation.Solver == 2
                MFDsolver_tripbased
            end
            
            % Convergence calculation
            ConvergeCalc
            
            % Iteration number
            Assignment.CurIteration = Assignment.CurIteration + 1;
            
        end
        
        Assignment.CurrentPeriodID = Assignment.CurrentPeriodID + 1;
        Assignment.CurrentTime = Assignment.Periods(Assignment.CurrentPeriodID);
    end
    
    disp ' '
    disp '*****************'
    disp 'End of simulation'
    toc;
    
    clear Temp_*
    
    % Save simulation outputs
    %------------------------
    if Simulation.Solver == 1
        outfile = ['UserNetworks/' Simulation.Network '/outputs/Outputs_' Simulation.Name '_accbased.mat'];
        save(outfile,'Simulation','Assignment','Reservoir','ODmacro','Route','MacroNode')
    elseif Simulation.Solver == 2
        outfile = ['UserNetworks/' Simulation.Network '/outputs/Outputs_' Simulation.Name '_tripbased.mat'];
        save(outfile,'Simulation','Assignment','Reservoir','ODmacro','Route','MacroNode','Global','Vehicle')
    end
    
    disp 'Simulation successfully saved as:'
    disp(outfile)
    rmpath(['UserNetworks/' Simulation.Network '/'])
    clear all
    diary off
    
catch err
    
    disp 'Simulation failed!'
    rmpath(['UserNetworks/' Simulation.Network '/'])
    diary off
    rethrow(err)
    
end


