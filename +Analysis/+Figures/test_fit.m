clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

% tag = 'g4-2';
tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

% --- Misc options

% File tag
ftag = 'events';

force = false;

% -------------------------------------------------------------------------

F = Focus(tag, verbose=false);

% =========================================================================

% --- Detector

if ~exist('D', 'var') || force

    D = Analysis.Detector();

    Tmp = load(F.filepath('trajectories'));
    D.P = Tmp.P([Tmp.P(:).checked]);

    Tmp = load(F.filepath(ftag));
    D.E = Tmp.E;

end

% --- COMPUTATION ------------------------------------------------------

% Single     66, 285, 2449
% Saturated  291,614,1269,1904,2499, 2765
% Strange    11,111,2887

i = 10662;

Ev = D.E(i);
r = D.P(Ev.idx).rho;

% --- Fit

f = D.fitEvent(i, ...
    resamplingFactor=10, ...
    enableSaturation=true, ...
    seThreshold=0.6)

% === Display =============================================================

% Margin
m = 5;
cm = lines(1);

figure(1)
clf
hold on

I = [Ev.frames(1)+(-m:-1) Ev.frames Ev.frames(end)+(1:m)];
I(I<1 | I>numel(r)) = [];

plot(I, r(I), ':', color=cm);
plot(Ev.frames, r(Ev.frames), '-', Color=cm, LineWidth=1.5)
scatter(Ev.frames, r(Ev.frames), 300, '.', MarkerEdgeColor=cm)

% --- Plot fit

x = Ev.frames(1) + linspace(-m, Ev.n-1+m, 1000);
y = Analysis.Detector.model(x, f.t0, f.s, f.A, f.tau, f.sat);
plot(x, y, 'k-');

title(['traj ' num2str(Ev.idx) ' - event ' num2str(i) ' - sk=' num2str(Ev.skew,'%.02f') ' - se=' num2str(f.se,'%.02f')])

box on

% % % return
% % % 
% % % D.plotEvent(P, E, margin=5)
% % % 
% % % J = [D.E(i).frames(1)+(-m:-1) D.E(i).frames D.E(i).frames(end)+(1:m)];
% % % 
% % % plot(P(D.E(i).idx).rho(J), '.--')
% % % plot(m+(1:E(i).n), E(i).rho, 'k-')
% % % scatter(m+(1:E(i).n), E(i).rho, 250, '.', 'MarkerEdgeColor', 'k')
% % % 
% % % x = linspace(1, 2*m+E(i).n, 200);
% % % if advancedFit
% % %     y = Analysis.Detector.model(x-m, f.s, f.t0, f.t1, f.t2, f.tau);
% % % else
% % %     y = Analysis.Detector.model(x-m, f.s, f.t0, f.t1);
% % % end
% % % plot(x, y, 'r-');

% title(gof.rmse)

box on
grid on

xlabel('t')
ylabel('\rho')