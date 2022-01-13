clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 2000;
N = 1000;

slope = 2.5;

th_n = 1:5;

A = 1:10;

force = true;

% -------------------------------------------------------------------------

th_rho = 4.77*th_n.^(-2/3);

% =========================================================================

if ~exist('mu', 'var') || force
    
    mu = NaN(numel(th_n), numel(A));
    
    fprintf('Computing ');
    tic
    
    for i = 1:numel(th_n)
        
        for j = 1:numel(A)
            
            me = NaN(N,1);
            
            for k = 1:N
                
                % --- Generation
                
                [Tr, GTr] = Simu.generate(T, 'np', 1, 'amp', A(j), ...
                    'ang', pi/3, 'slope', slope);
                
                % --- Detection
                
                Dtc = Analysis.Detector(Tr);
                
                Dtc.detect('th_nrho', 'th_n', th_n(i), 'th_r', th_rho(i));
                
                me(k) = Dtc.compare(GTr);
                            
            end
            
            mu(i,j) = sum(me)/N;
            
        end
        
        fprintf('.')
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% === Display =============================================================

cm = flipud(prism(numel(th_n)));

figure(1)
clf
hold on

for i = 1:numel(th_n)

    plot(A, mu(i,:), '.-', 'color', cm(i,:));
    
    line([1 1]*th_rho(i), ylim, 'LineStyle', ':', 'color', cm(i,:), ...
        'HandleVisibility', 'off')
    
end

box on

xlabel('A')
ylabel('\mu')
legend(arrayfun(@(x) ['th_n = ' num2str(x)], th_n, 'UniformOutput', false), 'location', 'SouthWest')
title('Ratio of missed events \mu');

