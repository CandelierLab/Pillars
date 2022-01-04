function search(this, varargin)

if this.verbose
    fprintf('--- Searching initial positions\n');
end

% === Input ===============================================================

p = inputParser;
p.addParameter('ks', this.ks, @isnumeric);           % Kernel size
p.addParameter('minCorr', 0.8, @isnumeric);     % Correlation threshold
p.addParameter('display', false, @islogical);   % Display the result
p.parse(varargin{:});

ks = p.Results.ks;
minCorr = p.Results.minCorr;
display = p.Results.display;

% -------------------------------------------------------------------------

a = (ks-1)/2;

% === Frame ===============================================================

Img = this.F.mmap.Data(1).frame;

% === Kernel ==============================================================

if this.verbose
    fprintf('  * Average kernel ...');
    tic
end

% --- Candidate detection

% Shift (any value between 5 and 10 works)
shift = 8;

Tmp = Img + imtranslate(-Img, [-1 1]*2*shift); % imtranslate(-Img, [-1 1]*6);
[yc, xc] = find(Tmp==imdilate(Tmp, strel('disk', a)));

% Regularization
xc = xc + shift;
yc = yc - shift;

% --- Average kernel

K = zeros(ks,ks);
for i = 1:numel(xc)
    K = K + this.F.getSub(1, xc(i), yc(i), ks);
end
K = K/numel(xc);

% --- Corner regularization

[X, Y] = meshgrid(1:ks, 1:ks);
M = 1-1./(1+1000*exp(-sqrt((X-ks/2).^2 + (Y-ks/2).^2)/2));
K = K.*M;

if this.verbose
    fprintf(' %.02f sec\n', toc);
end

% === Initial positions ===================================================

if this.verbose
    fprintf('  * Get initial positions ...');
    tic
end

% Normalized correlation
C = normxcorr2(K, Img);

% --- Positions (at integer locations)

I0 = find(C==imdilate(C, strel('disk', a)) & C>minCorr);

[y0, x0] = ind2sub(size(C), I0);
c0 = C(I0);

% Correction due to kernel size
x = x0 - a;
y = y0 - a;

if this.verbose
    fprintf(' %.02f sec\n', toc);
end

% === Define pilars =======================================================

this.P = struct('x', num2cell(x), 'y', num2cell(y), 'c0', num2cell(c0));

% === Display =============================================================

if display
    
    clf
    
    ax1 = axes;
    ax2 = axes;
    
    imagesc(Img, 'Parent', ax1);
    scatter(ax2, x, y, 30, 'o', 'MarkerFaceColor', 'flat', 'CData', c0);
    
    colormap(ax1, gray);
    colormap(ax2, jet);
    
    axis(ax1, [1 this.F.W 1 this.F.H], 'equal', 'xy', 'tight')
    axis(ax2, [1 this.F.W 1 this.F.H], 'equal', 'xy', 'tight', 'off')
    
    linkaxes([ax1,ax2])
    
    colorbar(ax2, 'Position', [0.93 0.18 0.03 0.65])
    caxis(ax2, [minCorr 1]);
    
    drawnow limitrate
    
end

end
