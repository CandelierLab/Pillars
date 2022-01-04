
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Files and directories

% Data source
DS = DataSource;

% --- Movie name

% movieFile = 'WT21pillars20percentGCB+sup.avi';
% movieFile = 'g4gcb.avi';
% movieFile = 'g4gcb-2.avi';
movieFile = 'g4dmemf12.avi';
% movieFile = 'g4dmemf12-3.avi';
% movieFile = 'g4dmemf12-4.avi';

pname = '12';

% --- Parameters

ss = 100;

% =========================================================================

% --- Tracker and pilars

Tr = pTracker(movieFile);

% Frame
Frame = Tr.mmap.Data(1).frame;

% Pilars
tmp = load([DS.Files Tr.Movie.name '.mat']);
P = tmp.P;

% --- Load reference trajectory

A = readmatrix([DS.Data movieFile(1:end-4) filesep pname '.txt']);
xij = A(:,2);
yij = A(:,3);

% --- Find closest traj

[~, mi] = min((arrayfun(@(p) mean(p.x), P)-mean(xij)).^2 + ...
    (arrayfun(@(p) mean(p.y), P)-mean(yij)).^2);

t = 1:Tr.T;
x = P(mi).x' - mean(P(mi).x) + mean(xij);
y = P(mi).y' - mean(P(mi).y) + mean(yij);

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

legend({'ImageJ plugin', 'Matlab'}, 'location', 'NorthWest');

% --- Zoom

subplot(3,2,2)
hold on
        
imagesc(Frame);
axis equal on ij
colormap(gray);
caxis auto;

% plot(xij, yij, '-');
% plot(x, y, '-');

axis([mean(x)+25*[-1 1] mean(y)+25*[-1 1]]);
box on

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

sgtitle([DS.Data ' - ' pname]);

% --- Save

% exportgraphics(gcf, [DS.Figures 'Comparison/' pname '.png'], 'Resolution', 300);
