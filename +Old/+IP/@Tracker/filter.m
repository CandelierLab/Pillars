function I = filter(this, varargin)
%Tracker.filter Filters trajectories
%

% === Input ===============================================================

p = inputParser;
addParameter(p, 'numel', [], @isnumeric);
addParameter(p, 'length', [], @isnumeric);
addParameter(p, 'extent', [], @isnumeric);
parse(p, varargin{:});

fnumel = p.Results.numel;
flength = p.Results.length;
fextent = p.Results.extent;

% =========================================================================

Ikeep = true(numel(this.traj),1);

% --- Number of elements

if ~isempty(fnumel)
    
    this.filters.numel = fnumel;
    
    n = arrayfun(@(x) numel(x.t), this.traj);
    
    Ikeep(n<fnumel(1)) = false;
    Ikeep(n>fnumel(2)) = false;
    
end

% --- Trajectory length

if ~isempty(flength)
    
    this.filters.length = flength;
    
    L = arrayfun(@(T) sum(sqrt(sum(diff(T.position,1,1).^2,2))), this.traj);
    
    Ikeep(L<flength(1)) = false;
    Ikeep(L>flength(2)) = false;
    
end

% --- Trajectory extent

if ~isempty(fextent)
    
    this.filters.extent = fextent;
    
    L = NaN(numel(this.traj),1);
    for i = 1:numel(this.traj)
        try
            L(i) = max(pdist(this.traj(i).position));
        catch
            this.traj(i).position
        end
    end
    
    Ikeep(L<fextent(1)) = false;
    Ikeep(L>fextent(2)) = false;
    
end


% --- Output --------------------------------------------------------------

if ~nargout
    
    this.traj = this.traj(Ikeep);
    
end