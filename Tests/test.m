clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Files and directories

% Data source
% DS = DataSource;

% --- Movie name

% movieFile = 'WT21pillars20percentGCB+sup.avi';
% movieFile = 'g4gcb.avi';
% movieFile = 'g4gcb-2.avi';
tag = 'g4dmemf12';
% movieFile = 'g4dmemf12-3.avi';
% movieFile = 'g4dmemf12-4.avi';

% --- Misc options

% Verbose
verbose = true;

force = true;

% -------------------------------------------------------------------------

F = Focus(tag);

Tmp = load(F.File.drift);
D = Tmp.D;

Tmp = load('/home/ljp/Science/Projects/Misc/Pilars/Files/g4dmemf12/Pilars.mat');
P = Tmp.P;

x = arrayfun(@(p) p.x(1), P);
y = arrayfun(@(p) p.y(1), P);
u = arrayfun(@(p) p.x(end)-p.x(1), P) - (D.x(end)-D.x(1));
v = arrayfun(@(p) p.y(end)-p.y(1), P) - (D.y(end)-D.y(1));


clf
hold on

scatter(x, y, 'k.');
quiver(x, y, u, v, 5)

axis equal
box on