function KeyPress(this, varargin)

this.mouseModifier = '';
K = varargin{2};

if isempty(K.Character) 
    switch K.Key
        case 'control'
            this.mouseModifier = 'ctrl';
            return
        otherwise
            return
    end
end

M = K.Modifier;

if char(K.Character)>=33 & char(K.Character)<=126
    in = K.Character;
    M = setdiff(M, 'shift');
else
    in = K.Key;
end

% --- Modifier

switch in
    case 'delete'
        this.mouseModifier = 'del';
        return
end

for i = 1:numel(M)
    in = [M{i} '+' in];
end

% --- Action

this.Command(in);