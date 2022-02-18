function Update(this, varargin)

% === Preparation =========================================================

% --- Check NaNs in traj

nN = nnz(isnan(this.P(this.current).fx));

if nN
    this.P(this.current).checked = false;
end

% --- Checked pilars

I = arrayfun(@(p) p.checked, this.P);

% --- Median trajectory

% xm = movmedian(this.P(this.current).x, this.wms);
% ym = movmedian(this.P(this.current).y, this.wms);

% --- Colors

% Blocks
cb = 50;
nb = ceil(this.F.T/cb);

cm = parula(nb);

% === Image ===============================================================

cla(this.Axes.Image)

% Backgroud image
imagesc(this.F.refFrame, 'Parent', this.Axes.Image, ...
    'ButtonDownFcn', @this.MouseInput);

% Selected
scatter(this.Axes.Image, this.X0(I), this.Y0(I), 'g+', ...
    'ButtonDownFcn', @this.MouseInput);

% Non-selected
scatter(this.Axes.Image, this.X0(~I), this.Y0(~I), 'rx', ...
    'ButtonDownFcn', @this.MouseInput);

% Current
scatter(this.Axes.Image, this.X0(this.current), this.Y0(this.current), 400, 's', ...
    'MarkerEdgeColor', 'w', 'ButtonDownFcn', @this.MouseInput);

colormap(this.Axes.Image, gray);
axis(this.Axes.Image, 'on', 'ij', 'equal', 'tight');
caxis(this.Axes.Image, 'auto');

% --- Zoom

if this.zoom.Image.active
    
    axis(this.Axes.Image, [this.zoom.Image.pos(1)+this.zoom.Image.size*[-1 1]/2 ...
        this.zoom.Image.pos(2)+this.zoom.Image.size*[-1 1]/2], 'square');
    
end

% === Trajectory ==========================================================

cla(this.Axes.XY)

if this.mode.kernel

    % Kernel size
    ks = size(this.P(1).K,1);

    % Mask
    Mask = (this.P(this.current).K~=0)*0.25+0.75;
    
    % Sub
    Sub = this.F.getSub(1, round(this.X0(this.current)), round(this.Y0(this.current)), ks);
    Sub = (Sub-min(Sub(:)))./(max(Sub(:))-min(Sub(:)))*255;
        
    % Image
    RGB = cat(3, uint8(Mask.*Sub), uint8(Sub), uint8(Sub));
    
    imagesc(RGB, 'parent', this.Axes.XY);

    axis(this.Axes.XY, 'off');
    caxis(this.Axes.XY, 'auto');
    
else
   
    hold(this.Axes.XY, 'on')
    
    if this.mode.baseline
    
        for i = 1:nb
        
            I = (i-1)*cb+1:min(i*cb+1, this.F.T);
            
            plot(this.Axes.XY, this.P(this.current).fx(I), this.P(this.current).fy(I), '-', ...
                'color', cm(i,:), 'ButtonDownFcn', @this.MouseInput);
            
        end
        
        plot(this.Axes.XY, this.P(this.current).fx, this.P(this.current).fy, 'w.', ...
            'ButtonDownFcn', @this.MouseInput);
        
        plot(this.Axes.XY, this.P(this.current).bx, this.P(this.current).by, 'r-', 'LineWidth', 1.5, ...
            'ButtonDownFcn', @this.MouseInput);
        
    else
        
        % --- Reduced trajectory

        for i = 1:nb
        
            I = (i-1)*cb+1:min(i*cb+1, this.F.T);
            
             plot(this.Axes.XY, this.P(this.current).fx(I) - this.P(this.current).bx(I), ...
                 this.P(this.current).by(I) - this.P(this.current).fy(I), ...
                 '-', 'color', cm(i,:), 'ButtonDownFcn', @this.MouseInput);
            
        end
        
        plot(this.Axes.XY, this.P(this.current).fx - this.P(this.current).bx, ...
            this.P(this.current).by - this.P(this.current).fy, ...
            'w.', 'ButtonDownFcn', @this.MouseInput);
        
        scatter(this.Axes.XY, 0, 0, 'ro', 'filled', ...
            'ButtonDownFcn', @this.MouseInput);
        
        % --- Event threshold

        theta = linspace(0, 2*pi, 200);
        r = this.th_r*this.sigma;

        plot(this.Axes.XY, r.*cos(theta), r.*sin(theta), 'r--');
    end
    
    axis(this.Axes.XY, 'on', 'equal');
    grid(this.Axes.XY, 'on');
    box(this.Axes.XY, 'on');
    
end

title(this.Axes.XY, ['\color{white} Pilar #' num2str(this.current, '%04i')]);

% === Trace ===============================================================

cla(this.Axes.Trace)
hold(this.Axes.Trace, 'on')

for i = 1:nb
    
    I = (i-1)*cb+1:min(i*cb+1, this.F.T);
    
    plot(this.Axes.Trace, I, this.P(this.current).rho(I), '-', 'color', cm(i,:), ...
        'ButtonDownFcn', @this.MouseInput);
    
end

% --- Dots

T = 1:this.F.T;
I = find(this.P(this.current).rho < this.th_rho);
J = find(this.P(this.current).rho >= this.th_rho);

h = plot(this.Axes.Trace, T(I), this.P(this.current).rho(I), '.', ...
    Color=[1 1 1]*0.75, ButtonDownFcn=@this.MouseInput);
uistack(h, 'bottom');

plot(this.Axes.Trace, T(J), this.P(this.current).rho(J), 'w.', ...
    ButtonDownFcn=@this.MouseInput);

% --- Zoom

if this.zoom.Trace.active
    xlim(this.Axes.Trace, this.zoom.Trace.pos+this.zoom.Trace.size*[-1 1]/2);
else
    xlim(this.Axes.Trace, [1 this.F.T]);
end

% --- Threshold

aL = axis(this.Axes.Trace);
r = rectangle(this.Axes.Trace, ...
    Position = [aL(1) aL(3) aL(2)-aL(1) this.th_rho-aL(3)], ...
    FaceColor = [[1 1 1]*0.5 0.35], ...
    EdgeColor = 'none', ...
    ButtonDownFcn=@this.MouseInput);
uistack(r, 'bottom');

ylabel(this.Axes.Trace, '\rho')

% --- Text ----------------------------------------------------------------

T = {};
T{1} = [num2str(nnz([this.P(:).checked])) ' pilars selected (out of ' num2str(this.N) ')'];
T{2} = ['Current pilar: ' num2str(this.current, '%04i') ' (' num2str(nN) ' NaNs)'];

this.Text.String = T;

drawnow limitrate