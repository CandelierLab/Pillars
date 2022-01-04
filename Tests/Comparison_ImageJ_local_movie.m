
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

pname = '15';
% --- Parameters

ws = 50;
ss = 100;

trace = 25;

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


for t = 1 %:Tr.T
    
    Fr = Tr.mmap.Data(t).frame;
    
    clf
    hold on
    
    % imagesc(Frame);
    colormap(gray);
    caxis auto;
    
    imshowpair(Frame, Fr, 'ColorChannels', 'red-cyan');
    
    I = max(1,t-trace):t;
    
    plot(xij(I), yij(I), 'c-');
    scatter(xij(t), yij(t), 100, 'cx');
    
    plot(x(I), y(I), 'r-');
    scatter(x(t), y(t), 100, 'r+');
    
%     plot(xij, yij, '-');
%     plot(x, y, '-');
    
%     axis([mean(x)+[-1 1]*ws/2 mean(y)+[-1 1]*ws/2], 'on', 'ij');
    box on
    
    title(t)
    
    drawnow limitrate
    
end