clc
close all

% === Parameters ==========================================================

tag = 'g4dmemf12';

force = true;

% =========================================================================

if force

    F = Focus(tag, verbose=false);

    Tmp = load(F.filepath('trajectories'));
    P = Tmp.P(find([Tmp.P(:).checked]));

    Tmp = load(F.filepath('events'));
    E = Tmp.E;

end

this = GUI.Filters(F, P, E);