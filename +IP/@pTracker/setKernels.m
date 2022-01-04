function setKernels(this, varargin)

% === Input ===============================================================

p = inputParser;
p.addParameter('force', false, @islogical);     % force computation
p.parse(varargin{:});

force = p.Results.force;

% =========================================================================

if isfield(this.P, 'K') && ~force
    return
end

if this.verbose
    fprintf('--- Define kernels\n');
end

% --- Large central peak mask ---------------------------------------------

if this.verbose
    fprintf('  *  Central peak mask ...');
    tic
end

[X, Y] = meshgrid(1:this.ks, 1:this.ks);
LCPM = 50*exp(-((X-this.ks/2).^2 + (Y-this.ks/2).^2)/50);

if this.verbose
    fprintf(' %.02f sec\n', toc);
end

% --- Computation ---------------------------------------------------------

if this.verbose
    fprintf('  *  Computing kernels ...');
    tic
end

for i = 1:numel(this.P)
    
    % Get sub
    Sub = this.F.getSub(1, this.P(i).x(1), this.P(i).y(1), this.ks);
    
    % Prepare and watershed
    L = watershed(-imgaussfilt(abs(Sub), 1.5) - LCPM);
    M = L==L((this.ks-1)/2, (this.ks-1)/2);
    
    % Store masked kernel
    this.P(i).K =  Sub.*M;
    
end

if this.verbose
    fprintf(' %.02f sec\n', toc);
end
