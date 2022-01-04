function assemble(this, varargin)
%Tracker.assemble Assemble trajectories
%
%   method can be:
%   * 'NN', 'direct'        Nearest neighbor
%   * 'KM', 'optimal'       The Kuhn-Munkres algorithm (optimal, slow)
%   * 'JV', 'fast'          The Jonker-Volgenant algorithm (suboptimal, fast)

% === Input ===============================================================

p = inputParser;
addParameter(p, 'method', 'fast', @ischar);
addParameter(p, 'max', Inf, @isnumeric);
addParameter(p, 'soft', 'linear', @ischar);
addParameter(p, 'norm', 0, @isnumeric);
addParameter(p, 'verbose', true, @islogical);
parse(p, varargin{:});

method = p.Results.method;
verbose = p.Results.verbose;

% === Assembly property ===================================================

this.assembly(1).hard = struct('max', p.Results.max);
this.assembly(1).soft = struct('method', p.Results.soft, 'norm', p.Results.norm);

% === Process =============================================================

% --- Checks

if ~this.iter
    return
end
    
if verbose
    fprintf('Assembly ...');
    tic
end

% --- Cost matrix ---------------------------------------------------------

% --- Edges of trajectories

e1 = struct();
e2 = struct();

for i = 1:numel(this.traj)

    e1.id(i,1) = i;
    e2.id(i,1) = i;
    
    e1.t(i,1) = this.traj(i).t(end);
    e2.t(i,1) = this.traj(i).t(1);
    
    for k = 1:this.nparam
        e1.(this.param(k).name)(i,:) = this.traj(i).(this.param(k).name)(end,:);
        e2.(this.param(k).name)(i,:) = this.traj(i).(this.param(k).name)(1,:);
    end
        
end

n1 = numel(this.traj);
n2 = numel(this.traj);

% --- Parameters Cost Matrix ----------------------------------------------

ai = find([this.param(:).active]);
nai = numel(ai);

PCM = cell(nai+1,1);

for i = 1:nai
    
    PCM{i} = Inf(n1, n2);
    
    % --- Distances
    
    D2 = zeros(n1, n2);
    v1 = e1.(this.param(ai(i)).name);
    v2 = e2.(this.param(ai(i)).name);
    for k = 1:size(v1,2)
        [V2, V1] = meshgrid(v2(:,k), v1(:,k));
        D2 = D2 + mod(abs(V2-V1), this.param(ai(i)).periodicity).^2;
    end
    D = sqrt(D2);
    
    % --- Hard cost
    
    switch this.param(ai(i)).hard.method
        
        case 'metric'
            
            Mask = D<=this.param(ai(i)).hard.max;
            
        case 'topologic'
            
            Mask = zeros(n1, n2);
            
            for k = 1:n1
                
                V = v2 - v1(k,:);
                W = V./(sum(V.^2,2)*[1 1]);
                
                I0 = all(V==0,2);
                Mask(k, I0) = 1;
                W(I0,:) = 0;
                
                Mask(k,unique(convhull(W))) = 1;
                
            end
            
            Mask = Mask & D<=this.param(ai(i)).hard.max;
            
    end
    
    Idx = find(Mask);
    
    % --- Soft cost
    
    switch this.param(ai(i)).soft.method
        
        case 'linear'
            PCM{i}(Idx) = D(Idx)/this.param(ai(i)).soft.norm;
            
        case 'quadratic'
            PCM{i}(Idx) = D2(Idx)/this.param(ai(i)).soft.norm;
            
    end
    
end

% --- Temporal Cost Matrix ------------------------------------------------

PCM{end} = Inf(n1, n2);

% --- Distances
    
[V2, V1] = meshgrid(e2.t, e1.t);
D = V2-V1;

% --- Hard cost

Idx = find(D>0 & D<=this.assembly.hard.max);

% --- Soft cost

switch this.assembly.soft.method
    
    case 'linear'
        PCM{end}(Idx) = D(Idx)/this.assembly.soft.norm;
        
    case 'quadratic'
        PCM{end}(Idx) = (D(Idx).^2)/this.assembly.soft.norm;
        
end

% --- Global Cost Matrix ---------------------------------------------

switch this.aggregation
    
    case 'addition'
        CM = sum(cat(3, PCM{:}),3);
        
end

% --- Assignement -----------------------------------------------------

switch method
    
    case {'NN', 'direct'}
        
        % Nearest neighbor
        
        A = NaN(0,2);
        
        while any(isfinite(CM(:)))
            
            [~, mi] = min(CM(:));
            [i,j] = ind2sub([n1 n2], mi);
            A(end+1,:) = [i j];
            
            CM(i,:) = Inf;
            CM(:,j) = Inf;
            
        end
        
    case {'KM', 'optimal'}
        
        % Kuhn-Munkres algorithm
        cna = max(CM(isfinite(CM)))+1;
        A = assignmunkres(CM, cna);
        
    case {'JV', 'fast'}
        
        % Jonker-Volgener algorithm
        cna = max(CM(isfinite(CM)))+1;
        A = assignjv(CM, cna);
        
end

% --- Assembly ------------------------------------------------------------

A = sortrows(A, 'descend');

% --- Merge

F = fieldnames(this.traj);

for i = 1:size(A,1)

    for k = 1:numel(F)
        this.traj(A(i,1)).(F{k}) = [this.traj(A(i,1)).(F{k}) ; this.traj(A(i,2)).(F{k})];
    end

end

% ---Remove

this.traj(A(:,2)) = [];

if verbose
    fprintf(' %.02f sec\n', toc);
end
