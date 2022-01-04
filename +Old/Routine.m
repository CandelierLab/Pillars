clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Files and directories -----------------------------------------------

rootDir = '/home/ljp/Science/Projects/Misc/Pilars/';

% --- Movie name

% movieName = 'WT21pillars20percentGCB+sup.avi';
% movieName = 'g4gcb.avi';
movieName = 'g4gcb-2.avi';
% movieName = 'g4dmemf12.avi';
% movieName = 'g4dmemf12-3.avi';
% movieName = 'g4dmemf12-4.avi';

% --- Files

movieFile = [rootDir 'Data' filesep movieName];
trajFile = [rootDir 'Files' filesep movieName(1:end-3) 'mat'];

% --- Image processing ----------------------------------------------------

% Pilar size
ps = 20;

% Kernel size
ks = 35;

% --- Misc options --------------------------------------------------------

% Verbose
verbose = true;

force = true;

% =========================================================================

% --- Process Movie

if ~exist('P', 'var') || force

    P = ProcessMovie(movieFile, ...
        'ps', ps, 'ks', ks, 'verbose', verbose);
    
end

% --- Tracking

if ~exist('Tr', 'var') || force

    Tr = Tracking(P, 'verbose', verbose);
    
    % Save
    traj = Tr.traj;
    save(trajFile, 'traj');

end

% Viewer

Viewer(movieFile, trajFile);


% clf
% hold on
% for i = 1:numel(traj)
%    
%     plot(traj(i).position(:,1), traj(i).position(:,2), '.-');
%     
% end
% 
% axis equal


