function Out = fitAllEvents(this, arg)

arguments
    this
    arg.threshold double = 4.77
    arg.verbose logical = this.verbose
end

if arg.verbose
    fprintf('Fitting ');
    tic
    itp = round(numel(this.E)/10);
end

for i = 1:numel(this.E)

    try
        f = this.fitEvent(i, ...
            resamplingFactor=10, ...
            enableSaturation=true, ...
            seThreshold=0.6);
    catch
        keyboard
    end

    % Update values
    this.E(i).t0 = f.t0;
    this.E(i).s = f.s;
    this.E(i).A = f.A;
    this.E(i).sat = f.sat;
    this.E(i).tau = f.tau;
    this.E(i).se = f.se;

    if arg.verbose && ~mod(i, itp)
        fprintf('.')
    end

end

if arg.verbose
    fprintf(' %.02f sec\n', toc);
end