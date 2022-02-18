function y = model(x, t0, s, A, tau, sat)

arguments
    x double
    t0 double
    s double
    A double
    tau double
    sat {mustBeInRange(sat,0,1e6)} = 0
end

y = NaN(size(x));

% Zeros before
y(x<=t0) = 0;

% Ramp
t1 = t0 + A/s;
I = x>t0 & x<=t1;
y(I) = s*(x(I)-t0);

if sat==0
    
    I = x>t1;
    y(I) = A*exp(-(x(I)-t1)/tau);

else

    t2 = t1 + sat;

    % Saturation    
    I = x>t1 & x<=t2;
    y(I) = A;

    % Exponential relaxation
    I = x>t2;
    y(I) = A*exp(-(x(I)-t2)/tau);

end