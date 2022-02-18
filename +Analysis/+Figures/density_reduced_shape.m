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

force = false;

% -------------------------------------------------------------------------

F = Focus(tag, verbose=false);

% =========================================================================

% --- Detector

if ~exist('E', 'var') || force

    Tmp = load(F.filepath('events'));
    E = Tmp.E;

end

if ~exist('X', 'var')

    fprintf('Computing ...')
    tic

    % --- Remove saturated
    I = find([E(:).sat]==0);

    X = [];
    Y = [];

    for i = I %(1:1000)

        X = [X (E(i).frames-E(i).t0)*E(i).s/E(i).A];
        Y = [Y E(i).rho/E(i).A];

    end

    fprintf(' %.02f sec\n');

end

x = linspace(-1,3,200);
y = linspace(-0.5,1.5,200);
[xg, yg] = meshgrid(x,y);

yp = zeros(size(x));
I = x>0 & x<=1;
yp(I) = x(I);

% === Display =============================================================

figure(1)
clf
hold on

ksdensity([X' Y'], [xg(:) yg(:)])

zL = zlim;
plot3(x, yp, zL(2)*ones(size(x)), 'k-')

caxis([0 2])
colorbar

shading flat
axis tight
box on

xlabel('Reduced time')
ylabel('Reduced amplitude')
title(F.tag)

