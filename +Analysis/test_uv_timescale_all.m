clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

ws = 80;

wso = logspace(log10(3), log10(200), 20);

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

Pc = Pc(1:50);

% --- Compute eigenvectors

if ~exist('Sv', 'var') || force
    
    fprintf('Computing eigenvectors .');
    tic
    
    Sv = NaN(numel(Pc), numel(wso));
    
    for i = 1:numel(Pc)
        
        x = Pc(i).x';
        y = Pc(i).y';
        
        % Moving median
        xi = movmedian(x, ws);
        yi = movmedian(y, ws);
        
        v = NaN(F.T, numel(wso));
        
        for k = 1:numel(wso)
            
            V1 = NaN(F.T, 2);
            
            for ti = 1:F.T
                
                I = max(round(ti-wso(k)/2),1):min(round(ti+wso(k)/2), F.T);
                
                coeff = pca([x(I)-xi(I) y(I)-yi(I)]);
                
                
                % Eigenvector
                p = (x(I)-xi(I))*coeff(1,1) + (y(I)-yi(I))*coeff(2,1);
                V1(ti,:) = sign(skewness(p))*coeff(:,1)';
                
                % New coordinates
                v(ti,k) = -(x(ti)-xi(ti))*V1(ti,2) + (y(ti)-yi(ti))*V1(ti,1);
                
            end
            
        end
        
        Sv(i,:) = std(v, 0, 1);
        
        if ~mod(i, 1), fprintf('.'); end
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% === Display =============================================================

figure(1)
clf
hold on

plot(wso, Sv, '.-');

set(gca, 'XScale', 'log');
% set(gca, 'YScale', 'log');
box on

xlabel('ws (frame)');
ylabel('std(v) (pix)');
title([F.tag ' - First 50 checked pilars'])
