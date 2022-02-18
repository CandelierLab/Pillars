function initFilters(this,varargin)

% --- Names ---------------------------------------------------------------

rows = {'Skewness', ...
    'Slope', ...
    'Amplitude', ...
    'Ramp duration', ...
    'Saturation duration', ...
    'Number of points', ...
    'Decay time', ...
    'Fit SE'};

cols = {'Min', ...
    'Mean', ...
    'Max', ...
    'Lower bound', ...
    'Upper bound', ...
    'Marg. Number', ...
    'Marg. Percentage', ...
    'Log. scale', ...
    'pdf log . scale'};

this.nFeat = numel(rows);

% --- Default content -----------------------------------------------------

T = {};

skew = [this.E(:).skew];
s = [this.E(:).s];
A = [this.E(:).A];
rd = A./s;
sat = [this.E(:).sat];
n = [this.E(:).n];
tau = [this.E(:).tau] ;
se = [this.E(:).se];

% Minimum values
T{1} = [min(skew) min(s) min(A) min(rd) min(sat) min(n) min(tau) min(se)]';

% Mean values
T{2} = [nanmean(skew) nanmean(s) nanmean(A) nanmean(rd) nanmean(sat) nanmean(n) nanmean(tau) nanmean(se)]';

% Maximum values
T{3} = [max(skew) max(s) max(A) max(rd) max(sat) max(n) max(tau) max(se)]';

% Lower bound
T{4} = zeros(this.nFeat,1);
T{4}(1) = 1;
T{4}(3) = 4.77;
T{4}(6) = min(n);

% Upper bound
T{5} = Inf(this.nFeat,1);

% Number & percentages
T{6} = NaN(this.nFeat,1);
T{7} = cell(this.nFeat,1);

% Logarithmic scale
T{8} = false(this.nFeat,1);

% pdf logarithmic scale
T{9} = true(this.nFeat,1);
T{9}([2 8]) = false;

% --- Set table data ------------------------------------------------------

this.table.filters.Data = table(T{:}, ...
    VariableNames=cols, ...
    RowNames=rows);

this.table.filters.ColumnEditable = [ ...
    false, ...  % Min
    false, ...  % Mean
    false, ...  % Max
    true, ...   % Lower bound
    true, ...   % Upper bound
    false, ...  % Marginal number
    false, ...  % Marginal percentage
    true, ...   % Log
    true];      % pdf log

% --- Update filters & plot

this.setFilter();
