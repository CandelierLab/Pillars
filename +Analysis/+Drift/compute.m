function compute(F, varargin)

if F.verbose
    fprintf('--- Drift\n');
end

% === Input ===============================================================

p = inputParser;
p.addParameter('display', false, @islogical);   % driftisplay the result
p.parse(varargin{:});

display = p.Results.display;


% === Computation =====================================================

% --- Reference frame

Ref = F.mmap.Data(1).frame;
fRef = fft2(Ref);

% --- Initialization

[X, Y] = meshgrid(1:F.W, 1:F.H);
drift = struct('x', NaN(F.T,1), 'y', NaN(F.T,1));

if F.verbose
    fprintf('  * Computing .');
    tic
end

for t = 1:F.T
    
    % Get frame
    Frame = F.mmap.Data(t).frame;
    
    % Perform correlation in Fourrier space
    Res = ifftshift(ifft2(fRef.*conj(fft2(Frame))));
    
    % --- Find peak
    
    % Trim result
    w = 20;
    Res(:,1:F.W/2-w) = 0;
    Res(:,F.W/2+w:end) = 0;
    Res(1:F.H/2-w,:) = 0;
    Res(F.H/2+w:end,:) = 0;
    
    % Filter values
    Z = sort(Res(Res(:)>0), 'descend');
    Res(Res < Z(200)) = 0;
    Res = Res - min(Res(Res(:)>0));
    
    % Get peak position
    I = Res>=0;
    drift.x(t) = F.W/2 + 1 - sum(X(I).*Res(I))./sum(Res(I));
    drift.y(t) = F.H/2 + 1 - sum(Y(I).*Res(I))./sum(Res(I));
    
    if F.verbose & ~mod(t, 100), fprintf('.'); end
    
end

if F.verbose
    fprintf(' %.02f sec\n', toc);
end

% === Save ================================================================

save(F.File.drift, 'drift');

% === Display =============================================================

if display
    
    clf
    hold on
    
    plot(drift.x, drift.y, '.-')
    
    axis equal
    grid on
    box on
    
    xlabel('x (pix)');
    ylabel('y (pix)');
    title(['Drift for ' F.tag]);
    
    
    drawnow limitrate
    
end

