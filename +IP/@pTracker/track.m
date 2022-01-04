function track(this, varargin)

if this.verbose
    fprintf('--- Tracking\n');
end

% === Detection ===========================================================
   
if this.verbose
    fprintf('  * Tracking pilars .');
    tic
end

for i = 1:numel(this.P)
    
    % --- Trajectory
    
    P = this.track_one(i, 'verbose', false);    
    this.P(i).x = P.x;
    this.P(i).y = P.y;

    % --- Baseline
    
    this.P(i).bx = movmedian(this.P(i).x, this.bws);
    this.P(i).by = movmedian(this.P(i).y, this.bws);
    
    % --- Rotating coordinates
    
    this.P(i).u = NaN(this.F.T, 1);
    this.P(i).v = NaN(this.F.T, 1);
        
    x = (this.P(i).x - this.P(i).bx)';
    y = (this.P(i).y - this.P(i).by)';
    
    for ti = 1:this.F.T
        
        I = max(round(ti-this.ews/2),1):min(round(ti+this.ews/2), this.F.T);
        
        % Check for NaNs
        if any(isnan(x(I))), continue; end
        
        coeff = pca([x(I) y(I)]);
        
        % Eigenvector
        V1 = sign(skewness(x(I)*coeff(1,1) + y(I)*coeff(2,1)))*coeff(:,1)';
        
        % New coordinates
        this.P(i).u(ti) = x(ti)*V1(1) + y(ti)*V1(2);
        this.P(i).v(ti) = -x(ti)*V1(2) + y(ti)*V1(1);
        
        
    end
    
    % Display
    if this.verbose && ~mod(i,100)
        fprintf('.');
    end
    
end

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end

% === Add checked state (default: true) ===================================

if this.verbose
    fprintf('  * Setting checked state ...');
    tic
end

tmp = num2cell(true(numel(this.P),1));
[this.P(:).checked] = tmp{:};

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end

% === Save ================================================================
    
if this.verbose
    fprintf('  * Saving ...');
    tic
end

P = this.P;
if ~exist(this.F.Dir.Files, 'dir')
    mkdir(this.F.Dir.Files);
end
save(this.F.File.trajectories, 'P');

if this.verbose
    fprintf(' %0.2f sec\n', toc);
end