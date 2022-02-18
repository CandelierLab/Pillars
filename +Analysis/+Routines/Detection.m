clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4-2';
tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

% --- Threshold

th_rho = 4.77;

% --- Misc options

% File tag
ftag = 'events';

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', verbose);

% =========================================================================

if ~exist(F.filepath(ftag), 'file') || force

    % Load trajectories
    Data = load(F.File.trajectories);

    % Keep only the checked pillars
    Ic = [Data.P(:).checked];

    % Detector object
    Dtr = Analysis.Detector(Data.P(Ic), verbose=verbose);

    % Detection
    Dtr.detect(threshold=th_rho);
    fprintf('%i events detected.\n', numel(Dtr.E));

    % Skewness
    Dtr.skewness

    % Fit
    Dtr.fitAllEvents(threshold=th_rho)
    
    % --- Save

    if verbose
        fprintf('Saving ...')
        tic
    end

    E = Dtr.E;
    save(F.filepath(ftag), 'E');

    if verbose
        fprintf(' %.02f sec\n', toc);
    end
end

