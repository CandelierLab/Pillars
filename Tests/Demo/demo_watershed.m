clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Movie name
tag = 'g4dmemf12';

ks = 75;

i = 222;

% --- Misc options
force = true;

% -------------------------------------------------------------------------

F = Focus(tag);

tmp = load(F.File.trajectories);
P = tmp.P;

[X, Y] = meshgrid(1:ks, 1:ks);
LCPM = 30*exp(-((X-ks/2).^2 + (Y-ks/2).^2)/50);

Sub = F.getSub(1, P(i).x(1),  P(i).y(1), ks);

% Prepare and watershed
Z = -imgaussfilt(abs(Sub), 1.5) - LCPM;

L = watershed(Z);
M = L==L((ks-1)/2, (ks-1)/2);

% === Display =============================================================

figure(1)
clf
hold on

imshow(Sub);
caxis auto

%surf(Z-50);

daspect([1 1 1])

% surf(Sub+50);
view(45,40)

% -------------------------------------------------------------------------

figure(2)
clf
hold on

surf(Z);

daspect([1 1 1])

% surf(Sub+50);
view(45,40)
axis off

% -------------------------------------------------------------------------

figure(3)
clf
hold on

I4 = labeloverlay(Sub/15, L);

imshow(I4)

caxis auto
