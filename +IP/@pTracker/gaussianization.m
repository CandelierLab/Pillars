function gaussianization(this, varargin)

if this.verbose
    fprintf('--- Gaussianization\n');
end

if this.verbose
    fprintf('  * Aggregate radii ...');
    tic
end

% --- Radii

R = NaN(numel(this.P), this.F.T);

for i = 1:numel(this.P)
    R(i,:) = this.P(i).r;
end

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end

% --- Sigma_x,y

if this.verbose
    fprintf('  * Compute sigma_x,y ...');
    tic
end

% Restrict to checked pillars
Rc = R([this.P(:).checked],:);

[Phi, xi] = ecdf(Rc(:));
I = Phi<=0.5;

f = fit(xi(I), Phi(I), fittype('gammainc((x/a)^2,1)','options', ...
    fitoptions('Method','NonlinearLeastSquares',...
    'Lower', 0, 'Upper', 1, 'StartPoint', 0.1)));

sigma_x = f.a;

if this.verbose
    fprintf(' %0.2f sec (sigma = %.03f)\n', toc, sigma_x);
end

% --- Gaussianization

if this.verbose
    fprintf('  * Compute rho ...');
    tic
end

% Slightly less accurate computation
% % % rho = sqrt(2)*erfinv(2*gammainc((R/sigma_x).^2/2, 1)-1)+1/2;
    
% Slightly more accurate computation
rho = sqrt(2)*erfinv(1-2*gammainc((R/sigma_x).^2/2, 1, 'upper'))+1/2;
   
% Regularization of infinite values
I = ~isfinite(rho);
rho(I) = R(I)/sigma_x;

for i = 1:numel(this.P)
    this.P(i).rho = rho(i,:);
end

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end

% === Save ================================================================
    
if this.verbose
    fprintf('  * Saving ...');
    tic
end

P = this.P;
save(this.F.File.trajectories, 'P');

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end