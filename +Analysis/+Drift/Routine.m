clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

% --- Misc options

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', true);

F.File.drift = [F.Dir.Files 'drift.mat'];

% =========================================================================

% --- Memory map

if ~exist(F.File.mmap, 'file')
    F.createMmap();
end

% --- Computation
if ~exist(F.File.drift, 'file') || force
    Analysis.Drift.compute(F, 'display', true);
end

% --- Load drift
tmp = load(F.File.drift);
drift = tmp.drift;

