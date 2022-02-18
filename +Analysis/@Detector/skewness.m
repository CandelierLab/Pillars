function skewness(this, arg)

arguments
    this
    arg.verbose logical = this.verbose
end

if arg.verbose
    fprintf('Skewness ');
    tic
    itp = round(numel(this.E)/10);
end

for i = 1:numel(this.E)

    hv = (this.E(i).n+1)/2;
    if mod(hv,1)==0
        x = this.E(i).frames;
        rho = this.E(i).rho;
    else
        x = [this.E(i).frames(1:hv-1/2) (this.E(i).frames(hv-1/2)+this.E(i).frames(hv+1/2))/2 this.E(i).frames(hv+1/2:end)];
        rho = interp1(this.E(i).frames, this.E(i).rho, x);
        hv = hv+1/2;
    end

    I1 = trapz(x(1:hv), rho(1:hv));
    I2 = trapz(x(hv:end), rho(hv:end));
    this.E(i).skew = I2/I1;

    if arg.verbose && ~mod(i, itp)
        fprintf('.')
    end

end

if arg.verbose
    fprintf(' %.02f sec\n', toc);
end