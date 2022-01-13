clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 2000;
N = 1000;

th_n = 1:5;
th_rho = logspace(-1,1,10);

force = true;

% =========================================================================

if ~exist('lambda', 'var') || force
    
    lambda = NaN(numel(th_n), numel(th_rho));
    
    fprintf('Computing ');
    tic
    
    for i = 1:numel(th_n)
        
        for j = 1:numel(th_rho)
            
            fp = NaN(N,1);
            
            for k = 1:N
                
                % --- Generation
                
                [Tr, GTr] = Simu.generate(T, 'np', 0);
                
                % --- Detection
                
                Dtc = Analysis.Detector(Tr);
                
                Dtc.detect('th_nrho', 'th_n', th_n(i), 'th_rho', th_rho(j));
                %    'preprocess', struct('type', 'Gaussian', 'sigma', 1));
                
                [~, fp(k)] = Dtc.compare(GTr);
                
            end
            
            lambda(i,j) = sum(fp)/N/T;
            
        end
        
        fprintf('.')
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Fits ----------------------------------------------------------------

f = NaN(numel(th_n), 3);
th_rho_ = NaN(numel(th_n),1);

for i = 1:numel(th_n)
   
    y = log(lambda(i,:));
    I = isfinite(y);
    f(i,:) = polyfit(th_rho(I), y(I), 2);
    
    th_rho_(i) = max(roots([f(i,1) f(i,2) f(i,3)-log(1e-6)]));
    
end

% --- Fit th_rho*

ft = fittype('a*x^(-2/3)', 'options', fitoptions('Method','NonlinearLeastSquares', ...
    'Lower', 1, 'Upper', 10, 'StartPoint', 5));
f_ = fit(th_n', th_rho_, ft);

% === Display =============================================================

cm = flipud(prism(numel(th_n)));

figure(1)
clf
hold on

x = linspace(0,6,100);

for i = 1:numel(th_n)

    plot(th_rho, lambda(i,:), '+', 'color', cm(i,:));
    
    plot(x, exp(f(i,1)*x.^2 + f(i,2)*x + f(i,3)), '--', 'color', cm(i,:), ...
        'HandleVisibility','off');
    
end

line(xlim, [1 1]*1e-6, 'LineStyle', ':', 'color', [1 1 1]*0.25)

box on
% set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
axis([0 6 1e-7 1], 'square')

xlabel('th_\rho')
ylabel('\lambda')
legend(arrayfun(@(x) ['th_n = ' num2str(x)], th_n, 'UniformOutput', false))
title('Ratio of false positive \lambda');

%% -------------------------------------------------------------------------

figure(2)
clf
hold on

plot(th_n, th_rho_, 'k+');

x = linspace(0.5,6,100);
plot(x, f_.a.*x.^(-2/3), 'r--')

axis([0 6 0 6], 'square')

xlabel('th_n');
ylabel('th_\rho*');
title('Threshold on \rho for \lambda=10^{-6}')

box on
axis square