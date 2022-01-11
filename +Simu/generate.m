function [Tr, GTr] = generate(varargin)

% === Input ===============================================================

p = inputParser;
p.addRequired('T', @isnumeric);
p.addParameter('sigma', 1, @isnumeric);
p.addParameter('tp', [], @isnumeric);
p.addParameter('np', NaN, @isnumeric);
p.addParameter('amp', 1, @isnumeric);
p.addParameter('slope', 1, @isnumeric);
p.addParameter('ang', [], @isnumeric);

p.parse(varargin{:});
T = p.Results.T;
sigma = p.Results.sigma;
tp = p.Results.tp;
np = p.Results.np;
amp = p.Results.amp;
slope = p.Results.slope;
ang = p.Results.ang;

% -------------------------------------------------------------------------

if isnan(np)
    np = numel(tp);
else
    tmp = linspace(0,T,np+2);
    tp = round(tmp(2:end-1));
end

if numel(amp)==1 && np>1
    amp = repmat(amp, [np 1]);
end

if numel(slope)==1 && np>1
    slope = repmat(slope, [np 1]);
end

if isempty(ang)
    ang = 2*pi*rand(np,1);
elseif numel(ang)==1 && np>1
    ang = repmat(ang, [np 1]);
end
    
% =========================================================================

Tr = struct();
GTr = {};

% --- Gaussian noise

Tr.x = sigma*randn(T,1);
Tr.y = sigma*randn(T,1);

% --- Pull events

for i = 1:np
    
    % Times
    I = tp(i)-round(amp(i)/slope(i))-1:tp(i);
    I(I<1) = [];
    
    % Ground truth
    GTr{end+1} = I(2:end);
    
    % Radial amplitude
    dr = linspace(0, amp(i), numel(I))';
    
    % Cartesian coordinates
    Tr.x(I) = Tr.x(I) + dr*cos(ang(i));
    Tr.y(I) = Tr.y(I) + dr*sin(ang(i));
    
end

% --- Gaussianization

Tr.r = sqrt(Tr.x.^2 + Tr.y.^2);
Tr.rho = sqrt(2)*erfinv(2*gammainc((Tr.r/sigma).^2/2, 1)-1);
