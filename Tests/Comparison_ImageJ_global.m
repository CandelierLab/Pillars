
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Files and directories -----------------------------------------------

rootDir = '/home/raphael/Science/Projects/Misc/Pilars/';

% --- Movie name

% movieName = 'WT21pillars20percentGCB+sup.avi';
% movieName = 'g4gcb.avi';
movieName = 'g4dmemf12.avi';
% movieName = 'g4dmemf12-3.avi';
% movieName = 'g4dmemf12-4.avi';

pname = '15';

% --- Files

movieFile = [rootDir 'Data' filesep movieName];
trajFile = [rootDir 'Files' filesep movieName(1:end-3) 'mat'];

refFile = [rootDir 'Data' filesep movieName(1:end-4) filesep pname '.txt'];

% --- Parameters

ss = 100;

% =========================================================================

% --- Load reference trajectory

A = readmatrix(refFile);
xij = A(:,2);
yij = A(:,3);

% --- Files access

% Frame
VR = VideoReader(movieFile);
Tmp = read(VR, 1);
Frame = Tmp(:,:,1);

% Load trajectory
Tmp = load(trajFile);
traj = Tmp.traj;

% --- Find closest traj

[~, mi] = min((arrayfun(@(x) mean(x.position(:,1)), traj)-mean(xij)).^2 + ...
    (arrayfun(@(x) mean(x.position(:,2)), traj)-mean(yij)).^2);

t = traj(mi).t;
x = traj(mi).position(:,1) - mean(traj(mi).position(:,1)) + mean(xij);
y = traj(mi).position(:,2) - mean(traj(mi).position(:,2)) + mean(yij);

% --- Sliding median

xij_ = movmedian(xij, ss);
yij_ = movmedian(yij, ss);
x_ = movmedian(x, ss);
y_ = movmedian(y, ss);

% === Display =============================================================

clf

% --- Full view

subplot(3,2,1)
hold on
        
% imagesc(Frame);
% axis equal on ij
% colormap(gray);
% caxis auto;

plot(xij, yij, '-');
plot(x, y, '-');

% axis([mean(x)+5*[-1 1] mean(y)+5*[-1 1]]);
axis equal
box on

% --- Zoom

subplot(3,2,2)
hold on

I = 1:20;

plot(xij(I), yij(I), '.-');
plot(x(I), y(I), '.-');

axis equal
box on

legend({'ImageJ plugin', 'Matlab'})

% --- Distance to median

subplot(3,2,3:4)
hold on

% dij = sqrt((xij-xij(1)).^2 + (yij-yij(1)).^2);
% d = sqrt((x-x(1)).^2 + (y-y(1)).^2);

dij = sqrt((xij-xij_).^2 + (yij-yij_).^2);
d = sqrt((x-x_).^2 + (y-y_).^2);


I = 1:100;

plot(t(I), dij(I), '.-' );
plot(t(I), d(I), '.-' );

box on

ylabel('Distance to baseline (median)');

% --- Distance

subplot(3,2,5:6)
hold on

d = sqrt((x-xij).^2 + (y-yij).^2);

plot(t, d, 'k-');

box on

ylabel('Distance between trajs')

sgtitle([fname ' - ' pname]);

% --- Save

exportgraphics(gcf, ['/home/raphael/Science/Projects/Misc/Pilars/Figures/Comparison/' pname '.png'], 'Resolution', 300);
