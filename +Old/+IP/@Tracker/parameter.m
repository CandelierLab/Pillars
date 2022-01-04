function parameter(this, varargin)
%Tracker.parameter Adds a parameter
%
% Exemples:
%   Tr.parameters('prop', 'active', false)
%   Tr.parameters('position', 'hard', d, 'soft', norm_fact);
%   Tr.parameters('position', 'hard', 'n1', 'soft', norm_fact);

% === Input ===============================================================

p = inputParser;
addRequired(p, 'name', @ischar);
addParameter(p, 'active', true, @islogical);
addParameter(p, 'hard', 'metric', @ischar);
addParameter(p, 'max', Inf, @isnumeric);
addParameter(p, 'soft', 'linear', @ischar);
addParameter(p, 'norm', 1, @isnumeric);
addParameter(p, 'periodicity', Inf, @isnumeric);
parse(p, varargin{:});

% =========================================================================

this.nparam = this.nparam+1;
this.param(this.nparam).name = p.Results.name;
this.param(this.nparam).active = p.Results.active;
this.param(this.nparam).periodicity = p.Results.periodicity;

% --- Hard cost

switch p.Results.hard
    case 'metric'
        this.param(this.nparam).hard = struct('method', 'metric', ...
            'max', p.Results.max);
    case 'n1'
        this.param(this.nparam).hard = struct('method', 'topologic', ...
            'nnei', 1, 'max', p.Results.max);
    case 'n2'
        this.param(this.nparam).hard = struct('method', 'topologic', ...
            'nnei', 2, 'max', p.Results.max);
end

% --- Soft cost

this.param(this.nparam).soft = struct('method', p.Results.soft, ...
    'norm', p.Results.norm);
