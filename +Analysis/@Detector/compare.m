function [me, fp] = compare(this, varargin)

% --- Input ---------------------------------------------------------------

p = inputParser;
p.addRequired('GroundTruth', @iscell);                  % Ground truth
p.addParameter('minOverlap', 0.5, @isnumeric);          % Minimal overlap
p.parse(varargin{:});

GTr = p.Results.GroundTruth;
minOverlap = p.Results.minOverlap;

% -------------------------------------------------------------------------

% --- Loop over detected events

b = false(numel(this.Ev), 1);
d = false(numel(GTr), 1);

for i = 1:numel(this.Ev)
    
    % Compare with ground truth
    n = cellfun(@(x) sum(ismember(x, this.Ev{i})), GTr);
    I = find(n, 1, 'first');
    
    if ~isempty(I) && n(I)/min(numel(this.Ev{i}), numel(GTr{I}))>minOverlap
        b(i) = true;        
        d(I) = true;
    end
    
end

% --- Output

me = nnz(~d);
fp = nnz(~b);
