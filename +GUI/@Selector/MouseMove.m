function MouseMove(this, varargin)

F = fieldnames(this.Axes);

for i = 1:numel(F)
    
    this.Cursor.(F{i}) = [NaN NaN];
    
    % Check visibility
    % if strcmp(this.Axes.(F{i}).Visible, 'off'), continue; end

    % Get cursor position
    tmp = this.Axes.(F{i}).CurrentPoint;

    % Check limits    
    if tmp(1,1) < this.Axes.(F{i}).XLim(1) || ...
            tmp(1,1) > this.Axes.(F{i}).XLim(2) || ...
            tmp(1,2) < this.Axes.(F{i}).YLim(1) || ...
            tmp(1,2) > this.Axes.(F{i}).YLim(2)
        
        continue
    end
    
    this.Cursor.(F{i}) = tmp(1,1:2);
    this.Cursor.location = F{i};
    
end