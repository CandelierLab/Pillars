function [x,y] = ProcessFrame(varargin)

% === Parameters ==========================================================

p = inputParser;
p.addRequired('Frame', @isnumeric);
p.addParameter('ps', 20, @isnumeric);           % Pilar size
p.addParameter('ks', 25, @isnumeric);           % Kernel size
p.addParameter('show', false, @islogical);      % Display the result
p.parse(varargin{:});

Frame = p.Results.Frame;
ps = p.Results.ps;
ks = p.Results.ks;
show = p.Results.show; 

% === Pre-processing ======================================================

% Smooth jpeg compression artifacts
Tmp = imgaussfilt(double(Frame), 1);

% Flatten background intensities
ML = medfilt2(Frame, [1 1]*100, 'symmetric');
Img = Tmp - imgaussfilt(double(ML), 5);

% === Kernel ==========================================================

% --- Candidate detection

Tmp = imtranslate(-Img, [-1 1]*6) + imtranslate(Img, [1 -1]*11);

[yc, xc] = find(Tmp==imdilate(Tmp, strel('disk', ps)));

% --- Rough kernel

K = zeros(ks,ks);
for i = 1:numel(xc)
    K = K + getSub(Img, xc(i), yc(i), ks);
end
K = K/numel(xc);

% --- Corner regularization

[X, Y] = meshgrid(1:ks, 1:ks);
M = 1-1./(1+1000*exp(-0.5*sqrt((X-ks/2).^2 + (Y-ks/2).^2)));
K = K.*M;

% === Correlation =====================================================

C = xcorr2(Img, K);

% --- Rough peaks (at integer locations)

[y0, x0] = find(C==imdilate(C, strel('disk', ps/2)) & C>max(C(:))/5);

% --- Parabolic fit

x = NaN(numel(x0),1);
y = NaN(numel(y0),1);

p = round(15);

for i = 1:numel(x0)
    
    x_ = max(1, x0(i)-p):min(x0(i)+p, size(C,2));
    y_ = max(1, y0(i)-p):min(y0(i)+p, size(C,1));
    
    [X, Y] = meshgrid(x_, y_);
    Z = C(y_,x_);
    Z(Z<max(Z(:)/2)) = 0;
    
    x(i) = sum(X(:).*Z(:))./sum(Z(:));
    y(i) = sum(Y(:).*Z(:))./sum(Z(:));
    
% % %     X = max(1, x0(i)-p):min(x0(i)+p, size(C,2));
% % %     Y = max(1, y0(i)-p):min(y0(i)+p, size(C,1));
% % %         
% % %     % --- X-interpolation
% % %         
% % %     % Fit
% % %     f = polyfit(X(:)-x0(i), sum(C(Y,X),1)', 2);
% % %     x(i) = x0(i) - f(2)/2/f(1);
% % %     
% % %     % --- Y-interpolation
% % %     
% % %     % Fit
% % %     f = polyfit(Y(:)-y0(i), sum(C(Y,X),2), 2);
% % %     y(i) = y0(i) - f(2)/2/f(1);
    
end

% Correction due to kernel size
x = x-(ks-1)/2;
y = y-(ks-1)/2;

% === Display =============================================================

if show
    
    clf
    hold on
    
    imshow(Frame)    
    scatter(x, y, 30, 'r+');
    
    % axis([450 550 450 550]);
    
    caxis auto
    drawnow limitrate
    
end

end

% === FUNCTIONS ===========================================================

function Sub = getSub(Img, x, y, w)

x1 = max(round(x-(w-1)/2),1);
x2 = min(round(x+(w-1)/2),size(Img,2));
y1 = max(round(y-(w-1)/2),1);
y2 = min(round(y+(w-1)/2),size(Img,1));

Sub = Img(y1:y2, x1:x2);

% Padding
if x1<(w-1)/2, Sub = [zeros(size(Sub,1),w-size(Sub,2)) Sub]; end
if x2>size(Sub,2)-(w-1)/2, Sub = [Sub zeros(size(Sub,1),w-size(Sub,2))]; end
if y1<(w-1)/2, Sub = [zeros(w-size(Sub,1),size(Sub,2)) ; Sub]; end
if y2>size(Sub,2)-(w-1)/2, Sub = [Sub ; zeros(w-size(Sub,1),size(Sub,2))]; end

end