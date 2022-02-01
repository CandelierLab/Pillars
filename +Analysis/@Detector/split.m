function split(this, arg)

arguments
    this
    arg.rotate logical = false
    arg.padLength = NaN
    arg.save char = ''
end

% --- Initialization

if arg.rotate
    this.Candidates = struct('Ipillar', {}, 'Itime', {}, ...
        'u', {}, 'v', {});
else
    this.Candidates = struct('Ipillar', {}, 'Itime', {}, ...
        'x', {}, 'y', {});
end

ii = 0;

for i = 1:numel(this.Tr)

    % Threshold in rho
    I = find(this.Tr(i).rho(:) > 0);

    % Group by indexes
    Gi = [1 ; 1+cumsum(diff(I)>1)];
    Idx = splitapply(@(x){x}, I, Gi);

    % Remove initial event
    if ismember(1, Idx{1})
        Idx(1) = [];
    end

    % Remove last event
    if ismember(numel(this.Tr.x), Idx{end})
        Idx(end) = [];
    end

    % Mandatory padding (1 before & 1 after)
    Idx = cellfun(@(x) [x(1)-1 ; x ; x(end)+1], Idx, 'UniformOutput', false);
    
    % Get sub traces
    x = cellfun(@(I) this.Tr(i).x(I), Idx, 'UniformOutput', false);
    y = cellfun(@(I) this.Tr(i).y(I), Idx, 'UniformOutput', false);
    % rho = cellfun(@(I) this.Tr(i).rho(I), Idx, 'UniformOutput', false);

    % --- Rotation

    if arg.rotate

        u = cell(size(x));
        v = cell(size(y));

        for k = 1:numel(x)
            X = sum(x{k}(2:end-1));
            Y = sum(y{k}(2:end-1));
            V = [X Y]/sqrt(X^2+Y^2);
            u{k} = x{k}*V(1) + y{k}*V(2);
            v{k} = -x{k}*V(2) + y{k}*V(1);
        end

    end

    % --- Padding

    if arg.padLength
        
        for k = 1:numel(x)

            if arg.rotate

                x{k}
                randn(arg.padLength-size(u{k},1),1)

                u{k} = [u{k} ; randn(arg.padLength-size(u{k},1),1)];
                v{k} = [v{k} ; randn(arg.padLength-size(v{k},1),1)];
            else
                x{k} = [x{k} ; randn(arg.padLength-size(x{k},1),1)];
                y{k} = [y{k} ; randn(arg.padLength-size(y{k},1),1)];
            end
        end
    
    end

    % --- Output

    for k = 1:numel(x)

        ii = ii + 1;

        this.Candidates(ii).Ipillar = i;
        this.Candidates(ii).Itime = Idx{k};

        if arg.rotate
            this.Candidates(ii).u = u{k};
            this.Candidates(ii).v = v{k};
        else
            this.Candidates(ii).x = x{k};
            this.Candidates(ii).y = y{k};
        end

    end

end