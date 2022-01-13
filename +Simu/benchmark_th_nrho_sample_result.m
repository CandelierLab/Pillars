clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 200;

th_n = 1;
th_rho = 5.201;

A = 1:2:9;
slope = 2.5;

force = false;

% =========================================================================

[Tr, GTr] = Simu.generate(T, 'np', numel(A), 'amp', A, ...
    'ang', pi/3, 'slope', slope);
    
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

line([1 T], [0 0], 'LineStyle', ':', 'color', [1 1 1]*0.5);
line([1 T], [1 1]*th_rho, 'LineStyle', '--', 'color', [1 1 1]*0.5);

plot(Tr.rho, '.-')

box on

xlabel('Time (frames)');
ylabel('\rho')