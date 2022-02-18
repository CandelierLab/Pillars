function Update(this, varargin)

% Check
if isempty(this.F), return; end

% --- Input element
elementToUpdate = 'all';
if numel(varargin) && ischar(varargin{end})
    elementToUpdate = varargin{end};
end

% Adapt to current view
switch this.layout.view.main.SelectedTab.Title

    case 'Events'   % === EVENTS TAB ======================================

        if ismember(elementToUpdate, {'image', 'all'})

            % --- Image ---------------------------------------------------

            % Initialization
            cla(this.axes.image)
            hold(this.axes.image, 'on')

            % Image
            h = imshow(this.image, Parent = this.axes.image);
            h.ButtonDownFcn = {@this.MouseInput, 'image'};

            % Pillars
            scatter(this.axes.image, this.pos.x, this.pos.y, 'w.', ...
                ButtonDownFcn={@this.MouseInput, 'image'})

            % Selected pillars
            if ~isempty(this.sel.traj)
                scatter(this.axes.image, ...
                    this.pos.x(this.sel.traj), ...
                    this.pos.y(this.sel.traj), ...
                    50, this.cm, ...
                    LineWidth=2, ...
                    ButtonDownFcn={@this.MouseInput, 'image'});
            end

            % Misc
            axis(this.axes.image, 'off', 'tight')

        end

        if ismember(elementToUpdate, {'trace', 'all'})

            % --- Trace ---------------------------------------------------

            if isempty(this.sel.traj)

                this.axes.trace.Visible = 'off';

            else

                % Initialization
                this.axes.trace.Visible = 'on';
                cla(this.axes.trace)
                hold(this.axes.trace, 'on')

                % --- Plot traces

                for i = 1:this.nSel.traj

                    % --- Definitions

                    k = this.sel.traj(i);
                    if this.use_rho
                        r = this.P(k).rho;
                    else
                        r = this.P(k).r;
                    end

                    % --- Plot

                    plot(this.axes.trace, i+r/max([15 ; r(:)]), '-', ...
                        color=this.cm(i,:), ...
                        LineWidth=0.1, ...
                        ButtonDownFcn={@this.MouseInput, 'trace'});

                    % --- Events

                    J = find([this.E(:).idx]==k);
                    for j = J
                        t1 = this.E(j).frames(1);
                        t2 = this.E(j).frames(end);
                        rectangle(this.axes.trace, ...
                            Position=[t1 i t2-t1 1], ...
                            FaceColor=[this.cm(i,:) 0.3], ...
                            EdgeColor='w', ...
                            ButtonDownFcn={@this.MouseInput, 'trace'});
                    end

                end

                % --- Ticks & limits

                this.axes.trace.YTick = (1:this.nSel.traj);
                this.axes.trace.YTickLabel = this.sel.traj;

                if this.use_rho
                    ylim(this.axes.trace, [0.5 this.nSel.traj+1]);
                else
                    ylim(this.axes.trace, [1 this.nSel.traj+1]);
                end

                % Misc
                box(this.axes.trace, 'on')
                xlabel(this.axes.trace, 't')

            end

        end

        if ismember(elementToUpdate, {'event', 'all'})

            % --- Event ---------------------------------------------------

            cla(this.axes.event)

            if isempty(this.sel.event)

                this.axes.event.Visible = 'off';

            else

                this.axes.event.Visible = 'on';
                hold(this.axes.event, 'on')

                % --- Definitions

                Ev = this.E(this.sel.event);

                if isnan(Ev.tau), Ev.tau = 0; end

                if this.use_rho
                    r = this.P(Ev.idx).rho;
                else
                    r = this.P(Ev.idx).r;
                end

                It = find(this.sel.traj==Ev.idx);

                % --- Plot event

                I = [Ev.frames(1)+(-this.eventMargin:-1) Ev.frames Ev.frames(end)+(1:this.eventMargin)];
                I(I<1 | I>numel(r)) = [];

                plot(this.axes.event, I, r(I), ':', color=this.cm(It,:));
                plot(this.axes.event, Ev.frames, r(Ev.frames), '-', ...
                    color=this.cm(It,:), LineWidth=1.5)
                scatter(this.axes.event, Ev.frames, r(Ev.frames), 300, '.', ...
                    MarkerEdgeColor=this.cm(It,:))

                % --- Plot fit

                x = Ev.frames(1) + linspace(-this.eventMargin, Ev.n-1+this.eventMargin, 200);
                y = Analysis.Detector.model(x, Ev.t0, Ev.s, Ev.A, Ev.tau, Ev.sat);
                plot(this.axes.event, x, y, 'k-');

                title(this.axes.event, ...
                    ['traj ' num2str(Ev.idx) ...
                    ' - event ' num2str(this.sel.event) ...
                    ' - skew=' num2str(Ev.skew,'%.02f') ...
                    ' - se=' num2str(Ev.se,'%.02f')])

                box(this.axes.event, 'on')

                xlabel(this.axes.event, 't')
                if this.use_rho
                    ylabel(this.axes.event, '\rho')

                    xL = xlim(this.axes.event);
                    rectangle(this.axes.event, ...
                        Position=[xL(1) 0 diff(xL) this.th_rho], ...
                        FaceColor=[[1 1 1]*0.9 0.25], ...
                        EdgeColor='none');

                else
                    ylabel(this.axes.event, 'r');
                end

            end

        end

    case 'Filters'   % === FILTERS TAB ====================================

        if ismember(elementToUpdate, {'mdplot', 'all'})

            % Reset plot
            cla(this.axes.mdplot);
            hold(this.axes.mdplot, 'on');
            
            % Index of selected rows
            if numel(this.fSel)
                rI = unique(this.fSel(:,1));
            else
                rI = [];
            end

            % Function handles
            rowName = @(i) this.table.filters.RowName{rI(i)};
            elm = @(i,j) this.table.filters.Data(rI(i),j).Variables;

            switch numel(rI)

                case 0

                    this.axes.mdplot.Visible = 'off';

                case 1

                    this.axes.mdplot.Visible = 'on';

                    % Colors
                    cm = lines(2);

                    % Get events feature
                    u = this.getEventsFeature(rowName(1));
                    v = u(this.sub);

                    % --- Special cases

                    % Log
                    if elm(1,8)
                        u(u<=0) = [];
                        v(v<=0) = [];
                    end

                    % Misc cases
                    switch rowName(1)
                        case 'Saturation duration'
                            support = 'positive';
                            u(u<=0) = [];
                            v(v<=0) = [];
                            pts = linspace(0, max(u), 200);
                        case 'Number of points'
                            support = 'positive';
                            pts = min(u):max(u);
                        otherwise
                            support = 'unbounded';
                            pts = linspace(min(u), max(u), 200);
                    end

                    d = mean(diff(pts));
                    edges = [pts-d/2 pts(end)+d/2];

                    % --- Marginal quantities

                    if this.disp.marg

                        % Histogram
                        histogram(this.axes.mdplot, u, edges, ...
                            FaceColor=cm(1,:), ...
                            EdgeColor=cm(1,:), ...
                            FaceAlpha=0.15, ...
                            EdgeAlpha=0.35, ...
                            Normalization='pdf');

                        % Distribution
                        [pdf, bin] = ksdensity(u, pts, Support=support);

                        % Correction for lower y limit
                        pdf(pdf<1/numel(u)) = 0;

                        % Plot
                        plot(this.axes.mdplot, bin, pdf, '.-', ...
                            Color=cm(1,:));

                    end

                    % --- Filtered quantities

                    if this.disp.filt

                        % Histogram
                        histogram(this.axes.mdplot, v, edges, ...
                            FaceColor=cm(2,:), ...
                            EdgeColor=cm(2,:), ...
                            FaceAlpha=0.15, ...
                            EdgeAlpha=0.35, ...
                            Normalization='pdf');

                        % Distribution
                        [pdf, bin] = ksdensity(v, pts, Support=support);

                        % Correction for lower y limit
                        pdf(pdf<1/numel(u)) = 0;

                        % Plot
                        plot(this.axes.mdplot, bin, pdf, '.-', ...
                            Color=cm(2,:));

                    end

                    % --- Log axes

                    if elm(1,8)
                        set(this.axes.mdplot, 'XScale', 'log');
                    else
                        set(this.axes.mdplot, 'XScale', 'lin');
                    end

                    if elm(1,9)
                        set(this.axes.mdplot, 'YScale', 'log');
                    else
                        set(this.axes.mdplot, 'YScale', 'lin');
                    end
            
                    % --- Misc settings

                    axis(this.axes.mdplot, 'normal');

                    colorbar(this.axes.mdplot, 'off');
                    view(this.axes.mdplot, 0, 90);

                    xlabel(this.axes.mdplot,rowName(1));
                    ylabel(this.axes.mdplot, 'pdf');

                    box(this.axes.mdplot, 'on');
                    grid(this.axes.mdplot, 'on');

                case 2

                    this.axes.mdplot.Visible = 'on';
                    
                    if ~isempty(this.sub)

                        % Get events feature
                        v1 = getEventsFeature(this, rowName(1), this.sub);
                        v2 = getEventsFeature(this, rowName(2), this.sub);
                    
                        % Scatter plot
                        % scatter(this.axes.mdplot, v1, v2, Marker='.');

                        % Density plot
                        ksdensity(this.axes.mdplot,[v1(:) v2(:)]);
                        
                    end
                    
                    % Log scales

                    if elm(1,8)
                        set(this.axes.mdplot, 'XScale', 'log');
                    else
                        set(this.axes.mdplot, 'XScale', 'lin');
                    end
    
                    if elm(2,8)
                        set(this.axes.mdplot, 'YScale', 'log');
                    else
                        set(this.axes.mdplot, 'YScale', 'lin');
                    end
    
                    % --- Misc settings

                    shading(this.axes.mdplot, 'flat');
                    axis(this.axes.mdplot, 'square', 'tight');
                    
                    drawnow
                    colorbar(this.axes.mdplot);
                    
                    xlabel(this.axes.mdplot,rowName(1));
                    ylabel(this.axes.mdplot,rowName(2));

                    box(this.axes.mdplot, 'on');
                    % grid(this.axes.mdplot, 'on');

                case 3

                    this.axes.mdplot.Visible = 'on';
                    
                    if ~isempty(this.sub)

                        % Get events feature
                        u1 = getEventsFeature(this, rowName(1), this.sub);
                        u2 = getEventsFeature(this, rowName(2), this.sub);
                        u3 = getEventsFeature(this, rowName(3), this.sub);
                    
                        % Scatter plot
                        scatter3(this.axes.mdplot, u1, u2, u3, ...
                            Marker='.');

                    end
                    
                    % Log scales

                    if elm(1,8)
                        set(this.axes.mdplot, 'XScale', 'log');
                    else
                        set(this.axes.mdplot, 'XScale', 'lin');
                    end
    
                    if elm(2,8)
                        set(this.axes.mdplot, 'YScale', 'log');
                    else
                        set(this.axes.mdplot, 'YScale', 'lin');
                    end

                    if elm(3,8)
                        set(this.axes.mdplot, 'ZScale', 'log');
                    else
                        set(this.axes.mdplot, 'ZScale', 'lin');
                    end
    
                    % --- Misc settings

                    colorbar(this.axes.mdplot, 'off');
                    xlabel(this.axes.mdplot,rowName(1));
                    ylabel(this.axes.mdplot,rowName(2));
                    zlabel(this.axes.mdplot,rowName(3));

                    view(this.axes.mdplot, 45,20)

                    box(this.axes.mdplot, 'on');
                    grid(this.axes.mdplot, 'on');

                otherwise

                    this.axes.mdplot.Visible = 'off';

            end

%             fprintf('Update md-plot\n');

        end


    case 'Overlay'   % === OVERLAY TAB ====================================


end