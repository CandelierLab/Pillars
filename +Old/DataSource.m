function DS = DataSource()

DS = struct('root', '');

% --- Root

switch computer
    
    case 'PCWIN64'
        
    case 'GLNXA64'
        test = {'/home/ljp/Science/Projects/Misc/Pilars/' ...
            '/home/raphael/Science/Projects/Misc/Pilars/'};
end

for i = 1:numel(test) 
    if exist(test{i}, 'dir')
        DS.root = test{i};
        break;
    end
end

if isempty(DS.root)
    return
end

% --- Data

DS.Data = [DS.root 'Data' filesep];

% --- Programs

DS.Programs = [DS.root 'Programs' filesep];

% --- Files

DS.Files = [DS.root 'Files' filesep];

% --- Figures

DS.Figures = [DS.root 'Figures' filesep];


% --- Movies

DS.Movies = [DS.root 'Movies' filesep];
