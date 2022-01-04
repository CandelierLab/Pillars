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

wso = [5 10 20 50 100 200]; 

% i = 201;
i = 523;

force = true;

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

% --- Compute eigenvectors

if ~exist('V1', 'var') || force
    
    fprintf('Computing eigenvectors .');
    tic
    
    x = Pc(i).x';
    y = Pc(i).y';
    
    % Moving median
    xi = movmedian(x, ws);
    yi = movmedian(y, ws);
    
    u = NaN(F.T, numel(wso));
    v = NaN(F.T, numel(wso));
    
    for k = 1:numel(wso)
        
        E = NaN(F.T, 2);
        V1 = NaN(F.T, 2);
        
        for ti = 1:F.T
            
            I = max(round(ti-wso(k)/2),1):min(round(ti+wso(k)/2), F.T);
            
            [coeff,~,evalue] = pca([x(I)-xi(I) y(I)-yi(I)]);
            
            % Eigenvalue
            E(ti,:) = evalue';
            
            % Eigenvector
            p = (x(I)-xi(I))*coeff(1,1) + (y(I)-yi(I))*coeff(2,1);
            V1(ti,:) = sign(skewness(p))*coeff(:,1)';
            
            % New coordinates
            u(ti,k) = (x(ti)-xi(ti))*V1(ti,1) + (y(ti)-yi(ti))*V1(ti,2);
            v(ti,k) = -(x(ti)-xi(ti))*V1(ti,2) + (y(ti)-yi(ti))*V1(ti,1);
            
        end
        
        fprintf('.');
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

%% === Display =============================================================

figure(1)
clf


% % % plot(x-xi, y-yi, '-', 'color', [1 1 1]*0.75)
% % % plot(x-xi, y-yi, '.', 'color', [1 1 1]*0.25)
% % % % plot(u, v, 'm.-')
% % % 
% % % axis equal off
% % % box on
% % % grid on
% % % return

subplot(2,1,1)
hold on

for k = 1:numel(wso)

    plot(u(:,k)+(k-1), '.-');
    
end

box on
grid on
xlabel('time (frame)');
ylabel('u (pix)');
title([F.tag ' - pillar ' num2str(i)]);

subplot(2,1,2)
hold on

for k = 1:numel(wso)

    plot(v(:,k)+(k-1), '.-');
    
end

box on
grid on

% legend({'u', 'v'});

xlabel('time (frame)');
ylabel('v (pix)');

legend(arrayfun(@(x) ['ws = ' num2str(x,'%03i')], wso, 'UniformOutput', false));
