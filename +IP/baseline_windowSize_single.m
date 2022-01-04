clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% Data tag
tag = 'g4dmemf12';

force = true;

% --- Algorithm

ws = logspace(log10(3), 3, 100);

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

% --- Computation

if ~exist('E1', 'var') || force

    fprintf('Computing eigenvalues ...');
    tic
    
    E1 = NaN(numel(Pc), numel(ws));
    
    for i = 1:numel(Pc)
        
        x = Pc(i).x';
        y = Pc(i).y';
        
        % --- Moving median
        
        for j = 1:numel(ws)
            
            xi = movmedian(x, ws(j));
            yi = movmedian(y, ws(j));
            
            [~,~,evalue] = pca([x-xi y-yi]);
            
            E1(i,j) = evalue(1);
            
        end
        
    end
   
    fprintf(' %.02f sec\n', toc);
    
end

% === Display =============================================================

clf

subplot(2,1,1)
hold on

plot(ws, E1, '-');

set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
xlim([min(ws) max(ws)]);
box on

xlabel('Time window (frames)');
ylabel('First eigenvalue e_1');
title(['All checked trajectories (' F.tag ')']);

subplot(2,1,2)
hold on

plot(ws, std(log(E1)), 'k.-')

[~, mi] = max(std(log(E1)));
line(ws(mi)*[1 1], ylim, 'linestyle', '--', 'color', [1 1 1]*0.5);

set(gca, 'XScale', 'log')
xlim([min(ws) max(ws)]);
box on

xlabel('Time window (frames)');
ylabel('std(log(e_1))');

