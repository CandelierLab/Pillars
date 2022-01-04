clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

force = false;

% --- Algorithm

ws = logspace(log10(3), 3, 100);

% -------------------------------------------------------------------------

Tags = Focus.taglist();

% =========================================================================

if ~exist('E1', 'var') || force
    
    E1 = cell(numel(Tags), 1);
    
    % --- Loop over datasets
    
    for k = 1:numel(Tags)
        
        % --- Set Focus
        
        F = Focus(Tags{k});
        
        % --- Load pilars
        
        fprintf('Loading checked pillars ...');
        tic
        
        tmp = load(F.File.trajectories);
        P = tmp.P;
        Pc = P([P(:).checked]);
        
        fprintf(' %.02f sec\n', toc);
        
        % --- Computation
        
        fprintf('Computing eigenvalues ...');
        tic
        
        E1{k} = NaN(numel(Pc), numel(ws));
        
        for i = 1:numel(Pc)
            
            x = Pc(i).x';
            y = Pc(i).y';
            
            % --- Moving median
            
            for j = 1:numel(ws)
                
                xi = movmedian(x, ws(j));
                yi = movmedian(y, ws(j));
                
                [~,~,evalue] = pca([x-xi y-yi]);
                
                E1{k}(i,j) = evalue(1);
                
            end
            
        end
        
        fprintf(' %.02f sec\n', toc);
        
    end
    
end

% === Display =============================================================

clf
hold on

cm = lines(numel(Tags));

% --- Curves

for k = 1:numel(Tags)

    plot(ws, std(log(E1{k})), '.-', 'color', cm(k,:));

end
    
% --- Maximums

for k = 1:numel(Tags)
    
    [~, mi] = max(std(log(E1{k})));
    line(ws(mi)*[1 1], ylim, 'linestyle', '--', 'color', cm(k,:));    
    
end

% --- Settings

axis square

set(gca, 'XScale', 'log')
xlim([min(ws) max(ws)]);
box on

xlabel('Time window (frames)');
ylabel('std(log(e_1))');

legend(Tags, 'location', 'SouthWest');
