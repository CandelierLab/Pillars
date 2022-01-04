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
wso = 100; 

% i = 201;
i = 214;

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
    
    fprintf('Computing eigenvectors ...');
    tic
    
    x = Pc(i).x';
    y = Pc(i).y';
    
    % Moving median
    xi = movmedian(x, ws);
    yi = movmedian(y, ws);
    
    E = NaN(F.T, 2);
    V1 = NaN(F.T, 2);
    
    u = NaN(F.T, 1);
    v = NaN(F.T, 1);
    
    for ti = 1:F.T
    
        I = max(round(ti-wso/2),1):min(round(ti+wso/2), F.T);
        
        [coeff,~,evalue] = pca([x(I)-xi(I) y(I)-yi(I)]);
        
        % Eigenvalue
        E(ti,:) = evalue';
        
        % Eigenvector
        p = (x(I)-xi(I))*coeff(1,1) + (y(I)-yi(I))*coeff(2,1);
        V1(ti,:) = sign(skewness(p))*coeff(:,1)';
        
        % New coordinates
        u(ti) = (x(ti)-xi(ti))*V1(ti,1) + (y(ti)-yi(ti))*V1(ti,2);
        v(ti) = -(x(ti)-xi(ti))*V1(ti,2) + (y(ti)-yi(ti))*V1(ti,1);
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Angles

A = mod(angle(V1(:,1) + 1i*V1(:,2)), 2*pi);

% === Display =============================================================

figure(1)
clf

hold on

plot(x-xi, y-yi, 'k-')
plot(u, v, 'm.-')

axis equal off
box on
grid on

legend({'x,y', 'u,v'});

xlabel('x, u (pix)');
ylabel('y, v (pix)');
title([F.tag ' - pillar ' num2str(i)]);

figure(2)
clf

% subplot(2,1,1)
% hold on
% 
% % plot(E(:,1), '.-');
% % plot(E(:,2), '.-');
% 
% plot(A, '.-');
% 
% box on
% % set(gca, 'YScale', 'log');
% 
% % xlim([0 100])
% 
% subplot(2,1,2)
hold on

plot(u, '.-');
plot(v, '.-');

box on
grid on

legend({'u', 'v'});

xlabel('time (frame)');
ylabel('u, v (pix)');
title([F.tag ' - pillar ' num2str(i)]);