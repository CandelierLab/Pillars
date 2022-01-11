clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

tags = Focus.taglist;

cm = lines(numel(tags));

% =========================================================================

figure(1)
clf
hold on

x = linspace(-6, 6, 200);
plot(x, 1/sqrt(2*pi)*exp(-x.^2/2), 'k--', 'HandleVisibility', 'off');

for Fi = 1:numel(tags)

    F = Focus(tags{Fi}, 'verbose', true);

    % --- Load pilars ---------------------------------------------------------
    
    fprintf('Loading checked pillars ...');
    tic
    
    tmp = load(F.File.trajectories);
    P = tmp.P;
    Pc = P([P(:).checked]);
    
    fprintf(' %.02f sec\n', toc);

    % --- Radial distances ----------------------------------------------------

    R = NaN(numel(Pc), F.T);

    for i = 1:numel(Pc)
        R(i,:) = sqrt((Pc(i).x-Pc(i).bx).^2 + (Pc(i).y-Pc(i).by).^2);
    end

    % --- Sigma_x estimation --------------------------------------------------

    [Phi, xi] = ecdf(R(:));
    I = Phi<=0.5;
    f = fit(xi(I), Phi(I), fittype('gammainc((x/a)^2,1)','options', ...
        fitoptions('Method','NonlinearLeastSquares',...
        'Lower', 0, 'Upper', 1, 'StartPoint', 0.1)));

% % %     figure(2)
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
    
    % --- Gaussianization -----------------------------------------------------
    
    % rho = sqrt(2)*erfinv(2*gammainc((R/sigma_x).^2/2, 1)-1)+1/2;
    
    % Slightly more accurate representation
    rho = sqrt(2)*erfinv(1-2*gammainc((R/sigma_x).^2/2, 1, 'upper'))+1/2;
    
    % Regularization
    I = ~isfinite(rho);
    rho(I) = R(I);
    
    [pdf, xi] = ksdensity(rho(:));
    
    plot(xi, pdf, '+', 'color', cm(Fi,:))
    
%     f = fit(xi', pdf', fittype('1/a/sqrt(2*pi)*exp(-(x/a)^2/2)','options', ...
%         fitoptions('Method','NonlinearLeastSquares',...
%         'Lower', 0, 'Upper', 2, 'StartPoint', 1)));

end
    
% === Display =============================================================

box on
grid on

legend(tags)

axis([-5 8 0 0.5], 'square')

set(gca, 'YScale', 'log');
ylim(10.^[-5 0])

xlabel('\rho')
ylabel('pdf')