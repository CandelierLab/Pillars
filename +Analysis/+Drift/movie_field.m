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

dn = 75;
f = 50;

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', true);

F.File.drift = [F.Dir.Files 'drift.mat'];

fname = [F.Dir.Movies F.tag filesep 'residual_drift_x50.avi'];

% =========================================================================

% --- Load ----------------------------------------------------------------

% --- Trajectories

tmp = load(F.File.trajectories);
P = tmp.P;

% --- Drift

tmp = load(F.File.drift);
drift = tmp.drift;

% --- Preparation ---------------------------------------------------------

% Positions
X = cell2mat({P(:).x}');
Y = cell2mat({P(:).y}');

% Driftplacements
dx_ = drift.x - drift.x(1);
dy_ = drift.y - drift.y(1);

% Neighbors
A = (X(:,1)-X(:,1)').^2 + (Y(:,1)-Y(:,1)').^2 <= dn^2;

VW = VideoWriter(fname);
open(VW);

for t = 1:F.T

    % Displacements
    dx = X(:,t)-X(:,1);
    dy = Y(:,t)-Y(:,1);
    
    % Residual displacements
    u = dx - dx_(t);
    v = dy - dy_(t);
    
    um = (A*u)./sum(A,2);
    vm = (A*v)./sum(A,2);

    % --- Display
    
    figure(1)
    clf
    hold on

    imshow(F.mmap.Data(t).frame)
    
    quiver(X(:,t), Y(:,t), f*um, f*vm, 0, 'color', 'y', 'linewidth', 1.5)

    text(18, 25, [F.tag ' / frame ' num2str(t, '%04i')], 'color', 'w', 'BackgroundColor', 'k');
    
    axis([1 F.W 1 F.H], 'xy');
    caxis auto
    box on
    
    drawnow
    
    % --- Save
    
    Fr = getframe();    
    writeVideo(VW, Fr.cdata);
    
end

close(VW);