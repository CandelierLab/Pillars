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

% --- Misc options

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', verbose);

fname = [F.Dir.Files 'candidates.mat'];

% =========================================================================

if ~exist(fname, 'file') || force

    % Load trajectories
    Data = load(F.File.trajectories);
    
    Tr = struct('x', {}, 'y', {}, 'rho', {});
    for i = 1
        Tr(i).x = Data.P(i).x - Data.P(i).bx;
        Tr(i).y = Data.P(i).y - Data.P(i).by;
        Tr(i).rho = Data.P(i).rho;
    end

    % Keep only the checked pillars

    % Detector object
    Dtr = Analysis.Detector(Tr);

    % Split & save
    Dtr.split(rotate=true, padLength=30, save=fname);

end

C = Dtr.Candidates

