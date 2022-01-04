clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% fMovie = 'WT21pillars20percentGCB+sup.avi';
fMovie = 'g4gcb.avi';

% Pilar size
ps = 20;

% Kernel size
ks = 35;

% -------------------------------------------------------------------------

% % % tK = [];

rootDir = '/home/ljp/Science/Projects/Misc/Pilars/';

% =========================================================================

% --- Preparation

VR = VideoReader([rootDir 'Data' filesep fMovie]);

% --- Detection

for t = 501 %:502 %1:100
    
    Raw = lImg(VR, t);
    
    % Smooth jpeg compression artifacts
    Tmp = imgaussfilt(double(Raw), 1);
    
    % Flatten background intensities
    ML = medfilt2(Raw, [1 1]*100, 'symmetric');
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
    
%     C(C<20000) = 0;
    
    % --- Rough peaks (at integer locations)
    
%     [y0, x0] = find(C==imdilate(C, strel('disk', ps/2)) & C>max(C(:))/5);
    
    [x0, y0] = meshgrid((550:560) + (ks-1)/2, (330:340) + (ks-1)/2);
            
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
              
% % %         clf
% % %         hold on
% % %         
% % %         imshow(Z)
% % %        
% % %         axis on tight
% % %         caxis auto        
% % %         colorbar
% % %         
% % %         return
    
    end
    
% % %   
    % Correction due to kernel size
%     x = x-(ks-1)/2;
%     y = y-(ks-1)/2;
%     
    % === Display =========================================================
    
    clf
    hold on
    
%     imshow(Raw)
%     imshow(Img)
%     imshow(K)
    imshow(C)
    
    scatter(x0(:), y0(:), 50, 'c.');
    scatter(x, y, 50, 'r+');
    axis([535 575 315 355] + (ks-1)/2, 'on');
    colorbar

    title(t)
    caxis auto   
    drawnow limitrate
    
end

% === FUNCTIONS ===========================================================

function Img = lImg(VR, t)

Tmp = read(VR, t);
Img = Tmp(:,:,1);

end

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