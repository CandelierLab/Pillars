function Out = fitEvent(this, i, arg)

arguments
    this
    i double
    arg.threshold double = 4.77
    arg.resamplingFactor = 10
    arg.enableSaturation logical = true
    arg.seThreshold double = 0.5
end

% Resampling
x = linspace(this.E(i).frames(1), this.E(i).frames(end), arg.resamplingFactor*(this.E(i).n-1)+1);
y = interp1(this.E(i).frames, this.E(i).rho, x);

[f, gof] = fit(x(:), y(:), ...
    fittype(@(t0,s,A,tau,x) Analysis.Detector.model(x,t0,s,A,tau)), ...
    Lower = [x(1)-this.E(i).n/2 0 arg.threshold 0], ...
    Upper = [x(1)+this.E(i).n/2 max(y) max(y) this.E(i).n/2], ...
    StartPoint = [x(1) max(y)*2/(this.E(i).n-1) max(y) 1]);

% Standard error
se = gof.rmse/sqrt(this.E(i).n);

% Define output
Out = struct('t0', f.t0, 's', f.s, 'A', f.A, 'tau', f.tau, 'sat', 0, ...
    'rmse', gof.rmse, 'se', se);

% --- Check saturation

if arg.enableSaturation && se>arg.seThreshold

    [f, gof] = fit(x(:), y(:), ...
    fittype(@(t0,s,A,tau,sat,x) Analysis.Detector.model(x,t0,s,A,tau,sat)), ...
    Lower = [x(1)-this.E(i).n/2 0 arg.threshold 0 0], ...
    Upper = [x(1)+this.E(i).n/2 max(y) max(y) this.E(i).n/2 this.E(i).n-2], ...
    StartPoint = [x(1) max(y)*2/(this.E(i).n-1) max(y) 1 1]);

    % Standard error
    se2 = gof.rmse/sqrt(this.E(i).n);

    if se2<se
        Out = struct('t0', f.t0, 's', f.s, 'A', f.A, 'tau', f.tau, 'sat', f.sat, ...
            'rmse', gof.rmse, 'se', se2);
    end
end

% --- Correct for decay time bias

if abs(round(2*Out.tau)/2-Out.tau)<1e-6
    Out.tau = Out.tau + randn(1)/4;
end

