clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

xchi = linspace(0,4,100);
xg = linspace(-4,4,200);

% =========================================================================

Cchi = gammainc(xchi.^2/2, 1);

Cg = (1 + erf(xg/sqrt(2)))/2;

% === Display =============================================================

figure(1)
clf
hold on

plot(xchi, Cchi);

plot(xg, Cg);

box on
grid on
axis square

xlabel('x');
ylabel('cdf');
legend({'\chi distribution', 'Gaussian distribution'}, 'location', 'NorthWest');