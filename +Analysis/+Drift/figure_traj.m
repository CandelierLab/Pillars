clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
tag = 'g4gcb';
% tag = 'g4gcb-2';

i = 1000;

% --- Misc options

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', true);

F.File.drift = [F.Dir.Files 'drift.mat'];

% =========================================================================

% --- Load ----------------------------------------------------------------

% --- Trajectories

tmp = load(F.File.trajectories);
P = tmp.P;

% --- Drift

tmp = load(F.File.drift);
drift = tmp.drift;


% --- Display

clf
hold on

plot(P(i).x, P(i).y, 'k.-')

plot(drift.x-drift.x(1)+P(i).x(1), drift.y-drift.y(1)+P(i).y(1), 'r-');

axis on xy equal
grid on
box on

legend({['Pilar #' num2str(i)], 'Global drift'}, 'location', 'NorthWest');

xlabel('x (pix)');
ylabel('y (pix)');

title(['trajectory vs drift (' F.tag ')'])