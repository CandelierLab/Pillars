clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

i = 245;
% i = 208;

force = false;

% -------------------------------------------------------------------------

F = Focus(tag);

% =========================================================================

% --- Load pilars

if ~exist('Pc', 'var') || force
    
    fprintf('Loading checked pillars ...');
    tic
    
    tmp = load(F.File.trajectories);
    P = tmp.P;
    Pc = P([P(:).checked]);
    
    fprintf(' %.02f sec\n', toc);
    
end

Z = Pc(i).x-Pc(i).bx + 1i*(Pc(i).y-Pc(i).by);
R = abs(Z)';
A = angle(Z)';


% === Display =============================================================

figure(1)
clf

ax1 = subplot(2,1,1);
hold on

plot(R, '.-')
plot(smooth(R,5), 'r-')

box on
grid on

ax2 = subplot(2,1,2);
hold on

plot(mod(A,2*pi), '.-')

box on
% ylim([-1 1]*pi)

linkaxes([ax1 ax2], 'x');

xlim([25 50])