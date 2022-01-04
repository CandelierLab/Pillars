function MouseInput(this, varargin)

K = varargin{2};

switch K.Button
    
    case 0
        in = 'otherclick';
        
    case 1
        in = 'leftclick';
        
    case 2
        in = 'middleclick';
        
    case 3
        in = 'rightclick';
        
end

% --- Modifier

if ~isempty(this.mouseModifier)
    
    in = [this.mouseModifier '+' in];
    this.mouseModifier = '';
    
end

% --- Action

this.Command(in);
