clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

T = 2000;
N = 1000;

th_n = 1:5;
th_r = linspace(1, 5, 9);

force = false;

% =========================================================================

if ~exist('rho', 'var') || force

rho = NaN(numel(th_n), numel(th_r));

fprintf('Computing ');
tic

for i = 1:numel(th_n)
    
    for j = 1:numel(th_r)

        fp = NaN(N,1);
        
        for k = 1:N
            
            % --- Generation
            
            [Tr, GTr] = Simu.generate(T, 'np', 0);
            
            % --- Detection
            
            Dtc = Analysis.Detector(Tr);
            
            Dtc.detect('th_nr', 'th_n', th_n(i), 'th_r', th_r(j));
            %    'preprocess', struct('type', 'Gaussian', 'sigma', 1));
            
            [~, fp(k)] = Dtc.compare(GTr);
            
        end
        
        rho(i,j) = sum(fp)/N/T;
        
    end
    
    fprintf('.')
    
end

fprintf(' %.02f sec\n', toc);
 
end

% --- Fits ----------------------------------------------------------------

f = NaN(numel(th_n), 3);
th_r_ = NaN(numel(th_n),1);

for i = 1:numel(th_n)
   
    y = log(rho(i,:));
    I = isfinite(y);
    f(i,:) = polyfit(th_r(I), y(I), 2);
    
    th_r_(i) = max(roots([f(i,1) f(i,2) f(i,3)-log(1e-6)]));
    
end

% --- Fit th_r*

ft = fittype('a/x^(1/2)', 'options', fitoptions('Method','NonlinearLeastSquares', ...
    'Lower', 1, 'Upper', 10, 'StartPoint', 5));
f_ = fit(th_n', th_r_, ft);

% === Display =============================================================

cm = flipud(prism(numel(th_n)));

figure(1)
clf
hold on

x = linspace(1,6,100);

for i = 1:numel(th_n)

    plot(th_r, rho(i,:), '+', 'color', cm(i,:));
    
    plot(x, exp(f(i,1)*x.^2 + f(i,2)*x + f(i,3)), '--', 'color', cm(i,:), ...
        'HandleVisibility','off');
    
end

line(xlim, [1 1]*1e-6, 'LineStyle', ':', 'color', [1 1 1]*0.25)

% set(gca, 'YScale', 'log');
% set(gca, 'XScale', 'log');
% ylim([0 1]);

box on

set(gca, 'YScale', 'log')
ylim(10.^[-7 0])

xlabel('th_r')
ylabel('\rho')
legend(arrayfun(@(x) ['th_n = ' num2str(x)], th_n, 'UniformOutput', false))
title('Ratio of false positive');

%% -------------------------------------------------------------------------

figure(2)
clf
hold on

plot(th_n, th_r_, 'k+');

plot(x, f_.a./x.^(1/2), 'r--')

xlabel('th_n');
ylabel('th_r*');
title('threshold on r for \rho=10^{-6}')

box on
axis square