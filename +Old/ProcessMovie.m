function P = ProcessMovie(varargin)

% === Parameters ==========================================================

p = inputParser;
p.addRequired('fMovie', @ischar);
p.addParameter('ps', 20, @isnumeric);           % Pilar size
p.addParameter('ks', 25, @isnumeric);           % Kernel size
p.addParameter('verbose', false, @islogical);   % Verbose
p.parse(varargin{:});
   
fMovie = p.Results.fMovie; 
ps = p.Results.ps; 
ks = p.Results.ks; 
verbose = p.Results.verbose; 

% =========================================================================

% --- Preparation

VR = VideoReader(fMovie);

% --- Detection

if verbose
    fprintf('Processing movie ');
    tic
end

P = NaN(0,3);

for t = 1:VR.NumFrames

    % Read frame
    Tmp = read(VR, t);
    Frame = Tmp(:,:,1);

    % Process frame
    [x, y] = ProcessFrame(Frame, 'ps', ps, 'ks', ks, 'show', false);

    % Concatenation
    P = [P ; t*ones(numel(x),1) x y];
    
    % Verbose
    if verbose && ~mod(t,200)
        fprintf('.');
    end
    
end

if verbose
    fprintf(' %.02f sec\n', toc);
    tic
end
