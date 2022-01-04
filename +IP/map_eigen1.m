clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
tag = 'g4gcb-2';

ws = 80;

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
    
    x0 = NaN(numel(Pc), 1);
    y0 = NaN(numel(Pc), 1);
    
    E1 = NaN(numel(Pc), 1);
    V1 = NaN(numel(Pc), 2);
    
    for i = 1:numel(Pc)
     
        x0(i) = Pc(i).x(1); 
        y0(i) = Pc(i).y(1); 
        
        x = Pc(i).x';
        y = Pc(i).y';
        
        % Moving median
        xi = movmedian(x, ws);
        yi = movmedian(y, ws);
        
        [coeff,~,evalue] = pca([x-xi y-yi]);
        
        % Eigenvalue
        E1(i) = evalue(1);
        
        % Eigenvector
        p = (x-xi)*coeff(1,1) + (y-yi)*coeff(2,1);
        V1(i,:) = sign(skewness(p))*coeff(:,1)';
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Angles

A = angle(V1(:,1) + 1i*V1(:,2));

% === Display =============================================================

% % % clf
% % % plot(x-xi, y-yi, '.-')
% % % line([0 V1(i,1)*E1(i)], [0 V1(i,2)*E1(i)], 'color', 'r');
% % % axis equal
% % % return

clf

ax1 = axes;
ax2 = axes;

imagesc(F.refFrame, 'Parent', ax1);
scatter(ax2, x0, y0, 1+round(400*E1.^(1)), 'o', 'MarkerFaceColor', 'flat', 'CData', A);

colormap(ax1, gray);
colormap(ax2, hsv);

axis(ax1, [1 F.W 1 F.H], 'equal', 'xy', 'tight')
axis(ax2, [1 F.W 1 F.H], 'equal', 'xy', 'tight', 'off')

linkaxes([ax1,ax2])

hcb = colorbar(ax2, 'Position', [0.93 0.18 0.03 0.65])
hcb.Title.String = 'Angle of e_1';
hcb.XTick = -pi:pi/2:pi;
hcb.XTickLabel = {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'};

caxis(ax2, [-pi pi]);

xlabel(ax1, 'x (pix)')
ylabel(ax1, 'y (pix)')

title(ax1, F.tag)


