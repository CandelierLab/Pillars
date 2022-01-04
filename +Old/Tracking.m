function Tr = Tracking(varargin)

% === Parameters ==========================================================

p = inputParser;
p.addRequired('P', @isnumeric);
p.addParameter('verbose', false, @islogical);   % Verbose
p.parse(varargin{:});
   
P = p.Results.P; 
verbose = p.Results.verbose; 

% =========================================================================

% --- Initialization

T = max(P(:,1));

Tr = IP.Tracker;
Tr.parameter('position', 'max', 10, 'norm', 1);

% --- Tracking

if verbose
    fprintf('Tracking ');
end

for t = 1:T

    I = P(:,1)==t;
    
    Tr.set('position', P(I, 2:3));
    Tr.match('method', 'fast');
    
    if verbose && ~mod(t,200)
        fprintf('.'); 
    end
    
end

if verbose
    fprintf(' %.02f sec\n', toc);
end

% --- Assemble

% Pre-filtering
Tr.filter('numel', [3 Inf]);

Tr.assemble('method', 'fast', 'max', 50, 'norm', 1);

% --- Filtering

Tr.filter('numel', [20 Inf], 'extent', [0 Inf]);