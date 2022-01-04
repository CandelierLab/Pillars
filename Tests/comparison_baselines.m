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

wmn = 100;
wmd = 90;

ksig = 0.05;
ws = 25;

% --- Misc options

% Verbose
verbose = true;

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

emn0 = NaN(numel(I0),2);
emd0 = NaN(numel(I0),2);
ed0 = NaN(numel(I0),2);

for i = 1:numel(I0)

    k = I0(i);
    x = P(k).x';
    y = P(k).y';

    % --- Moving mean
    
    xi = movmean(x, wmn);
    yi = movmean(y, wmn);
    [~,~,emn0(i,:)] = pca([x-xi y-yi]);
    
    % --- Moving median
    
    xi = movmedian(x, wmd);
    yi = movmedian(y, wmd);
    [~,~,emd0(i,:)] = pca([x-xi y-yi]);

    % --- High density points
    
    % Density
    D = squareform(pdist([x y]));
    d = sum(exp(-D.^2/2/ksig^2));
    
    % Higher density points
    J = find(d==movmax(d, ws));
    
    % --- Interpolation
    
    xi = NaN(F.T,1);
    yi = NaN(F.T,1);
    for j = 1:numel(J)-1
        xi(J(j):J(j+1)) = linspace(x(J(j)), x(J(j+1)), J(j+1)-J(j)+1);
        yi(J(j):J(j+1)) = linspace(y(J(j)), y(J(j+1)), J(j+1)-J(j)+1);
    end
    
    % Regularize beginning
    xi(1:J(1)) = x(J(1));
    yi(1:J(1)) = y(J(1));
    
    % Regularize end
    xi(J(end):end) = x(J(end));
    yi(J(end):end) = y(J(end));
    
    xi = smooth(xi, 2*ws);
    yi = smooth(yi, 2*ws);
    [~,~,ed0(i,:)] = pca([x-xi y-yi]);
    
end

% -------------------------------------------------------------------------

emn1 = NaN(numel(I1),2);
emd1 = NaN(numel(I1),2);
ed1 = NaN(numel(I1),2);

for i = 1:numel(I1)

    k = I1(i);
    x = P(k).x';
    y = P(k).y';

    % --- Moving mean
    
    xi = movmean(x, wmn);
    yi = movmean(y, wmn);
    [~,~,emn1(i,:)] = pca([x-xi y-yi]);
    
    % --- Moving median
    
    xi = movmedian(x, wmd);
    yi = movmedian(y, wmd);
    [~,~,emd1(i,:)] = pca([x-xi y-yi]);

    % --- High density points
    
    % Density
    D = squareform(pdist([x y]));
    d = sum(exp(-D.^2/2/ksig^2));
    
    % Higher density points
    J = find(d==movmax(d, ws));
    
    % --- Interpolation
    
    xi = NaN(F.T,1);
    yi = NaN(F.T,1);
    for j = 1:numel(J)-1
        xi(J(j):J(j+1)) = linspace(x(J(j)), x(J(j+1)), J(j+1)-J(j)+1);
        yi(J(j):J(j+1)) = linspace(y(J(j)), y(J(j+1)), J(j+1)-J(j)+1);
    end
    
    % Regularize beginning
    xi(1:J(1)) = x(J(1));
    yi(1:J(1)) = y(J(1));
    
    % Regularize end
    xi(J(end):end) = x(J(end));
    yi(J(end):end) = y(J(end));
    
    xi = smooth(xi, 2*ws);
    yi = smooth(yi, 2*ws);
    [~,~,ed1(i,:)] = pca([x-xi y-yi]);
    
end

% === Display =============================================================

figure(1)
clf
hold on

plot(emn0(:,1), 'r.-');
plot(emn0(:,2), 'r.--');

plot(emd0(:,1), 'm.-');
plot(emd0(:,2), 'm.--');

plot(ed0(:,1), 'k.-');
plot(ed0(:,2), 'k.--');

% plot(emn0(:,1)./emn0(:,2), 'b.-');
% plot(emd0(:,1)./emd0(:,2), 'r.-');
% plot(ed0(:,1)./ed0(:,2), 'k.-');

box on
% ylim([0 0.5])

figure(2)
clf
hold on

% plot(emn1(:,1), 'r.-');
% plot(emn1(:,2), 'r.--');
% 
% plot(emd1(:,1), 'm.-');
% plot(emd1(:,2), 'm.--');
% 
% plot(ed1(:,1), 'k.-');
% plot(ed1(:,2), 'k.--');

plot(emn1(:,1)./emn1(:,2), 'b.-');
plot(emd1(:,1)./emd1(:,2), 'r.-');
plot(ed1(:,1)./ed1(:,2), 'k.-');

box on
% ylim([0 0.5])