function track(this, arg)

arguments
    this
    arg.save logical = true
end

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
    this.P(i).fx = P.x;
    this.P(i).fy = P.y;

    % --- Baseline

    this.P(i).bx = movmedian(this.P(i).fx, this.bws);
    this.P(i).by = movmedian(this.P(i).fy, this.bws);

    % --- Radial coordinate

    this.P(i).r = sqrt((this.P(i).fx - this.P(i).bx).^2 + (this.P(i).fy - this.P(i).by).^2);

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

if arg.save

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

end