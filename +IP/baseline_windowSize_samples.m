clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% Data tag
tag = 'g4dmemf12';

% Pilars without events
I0 = [1 5 29 102 105 205 264 268 290 331 585 626 618 622 656 1009 1063 1074 1117 1118];

% Pilars with events
I1 = [66 80 106 115 146 152 281 350 345 379 529 553 557 567 592 988 1021 1073 1081 1120];

% --- Algorithm

ws = logspace(log10(3), 3, 50);

% -------------------------------------------------------------------------

F = Focus(tag);

% =========================================================================

% --- Load pilars

if ~exist('P', 'var')
    
    fprintf('Loading pilars ...');
    tic
    
    tmp = load(F.File.trajectories);
    P = tmp.P;
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Computation

e0 = NaN(numel(I0), numel(ws));
e1 = NaN(numel(I1), numel(ws));

for i = 1:numel(I0)

    k = I0(i);
    x = P(k).x';
    y = P(k).y';
    
    % --- Moving median

    for j = 1:numel(ws)
    
        xi = movmedian(x, ws(j));
        yi = movmedian(y, ws(j));
        
        [~,~,evalue] = pca([x-xi y-yi]);
        
        e0(i,j) = evalue(1);

    end
    
end
     

for i = 1:numel(I1)

    k = I1(i);
    x = P(k).x';
    y = P(k).y';
    
    % --- Moving median

    for j = 1:numel(ws)
    
        xi = movmedian(x, ws(j));
        yi = movmedian(y, ws(j));
        
        [~,~,evalue] = pca([x-xi y-yi]);
        
        e1(i,j) = evalue(1);

    end
    
end

% === Display =============================================================

clf

subplot(2,1,1)
hold on

plot(ws, e0, '.-')

set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
xlim([min(ws) max(ws)]);

xlabel('Time window (frames)');
ylabel('First eigenvalue e_1');
title([num2str(numel(I0)) ' trajectories without events (' F.tag ')'])

box on

subplot(2,1,2)
hold on

plot(ws, e1, '.-')

set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
xlim([min(ws) max(ws)]);

xlabel('Time window (frames)');
ylabel('First eigenvalue e_1');
title([num2str(numel(I1)) ' trajectories with events (' F.tag ')'])

box on
