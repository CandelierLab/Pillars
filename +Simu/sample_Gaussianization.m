clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 1e6;
sigma_x = 1;

A = [];
slope = 2.25;

force = false;

% =========================================================================

[Tr, GTr] = Simu.generate(T, 'sigma', sigma_x, ...
    'np', numel(A), 'amp', A, 'ang', pi/3, 'slope', slope);

% === Display =============================================================

figure(1)
clf
hold on

for i = 1:numel(GTr)
    
    x1 = GTr{i}(1)-0.5;
    x2 = GTr{i}(end)+0.5;
    
    rectangle('Position', [x1 0 x2-x1 10], ...
        'EdgeColor', [1 1 1]*0.85, 'FaceColor', [1 1 1]*0.95);
    
end

plot(Tr.r, 'k-')
plot(Tr.rho, '-')

box on

xlabel('Time (frames)');
ylabel('r, \rho (\sigma_{x,y}=1)')

box on
grid on

return

% -------------------------------------------------------------------------

figure(2)
clf
hold on

[pdf, xi] = ksdensity(Tr.rho);

f = fit(xi', pdf', 'gauss1');

plot(xi, pdf, '+')
plot(f)

axis square
box on