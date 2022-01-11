clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

tag = 'g4dmemf12';

force = true;

% -------------------------------------------------------------------------

F = Focus(tag, 'verbose', true);

% =========================================================================

% --- Load pilars ---------------------------------------------------------

if ~exist('Pc', 'var') || force
    
    fprintf('Loading checked pillars ...');
    tic
    
    tmp = load(F.File.trajectories);
    P = tmp.P;
    Pc = P([P(:).checked]);
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Radial distances ----------------------------------------------------

if ~exist('R', 'var') || force

    R = NaN(numel(Pc), F.T);
    
    for i = 1:numel(Pc)
        R(i,:) = sqrt((Pc(i).x-Pc(i).bx).^2 + (Pc(i).y-Pc(i).by).^2);
    end
    
end

% --- Sigma_x estimation --------------------------------------------------
    
if ~exist('sigma_x', 'var') || force

    [Phi, xi] = ecdf(R(:));
    
    I = Phi<=0.5;
    
    f = fit(xi(I), Phi(I), fittype('gammainc((x/a)^2,1)','options', ...
        fitoptions('Method','NonlinearLeastSquares',...
        'Lower', 0, 'Upper', 1, 'StartPoint', 0.1)));

% % %     figure(1)
% % %     clf
% % %     hold on
% % %     
% % %     plot(xi, Phi)
% % %     plot(f)
% % %     
% % %     xlim([0 0.3])
% % %     box on
% % %     grid on
    
    sigma_x = f.a;
    
end

% --- Gaussianization -----------------------------------------------------

% rho = sqrt(2)*erfinv(2*gammainc((R/sigma_x).^2/2, 1)-1)+1/2;

% Slightly more accurate representation
rho = sqrt(2)*erfinv(1-2*gammainc((R/sigma_x).^2/2, 1, 'upper'))+1/2;

% Regularization
I = ~isfinite(rho);
rho(I) = R(I);

%% === Display =============================================================

figure(1)
clf
hold on

i = 258;

plot(R(i,:)/sigma_x, '-')
plot(rho(i,:), '-')

box on
grid on
