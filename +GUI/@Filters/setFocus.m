function setFocus(this,~,~, tag)

W = waitbar(0, 'Setting Focus');

% Update Focus
this.F = Focus(tag, verbose=false);

% Update figure name
this.fig.Name = ['Filters | ' this.F.tag];

% --- Load pillars

waitbar(.33, W, 'Loading checked trajectories');
Tmp = load(this.F.filepath('trajectories'));
this.P = Tmp.P(find([Tmp.P(:).checked]));

% --- Load events

waitbar(.66, W, 'Loading events');
Tmp = load(this.F.filepath('events'));
this.E = Tmp.E;
this.nEv = numel(this.E);

% --- Misc settings

waitbar(.9, W, 'Misc settings');

% Reset selection
this.sel.traj = [];
this.sel.event = [];

% Update image
this.image = imread(this.F.File.refFrame);

% Define positions
this.pos = struct('x', arrayfun(@(x) x.fx(1), this.P), ...
    'y', arrayfun(@(x) x.fy(1), this.P));

close(W)

% --- Initialize filters
this.initFilters

% --- Update display
this.Update