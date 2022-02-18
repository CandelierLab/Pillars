function KeyPress(this, varargin)

K = varargin{2};

if isempty(K.Modifier)
    input = K.Key;
else
    m = join(K.Modifier,'+');
    input =  [m{1} '+' K.Key];
end


% --- Trigger command

this.Command(input);