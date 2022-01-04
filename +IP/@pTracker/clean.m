function clean(this, varargin)

if this.verbose
    fprintf('--- Cleaning\n');
end

% === Detection ===========================================================
   
if this.verbose
    fprintf('  * Uncheck pilars with NaNs ...');
    tic
end

I = arrayfun(@(p) any(isnan(p.x)), this.P);

tmp = num2cell(false(numel(I),1));
[this.P(I).checked] = tmp{:};

if this.verbose
    fprintf(' %0.2f sec (%i found)\n', toc, nnz(I));
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