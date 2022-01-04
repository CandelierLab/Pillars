clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data

tag = 'g4dmemf12';
pname = '6';

% Verbose
verbose = true;

force = false;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', verbose);

% =========================================================================

% --- Tracker

if ~exist('Tr', 'var') || force
    
    % Define tracker object
    Tr = pTracker(F);
    
    % Search pilars & kernels (references)
    Tr.search('ks', 31, 'minCorr', 0.8, 'display', false);

    % Set kernels
    Tr.setKernels();
    
end

% --- Reference traj

A = readmatrix([F.Dir.Data F.tag filesep pname '.txt']);
xij = A(:,2);
yij = A(:,3);

% --- Find closest pilar

[~, mi] = min((arrayfun(@(p) mean(p.x), Tr.P)-mean(xij)).^2 + ...
    (arrayfun(@(p) mean(p.y), Tr.P)-mean(yij)).^2);

% --- Track one

P = Tr.track_one(mi, 'verbose', verbose);

% === Display =============================================================

clf

subplot(1,3,1)
hold on

imshow(P.K)

axis on xy tight
caxis auto
colorbar

subplot(1,3,2:3)
hold on

I = 1:numel(P.x);

% plot(xij-xij(1), yij-yij(1), 'k.-')

plot(P.x(I)-P.x(1), P.y(I)-P.y(1), '.-')

plot(xij(I)-xij(1), yij(I)-yij(1), 'k.-')


grid on
box on
axis equal