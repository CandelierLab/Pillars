function E = detect(this, arg)

arguments
    this
    arg.algorithm char = 'th_rho'
    arg.threshold double = 4.77
    arg.verbose logical = this.verbose
end

% --- DETECTION -----------------------------------------------------------

fields = {'idx','n','frames', 'r', 'rho', 'skew', 't0', 's', 'A', 'sat', 'tau', 'se'};
this.E = cell2struct(cell(numel(fields),1), fields);

k = 0;

switch arg.algorithm

    case 'th_rho'

        if arg.verbose
            fprintf('Detection ');
            tic
            itp = round(numel(this.P)/10);
        end

        % --- Parameters

        % Threshold
        T = numel(this.P(1).rho);

        % --- Loop over pillars

        for i = 1:numel(this.P)

            % Threshold
            I = find(this.P(i).rho' >= arg.threshold);

            if isempty(I)
                continue;
            end

            % Group
            Gi = [1 ; 1+cumsum(diff(I)>1)];
            G = splitapply(@(x){x}, I, Gi);

            % Store
            for j = 1:numel(G)

                % Remove beginning and ending
                if any(G{j}==1) || any(G{j}==T)
                    continue
                end

                I = [G{j}(1)-1 G{j}' G{j}(end)+1];

                % Extend before
                while I(1)>1 && this.P(i).rho(I(1)-1)>=0 && this.P(i).rho(I(1)-1)<this.P(i).rho(I(1))
                    I = [I(1)-1 I];
                end

                % Extend after
                while I(end)<T && this.P(i).rho(I(end)+1)>=0 && this.P(i).rho(I(end)+1)<this.P(i).rho(I(end))
                    I(end+1) = I(end)+1;
                end

                k = k+1;
                this.E(k).idx = i;
                this.E(k).n = numel(I);
                this.E(k).frames = I;
                this.E(k).r = this.P(i).r(I);
                this.E(k).rho = this.P(i).rho(I);

            end

            if arg.verbose && ~mod(i, itp)
                fprintf('.')
            end
        end

        if arg.verbose
            fprintf(' %.02f sec\n', toc);
        end

    case 'th_rho_smoothed'

        % --- Parameters

        % Smooth window size
        sws = 3;

        % Threshold
        th_rho = 2.75;

        T = numel(this.P(1).rho);

        % --- Loop over pillars

        for i = 1:numel(this.P)

            % Smooth
            rho = smooth(this.P(i).rho, sws);

            % Threshold
            I = find(rho >= th_rho);

            if isempty(I)
                continue;
            end

            % Group
            Gi = [1 ; 1+cumsum(diff(I)>1)];
            G = splitapply(@(x){x}, I, Gi);

            % Store
            for j = 1:numel(G)

                % Remove beginning and ending
                if any(G{j}==1) || any(G{j}==T)
                    continue
                end

                I = [G{j}(1)-1 G{j}' G{j}(end)+1];

                % Check max position
                [~, mi] = max(this.P(i).rho(I));
                if mi==1 || mi==numel(I)
                    continue
                end

                k = k+1;
                E(k).idx = i;
                E(k).frames = I;
                E(k).x = this.P(i).x(I);
                E(k).y = this.P(i).y(I);
                E(k).r = this.P(i).r(I);
                E(k).rho = this.P(i).rho(I);

            end

        end

end