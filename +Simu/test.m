clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 200;
sigma = 1;

% =========================================================================

% --- Generation

[Tr, GTr] = Simu.generate(T, 'sigma', sigma, ...
    'np', 1, 'amp', 10, 'ang', pi/3, ...
    'slope', 2);

% --- Detection

Dtc = Analysis.Detector(Tr);

Dtc.detect('th_nr', 'th_n', 3, 'th_r', 5); 
%    'preprocess', struct('type', 'Gaussian', 'sigma', 1));

[me, fp] = Dtc.compare(GTr);

% === Display =============================================================

clf

subplot(2,1,1)
hold on

plot(Tr.x, Tr.y, '.-');

axis equal
box on
grid on

subplot(2,1,2)
hold on

plot(Tr.x, '.-');
plot(Tr.y, '.-');

plot(sqrt(Tr.x.^2 + Tr.y.^2), 'k.-');

box on
grid on