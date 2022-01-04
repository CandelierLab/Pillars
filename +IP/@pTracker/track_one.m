function P = track_one(this, varargin)

% === Input ===============================================================

prs = inputParser;
prs.addRequired('p', @isnumeric);                           % Pilar index
prs.addParameter('waitbar', false, @islogical);             % Waitbar
prs.addParameter('verbose', this.verbose, @islogical);      % Verbose
prs.parse(varargin{:});

p = prs.Results.p;
wb = prs.Results.waitbar;
verbose = prs.Results.verbose;

% =========================================================================

if verbose
    fprintf('--- Tracking pilar %i\n', p);
end

% Output
P = this.P(p);

% Initial position
x0 = P.x(1);
y0 = P.y(1);

% Convolution kernel
K_ = rot90(P.K, 2);

[X, Y] = meshgrid(1:this.ks, 1:this.ks);

% === Track ===============================================================

if verbose
    fprintf('Tracking .');
    tic
end

if wb
    wbh = waitbar(0, ['Tracking pilar ' num2str(p)]);
end

for t = 1:this.F.T
    
    % Sub image
    Sub = this.F.getSub(t, x0, y0, this.ks);
    
    % Convolution
    C = conv2(Sub, K_, 'same');
    
    % Interger-pixel detection
    [yi, xi] = find(C==max(C(:)));
    
    % Sub-pixel detection
    C_ = C - (max(C(:))-min(C(:)))/2;
    C_(C_<0) = 0;
    
    I = C_>0;
    x = sum(X(I).*C_(I))./sum(C_(I));
    y = sum(Y(I).*C_(I))./sum(C_(I));
      
    % Regulartization & storage
    P.x(t) = x0 + x - (this.ks+1)/2;
    P.y(t) = y0 + y - (this.ks+1)/2;
    
    % Update kernel location
    x0 = x0 + xi - (this.ks+1)/2;
    y0 = y0 + yi - (this.ks+1)/2;
        
    % Verbose
    if verbose && ~mod(t,100)
        fprintf('.');
    end
    
    % Waitbar
    if wb && ~mod(t,10)
        waitbar(t/this.F.T, wbh);
    end
    
end

if verbose
    fprintf(' %0.2f sec\n', toc);
end

if wb
    close(wbh);
end