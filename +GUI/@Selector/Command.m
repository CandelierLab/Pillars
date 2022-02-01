function Command(this, command)

switch command
    
    % --- SELECT CURRENT PILAR --------------------------------------------
    
    case 'leftclick'
        
        switch this.Cursor.location

            case 'Image'
                
                % Set nearest pilar as current
                [~, this.current] = min((this.Cursor.Image(1) - this.X0).^2 + (this.Cursor.Image(2) - this.Y0).^2);
                
                % Reset zoom state
                this.zoom.Trace.active = false;
                
                % Update figure
                this.Update
                
        end     
    
    % --- TOGGLE ZOOM -----------------------------------------------------
    
    case {'middleclick', 'z'}
    
        switch this.Cursor.location

            case 'Image'
                
                % Set zoom center point
                this.zoom.Image.pos = this.Cursor.Image;
                
                % Set zoom sate
                this.zoom.Image.active = ~this.zoom.Image.active;
                
                % Update figure
                this.Update
               
            case 'Trace'
                
                % Set zoom center point
                this.zoom.Trace.pos = this.Cursor.Trace(1);
                
                % Set zoom sate
                this.zoom.Trace.active = ~this.zoom.Trace.active;
                
                % Update figure
                this.Update
                
        end     
        
        
    case 'rightclick'
    
        switch this.Cursor.location

            case 'Image'
                
                % Get nearest pilar
                [~, i] = min((this.Cursor.Image(1) - this.X0).^2 + (this.Cursor.Image(2) - this.Y0).^2);
                
                % Toggle selection
                this.P(i).checked = ~this.P(i).checked;
                
                % Update figure
                this.Update
                
            otherwise
                
                % Toggle current pilar' selection
                this.P(this.current).checked = ~this.P(this.current).checked;
                
                % Update figure
                this.Update
        end     
        
    
        
    case 'escape'
        
        % --- Print state info
        
        fprintf('--- Selector last state\n');
        fprintf('Current pilar = %i\n\n', this.current);
        
        close(this.Fig);
        return
        
    % --- TOGGLE BASELINE VIEW --------------------------------------------
        
    case 'b'
        
        % Toggle baseline view
        this.mode.baseline = ~this.mode.baseline;
        
        % Update view
        this.Update;
        
    % --- TOGGLE KERNEL VIEW ----------------------------------------------
        
    case 'k'
        
        % Toggle baseline view
        this.mode.kernel = ~this.mode.kernel;
        
        % Update view
        this.Update;
        
    % --- POLYGONAL SELECTION ---------------------------------------------
        
    case 'p'
        
        switch this.Cursor.location

            case 'Image'
                
                % Get polygonal ROI
                p = drawpolygon(this.Axes.Image);
                
                for i = find(inpolygon(this.X0, this.Y0, p.Position(:,1), p.Position(:,2)))'
                    this.P(i).checked = ~this.P(i).checked;
                end

            case 'XY'
                
                if this.mode.kernel
                
                    % Get polygonal ROI
                    p = drawpolygon(this.Axes.XY);
                    
                    % Kernel size
                    ks = size(this.P(this.current).K, 1);
                    
                    % Sub
                    Sub = this.F.getSub(1, round(this.X0(this.current)), round(this.Y0(this.current)), ks);
                    
                    [X, Y] = meshgrid(1:ks, 1:ks);
                    Sub(~inpolygon(X(:), Y(:), p.Position(:,1), p.Position(:,2))) = 0;
                    
                    this.P(this.current).K = Sub;
                    
                end
                                
        end
                
        % Update view
        this.Update;
       
    % --- RECOMPUTE TRAJECTORY --------------------------------------------
        
    case 'r'
        
        % Get sigma_x
        sigma_x = nanmean((this.P(this.current).fx-this.P(this.current).bx)./this.P(this.current).x);

        % Define pTracker
        Tr = IP.pTracker(this.F, 'verbose', false);
        Tr.P = this.P;
        
        % Set inital position to nearest integer
        Tr.P(this.current).x = round(Tr.P(this.current).fx);
        Tr.P(this.current).y = round(Tr.P(this.current).fy);
        
        % Track_once
        p = Tr.track_one(this.current, 'waitbar', true);

        % --- Update fields

        % Frame position
        this.P(this.current).fx = p.x;
        this.P(this.current).fy = p.y;

        % Baseline
        this.P(this.current).bx = movmedian(this.P(this.current).fx, this.bws);
        this.P(this.current).by = movmedian(this.P(this.current).fy, this.bws);

        % Reduced coordinates
        this.P(this.current).x = (this.P(this.current).fx - this.P(this.current).bx)/sigma_x;
        this.P(this.current).y = (this.P(this.current).fy - this.P(this.current).by)/sigma_x;

        % Radial coordinates
        this.P(this.current).r = sqrt((this.P(this.current).fx - this.P(this.current).bx).^2 + (this.P(this.current).fy - this.P(this.current).by).^2);
        
        % Rho
        this.P(this.current).rho = sqrt(2)*erfinv(1-2*gammainc((this.P(this.current).r/sigma_x).^2/2, 1, 'upper'))+1/2;
        I = ~isfinite(this.P(this.current).rho);
        this.P(this.current).rho(I) = this.P(this.current).r(I)/sigma_x;

        % Reset view
        this.mode.kernel = false;
        
        % Update view
        this.Update;
        
    % --- SAVE ------------------------------------------------------------
        
    case 'control+s'
        
        P = this.P;
        save(this.F.File.trajectories, 'P');
        
        % Display
        S = this.Text.String;
        S{end+1} = '=== SAVED ===';
        this.Text.String = S;
        
end

end

