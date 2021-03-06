classdef Selector < handle
    %Selector | A class for selecting pillars to keep
    
    % // Manage NaNs in traj !
    %   - Display in text
    %   - Force unchecked
    %
    
    % === PROPERTIES ======================================================
    
    properties
        
        % Focus
        F
        
        % Backgroud image
        Img
        
        % Pilar structure
        P
        
        % Number of pilars
        N
        
        % Initial positions
        X0
        Y0      
        
        % Baseline window size
        bws = 80;

        % Conversion and thresholds
        sigma
        th_r
        th_rho
        
        % --- Internal states
        
        Cursor = struct();
        zoom = struct('Image', struct('active', false, 'size', 300, 'pos', NaN(1,2)), ...
            'Trace', struct('active', false, 'size', 200, 'pos', NaN));
        mode = struct('baseline', false, 'kernel', false);
        current = 1;
        
        mouseModifier = '';
        
        % --- Display properties
        
        Fig
        Axes = struct();
        Text
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Selector(F, arg)
                        
            arguments
                F
                arg.th_rho double = 4.77
            end

            clc

            % --- Input
            
            % Focus
            this.F = F;

            % Threshold
            this.th_rho = arg.th_rho;
            this.th_r = sqrt(2*gammaincinv((-erf(this.th_rho/sqrt(2))+1)/2,1,'upper'));
                        
            % --- Trajectories
            
            Tmp = load(F.File.trajectories);
            this.P = Tmp.P;
            this.N = numel(this.P);
                        
            this.X0 = arrayfun(@(p) p.fx(1), this.P);
            this.Y0 = arrayfun(@(p) p.fy(1), this.P);
            
            % Noise dispersion
            this.sigma = nanmean((this.P(1).fx-this.P(1).bx)./this.P(1).x);

            % --- Initial checks ------------------------------------------
                        
            % --- Checked status
            
            if ~isfield(this.P, 'checked')
                tmp = num2cell(true(this.N,1));
                [this.P(:).checked] = tmp{:};
            end
            
            % --- Display -------------------------------------------------
                        
            % --- Figure
            
            this.Fig = figure('Name', 'Selector', 'Menu', 'none', 'ToolBar', 'none');
            this.Fig.WindowState = 'maximized';            
            this.Fig.Color = [0 0 0];
            this.Fig.KeyPressFcn = @this.KeyPress;
            this.Fig.WindowButtonMotionFcn = @this.MouseMove;
            drawnow
                        
            % --- Axes
            
            this.Axes.Image = axes();
            this.Axes.Image.OuterPosition = [0 0.25 0.6 0.75];
            this.Axes.Image.Color = 'k';
            this.Axes.Image.XColor = 'w';
            this.Axes.Image.YColor = 'w';
            box(this.Axes.Image, 'on')
            hold(this.Axes.Image, 'on')
            this.Axes.Image.ButtonDownFcn = @this.MouseInput;

            this.Axes.XY = axes();
            this.Axes.XY.OuterPosition = [0.6 0.25 0.4 0.75];
            this.Axes.XY.Color = 'k';
            this.Axes.XY.XColor = 'w';
            this.Axes.XY.YColor = 'w';
            hold(this.Axes.XY, 'on')
            this.Axes.XY.ButtonDownFcn = @this.MouseInput;
            
            this.Axes.Trace = axes();
            this.Axes.Trace.OuterPosition = [0.2 0 0.8 0.25];
            this.Axes.Trace.Color = 'k';
            this.Axes.Trace.XColor = 'w';
            this.Axes.Trace.YColor = 'w';
            box(this.Axes.Trace, 'on')
            hold(this.Axes.Trace, 'on')
            this.Axes.Trace.ButtonDownFcn = @this.MouseInput;
           
            % drawnow
            
            % --- Text
            
            this.Text = uicontrol('style', 'text', 'units', 'normalized','Max',2);
            this.Text.Position = [0.01 0.01 0.19 0.24];
            this.Text.HorizontalAlignment = 'Left';
            this.Text.BackgroundColor = 'k';
            this.Text.ForegroundColor = 'w';
            this.Text.FontSize = 10;
            
                
            % Default cursor
            F = fieldnames(this.Axes);
            for i = 1:numel(F)
                this.Cursor.(F{i}) = NaN(1,2);
            end
            this.Cursor.location = '';
            
            % Initalization
            this.Update();
            
        end
        
    end
end

