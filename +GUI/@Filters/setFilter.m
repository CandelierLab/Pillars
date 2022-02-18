function setFilter(this, varargin)

% --- Features and bounds

% Initial selection
I = true(1, this.nEv);

for i = 1:this.nFeat

    % Feature
    Ft = this.getEventsFeature(i);

    % Bound
    Bd = this.table.filters.Data(i,4:5).Variables;

    % --- Marginal quantities

    J = Ft>=Bd(1) & Ft<=Bd(2);
    
    nJ = nnz(J);
    this.table.filters.Data{i,6} = nJ;
    this.table.filters.Data{i,7} = {num2str(nJ/this.nEv*100, '%.02f')};

    % Update global filter
    I = I & J;

end

this.sub = find(I);

% --- Update filtered count

gc = numel(this.sub);

this.html.global.HTMLSource = ['<div style="font-family: sans-serif; font-size:12px; margin: 35px 0 0 0;">' ...
    '<center>Filt. number of events<br>' num2str(gc) '</center><br><hr><br>' ...
    '<center>Global percentage<br>' num2str(gc*100/this.nEv, '%.02f') '%</center></div>'];

% --- Update mdplot

this.Update('mdplot')