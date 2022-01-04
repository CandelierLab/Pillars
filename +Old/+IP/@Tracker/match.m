function match(this, varargin)
%Tracker.match Perform the matching and store the result
%
%   method can be:
%   * 'NN', 'direct'        Nearest neighbor
%   * 'KM', 'optimal'       The Kuhn-Munkres algorithm (optimal, slow)
%   * 'JV', 'fast'          The Jonker-Volgenant algorithm (suboptimal, fast)

% === Input ===============================================================

p = inputParser;
addParameter(p, 'method', 'optimal', @ischar);
addParameter(p, 'verbose', false, @islogical);
parse(p, varargin{:});

method = p.Results.method;
verbose = p.Results.verbose;

% === Process =============================================================

if verbose, tic, end

this.iter = this.iter+1;

% --- Heading

if verbose && this.iter==1
    
    fprintf('--- Tracking -----------------------------------------------------\n');
    
end

% --- Empty step ?

if isempty(this.values(2).(this.param(1).name))
    
    this.reset = true;
    this.lidx(~isnan(this.lidx)) = NaN;
    
    if verbose
        fprintf('  [%i] Empty step (%.02f sec)\n', this.iter, toc);
    end
    
    return
end

% --- Init & reset --------------------------------------------------------

if this.reset
    
    % Update reset status
    this.reset = false;
    
    % Trajectories
    B = {'t' this.iter};
    for i = 1:numel(this.param)
        B{end+1} = this.param(i).name;
        B{end+1} = num2cell(this.values(2).(this.param(i).name), 2);
    end
    ntraj = struct(B{:});
    
    if this.iter==1
        
        % First step
        this.traj = ntraj;
        nidx = (1:numel(this.traj))';
        
    else
        
        % Non-first steps
        this.traj
        ntraj
        this.traj = [this.traj ; ntraj];
        nidx = [this.lidx ; (1:numel(ntraj))'];
                
    end
    
else
    
    n1 = size(this.values(1).(this.param(1).name), 1);
    n2 = size(this.values(2).(this.param(1).name), 1);
    
    % --- Parameters Cost Matrix --------------------------------------
    
    % --- Active parameters
    
    ai = find([this.param(:).active]);
    nai = numel(ai);
    
    PCM = cell(nai,1);
    
    for i = 1:nai
        
        PCM{i} = Inf(n1, n2);
        
        % --- Distances
        
        D2 = zeros(n1, n2);
        v1 = this.values(1).(this.param(ai(i)).name);
        v2 = this.values(2).(this.param(ai(i)).name);
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
    
    % --- Global Cost Matrix ------------------------------------------
    
    switch this.aggregation
        
        case 'addition'
            CM = sum(cat(3, PCM{:}),3);
            
    end
    
    % --- Assignment --------------------------------------------------
    
    
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
            
            uRow = setdiff(1:n1, unique(A(:,1)));
            uCol = setdiff(1:n2, unique(A(:,2)));
            
        case {'KM', 'optimal'}
            
            % Kuhn-Munkres algorithm
            cna = max(CM(isfinite(CM)))+1;
            if ~isempty(cna)
                [A, uRow, uCol] = assignmunkres(CM, cna);
            else
                A = NaN(0,2);
                uRow = 1:size(CM,1);
                uCol = 1:size(CM,2);
            end
            
        case {'JV', 'fast'}
            
            % Jonker-Volgener algorithm
            cna = max(CM(isfinite(CM)))+1;
            if ~isempty (cna)
                [A, uRow, uCol] = assignjv(CM, cna);
            else
                A = NaN(0,2);
                uRow = 1:size(CM,1);
                uCol = 1:size(CM,2);
            end
            
    end
    
    % --- Trajectories ----------------------------------------------------
    
    % --- Update
    
    nidx = NaN(numel(this.traj),1);
    
    for u = 1:size(A,1)
        
        i = A(u,1);
        j = A(u,2);
        
        try
            this.traj(this.lidx==i).t(end+1,1) = this.iter;
        catch
            keyboard
        end
            
        for k = 1:this.nparam
            this.traj(this.lidx==i).(this.param(k).name)(end+1,:) = this.values(2).(this.param(k).name)(j,:);
        end
        
        nidx(this.lidx==i) = j;
    end
    
    % --- New trajectories
    
    nt = numel(this.traj);
    for u = 1:numel(uCol)
        
        j = uCol(u);
        nt = nt+1;
        
        this.traj(nt).t = this.iter;
        for k = 1:this.nparam
            this.traj(nt).(this.param(k).name)(1,:) = this.values(2).(this.param(k).name)(j,:);
        end
        
        nidx(nt) = j;
        
    end
    
end

% === Update ==========================================================

this.lidx = nidx;

this.values(1) = this.values(2);
for i = 1:numel(this.param)
    this.values(2).(this.param(i).name) = [];
end

if verbose
    fprintf('  [%i] %i terminated,\t%i started,\t%i trajs (%.02f sec)\n', this.iter, numel(uRow), numel(uCol), numel(this.traj), toc);
end
