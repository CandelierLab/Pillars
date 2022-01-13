clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 50;
sigma = 1;

% =========================================================================

% --- Generation

Tr = Simu.generate(T, 'sigma', sigma, 'np', 0, 'amp', 8, 'slope', 2.5);

% === Display =============================================================

clf
hold on

plot(Tr.r, '.-');
plot(Tr.rho, '.-');

line([1 50], [0 0], 'lineStyle', '--', 'color', 'k')

axis([1 50 -5 5], 'square', 'off');

