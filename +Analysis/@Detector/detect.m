function detect(this, varargin)

% --- Input ---------------------------------------------------------------

p = inputParser;
p.addRequired('Algorithm', @ischar);                    % Algorithm
p.addParameter('preprocess', [], @iscell);              % Preprocess
p.addParameter('th_n', NaN, @isnumeric);                % Threshold on n
p.addParameter('th_r', NaN, @isnumeric);                % Threshold on r
p.addParameter('verbose', this.verbose, @islogical);    % Verbose
p.parse(varargin{:});

Algo = p.Results.Algorithm;
PP = p.Results.preprocess;
th_n = p.Results.th_n;
th_r = p.Results.th_r;
verbose = p.Results.verbose;

% -------------------------------------------------------------------------

switch Algo
    
    case 'th_nr'
        
        % Threshold in R
        I = find(sqrt(this.Tr.x.^2 + this.Tr.y.^2) >= th_r);
        
        % Group
        Gi = [1 ; 1+cumsum(diff(I)>1)];
        G = splitapply(@(x){x}, I, Gi);
        
        % Threshold in n
        nG = cellfun(@numel, G);
        this.Ev = G(nG>=th_n);
        
end