function set(this, varargin)
%Tracker.set Set values
%

% === Input ===============================================================

p = inputParser;
addRequired(p, 'name', @ischar);
addRequired(p, 'value', @(x) isnumeric(x) || iscell(x));
parse(p, varargin{:});

name = p.Results.name;
value = p.Results.value;

% =========================================================================

if ~isfield(this.values, name)
    this.values(1).(name) = NaN;
end

this.values(2).(name) = value;
