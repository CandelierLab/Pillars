classdef Filters < handle
    %Filters | A class for filtering events
    
    % === PROPERTIES ======================================================
    
    properties
        
        % --- Data
        F
        P
        E
        image
        pos

        % --- Global settings

        use_rho = true

        % Event selection
        nSel = struct('traj', 7)
        cm

        % Filter selection
        fSel
        sub

        % --- Constants

        nEv
        nFeat

        eventMargin = 5
        th_rho = 4.77
        th_r

        % --- States

        sel = struct('traj', [], 'event', []);
        disp = struct('marg', true, 'filt', true);

        % --- Display properties
        
        fig
        menu = struct()
        layout = struct()
        axes = struct()
        table = struct()
        html = struct()
        elms = struct();
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Filters(varargin)
            
            % Debug mode
            if nargin==3
                this.F = varargin{1};
                this.P = varargin{2};
                this.E = varargin{3};
                
                this.image = imread(this.F.File.refFrame);
                this.pos = struct('x', arrayfun(@(x) x.fx(1), this.P), ...
                    'y', arrayfun(@(x) x.fy(1), this.P));
            end

            close all
            clc
            
            % --- Constants

            this.th_r = sqrt(2*gammaincinv((-erf(this.th_rho/sqrt(2))+1)/2,1,'upper'));

            % --- Initialize figure

            this.fig = uifigure('HandleVisibility', 'on');
            this.fig.Name = "Filters";
            
            % Fullscreen
%             this.fig.Position = get(0,'ScreenSize');
            this.fig.Position = [0 100 1200 850];
            
            % Shortcuts
            this.fig.KeyPressFcn = @this.KeyPress;

            % --- MENUS ---------------------------------------------------

            % --- Data menu

            this.menu.data = uimenu(this.fig, 'Text','Data');

            L = Focus.taglist;
            for i = 1:numel(L)
                uimenu(this.menu.data, ...
                    Text = L{i}, ...
                    MenuSelectedFcn = {@this.setFocus, L{i}});
            end

            % Default focus
            if numel(L)
%                 this.setFocus([],[],L{1});
            end

            % --- Options

% % %             this.menu.options = struct('main', ...
% % %                 uimenu(this.fig, 'Text','Options'));
% % % 
% % %             this.menu.options.use_r = uimenu(this.menu.options.main, ...
% % %                 Text = 'Use r', ...
% % %                 MenuSelectedFcn = {@this.setOption, 'use_r'}, ...
% % %                 Checked = 'off');
% % % 
% % %             this.menu.options.use_rho = uimenu(this.menu.options.main, ...
% % %                 Text = 'Use rho', ...
% % %                 MenuSelectedFcn = {@this.setOption, 'use_rho'}, ...
% % %                 Checked = 'on');

            % --- MAIN TAB ------------------------------------------------

            this.layout.view = struct('main', ...
                uitabgroup(this.fig, ...
                Units='normalized', Position=[0 0 1 1], ...
                SelectionChangedFcn=@this.Update));

            this.layout.view.events = uitab(this.layout.view.main, ...
                Title = 'Events');

            this.layout.view.filters = uitab(this.layout.view.main, ...
                Title = 'Filters');

            % --- EVENTS VIEW ---------------------------------------------

            this.cm = lines(this.nSel.traj);

            % --- Layout

            this.layout.events = uigridlayout(this.layout.view.events);
            this.layout.events.RowHeight = {'1x','1x'};
            this.layout.events.ColumnWidth = {'1x','1x'};

            this.axes.image = uiaxes(this.layout.events);
            this.axes.image.Layout.Row = 1;
            this.axes.image.Layout.Column = 1;
            this.axes.image.Toolbar.Visible = 'off';
                       
            this.axes.trace = uiaxes(this.layout.events);
            this.axes.trace.Layout.Row = 2;
            this.axes.trace.Layout.Column = [1 2];            
            this.axes.trace.ButtonDownFcn = {@this.MouseInput, 'trace'};
            this.axes.trace.Visible = 'off';

            this.axes.event = uiaxes(this.layout.events);
            this.axes.event.Layout.Row = 1;
            this.axes.event.Layout.Column = 2;
            this.axes.event.Visible = 'off';

            % --- FILTERS VIEW --------------------------------------------

            % Main layout
            this.layout.filters = uigridlayout(this.layout.view.filters);
            this.layout.filters.RowHeight = {150, 75, '1x'};
            this.layout.filters.ColumnWidth = {'1x', 150};

            % Filters table
            this.table.filters = uitable(this.layout.filters);
            this.table.filters.Layout.Row = 1:2;
            this.table.filters.Layout.Column = 1;
            this.table.filters.SelectionChangedFcn = @this.selectFilter;
            this.table.filters.CellEditCallback = @this.setFilter;
            addStyle(this.table.filters, uistyle('HorizontalAlignment','center'));

            % Global selection
            this.html.global = uihtml(this.layout.filters);
            this.html.global.Layout.Row = 1;
            this.html.global.Layout.Column = 2;

            % --- Selection of distributions

            this.elms.dist = uibuttongroup(this.layout.filters, ...
                SelectionChangedFcn={@this.setOption, 'dist_pdf'});   
            this.elms.dist.Layout.Row = 2;
            this.elms.dist.Layout.Column = 2;

            this.elms.pdf_marg = uiradiobutton(this.elms.dist, ...
                Position=[10 50 90 15], ...
                Text='Marginal only');

            this.elms.pdf_filt = uiradiobutton(this.elms.dist, ...
                Position=[10 30 90 15], ...
                Text='Filtered only');

            this.elms.pdf_both = uiradiobutton(this.elms.dist, ...
                Position=[10 10 90 15], ...
                Text='Both', ...
                Value=true);


            % Multi-dimensional plot
            this.axes.mdplot = uiaxes(this.layout.filters);
            this.axes.mdplot.Layout.Row = 3;
            this.axes.mdplot.Layout.Column = 1:2;

            % --- Update content ------------------------------------------

            % --- Debug mode

            if ~isempty(this.F)
                this.fig.Name = ['Filters | ' this.F.tag];
                this.initFilters
                % this.layout.view.main.SelectedTab = this.layout.view.filters;
                this.Update;
            end

        end
        
    end
end

