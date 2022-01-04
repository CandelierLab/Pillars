clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
tag = 'g4gcb-2';

% --- Misc options

% Verbose
verbose = true;

force = false;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', true);

% =========================================================================

% --- Memory map

if ~exist(F.File.mmap, 'file')
    
    F.createMmap();
    
end

% --- Pillars tracking

if ~exist(F.File.trajectories, 'file') || force

    % Define tracker object
    Tr = IP.pTracker(F);
        
    % Search pilars
    Tr.search('ks', 31, 'minCorr', 0.8, 'display', true);
  
    % Set kernels
    Tr.setKernels();
    
    % Track all pilars
    Tr.track();

    % Clean trajectories
    Tr.clean();
    
end
