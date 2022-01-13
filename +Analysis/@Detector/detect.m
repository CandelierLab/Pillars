function detect(this, varargin)

% --- Input ---------------------------------------------------------------

p = inputParser;
p.addRequired('Algorithm', @ischar);                    % Algorithm
p.addParameter('preprocess', struct('type', ''), @isstruct);            % Preprocess
p.addParameter('th_n', NaN, @isnumeric);                % Threshold on n
p.addParameter('th_rho', NaN, @isnumeric);              % Threshold on rho
p.addParameter('verbose', this.verbose, @islogical);    % Verbose
p.parse(varargin{:});

Algo = p.Results.Algorithm;
PP = p.Results.preprocess;
th_n = p.Results.th_n;
th_rho = p.Results.th_rho;
verbose = p.Results.verbose;

% --- PRE-PROCESS ---------------------------------------------------------

switch PP.type
    
    case 'smooth'
        rho = smooth(this.Tr.rho, PP.WindowSize);
        
    otherwise
        rho = this.Tr.rho;
end

% --- DETECTION -----------------------------------------------------------

switch Algo
    
    case 'th_nrho'
        
        % Threshold in rho
        I = find(rho >= th_rho);
        
        % Group
        Gi = [1 ; 1+cumsum(diff(I)>1)];
        G = splitapply(@(x){x}, I, Gi);
        
        % Threshold in n
        nG = cellfun(@numel, G);
        this.Ev = G(nG>=th_n);
        
end