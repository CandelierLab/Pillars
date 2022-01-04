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

rootDir = '/home/ljp/Science/Projects/Misc/Pilars/';

VW = VideoWriter([rootDir 'Movies/Zoom_' fMovie],'Uncompressed AVI');
VW.FrameRate = 10;
open(VW);

% =========================================================================

% --- Preparation

VR = VideoReader([rootDir 'Data' filesep fMovie]);

% --- Detection

for t = 10 %:100 %VR.NumFrames

    Raw = lImg(VR, t);
    
    % Smooth jpeg compression artifacts
    Tmp = imgaussfilt(double(Raw), 1);
    
    % Flatten background intensities
    ML = medfilt2(Raw, [1 1]*50, 'symmetric');   
    Img = Tmp - double(ML);
    
    % === Kernel ==========================================================
    
    % --- Candidate detection
    
    Tmp = imtranslate(-Img, [-1 1]*6) + imtranslate(Img, [1 -1]*11);   
    [yc, xc] = find(Tmp==imdilate(Tmp, strel('disk', ps)));
    
    % --- Rough kernel
    
    K = zeros(ks,ks);
    for i = 1:numel(xc)
        K = K + getSub(Img, xc(i), yc(i), ks);        
    end
    K = K/numel(x);
    
    % --- Corner regularization
    
    [X, Y] = meshgrid(1:ks, 1:ks);
    M = 1-1./(1+1000*exp(-0.5*sqrt((X-ks/2).^2 + (Y-ks/2).^2)));
    K = K.*M;
    
    % === Correlation =====================================================
    
    C = xcorr2(Img, K);
    
    % --- Rough peaks (at integer locations)
    
    [y0, x0] = find(C==imdilate(C, strel('disk', ps/2)) & C>max(C(:))/5);
    
%     I = find(x0-(ks-1)/2>ROI(1) & x0-(ks-1)/2<ROI(2) & y0-(ks-1)/2>ROI(3) & y0-(ks-1)/2<ROI(4));
%     x0 = x0(I);
%     y0 = y0(I);
    
    % --- Parabolic interpolation
    
    x = NaN(numel(x0),1);
    y = NaN(numel(y0),1);
    
    for i = 1:numel(x)
        
        if x0(i)>1 & x0(i)<size(C,2) 
        
            u = x0(i) + [-1 0 1];
            v = C(y0(i), u);
            
            a = v(1)/2 - v(2) + v(3)/2;
            b = v(1) - v(2) - a*(u(1)+u(2));
            
            x(i) = -b/2/a;
            
        end
        
        if y0(i)>1 & y0(i)<size(C,1) 
        
            u = y0(i) + [-1 0 1];
            v = C(u, x0(i));
            
            a = v(1)/2 - v(2) + v(3)/2;
            b = v(1) - v(2) - a*(u(1)+u(2));
            
            y(i) = -b/2/a;
            
        end
        
    end
    
    % Correction due to kernel size
    x = x-(ks-1)/2;
    y = y-(ks-1)/2;
    
    % === Display =============================================================
    
    clf
    hold on
    
%     imshow(Raw)
%     imshow(Img)
    imshow(K)
%     imshow(C)
      
%     scatter(x, y, 30, 'r+');
%     axis([450 550 450 550], 'on', 'xy', 'square');
    
    
    title(t)
    
%     axis on xy tight
    caxis auto
%     colorbar
    
    drawnow limitrate
    
    return
    
    % Save to video
    F = getframe(gca);
    
%     F.cdata = F.cdata(500:550, 500:550, :);
    
%     clf
%     imagesc(F.cdata)
%     return
    
    writeVideo(VW,F);
    
end

close(VW);

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