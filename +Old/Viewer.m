function Viewer(movieFile, trajFile)

% --- Files access

% Frame
VR = VideoReader(movieFile);
Tmp = read(VR, 1);
Frame = Tmp(:,:,1);

% Load trajectory
Tmp = load(trajFile);
traj = Tmp.traj;

% --- Display

cm = hsv(numel(traj));
cm = cm(randperm(numel(traj)),:);

[~, fname] = fileparts(movieFile);

% Variables
state = '';

showAll();
% showOne(253);


% === NESTED FUNCTIONS ====================================================

    function showAll()
        
        state = 'all';
        
        clf
        drawnow
        
        Ax = axes();
        hold(Ax, 'on');
        
        imagesc(Frame, 'Parent', Ax, 'ButtonDownFcn', @MouseInput);
        axis(Ax, 'equal', 'off', 'ij');
        colormap(Ax, gray);
        caxis(Ax, 'auto');
                
        for i = 1:numel(traj)
            plot(Ax, traj(i).position(:,1), traj(i).position(:,2), '-', ...
            'color', cm(i,:), 'ButtonDownFcn', @MouseInput);
        end
        
        title(fname);
        drawnow
        
    end


    function showOne(i)
        
        state = 'one';
        
        clf
        drawnow
        
        % --- Top plot
        
        Ax1 = subplot(3,1,1:2);
        hold(Ax1, 'on');
        
        imagesc(Frame, 'Parent', Ax1, 'ButtonDownFcn', @MouseInput);
        axis(Ax1, 'equal', 'on', 'ij');
        colormap(gray);
        caxis(Ax1, 'auto'); 
                
        plot(Ax1, traj(i).position(:,1), traj(i).position(:,2), '-', ...
            'color', cm(i,:), 'ButtonDownFcn', @MouseInput);
           
        % View
        mp = mean(traj(i).position, 1);
        axis(Ax1, mp([1 1 2 2]) + [-1 1 -1 1]*20);
        
        title(Ax1, [fname ' - traj ' num2str(i)]);
        
        % --- Bottom plot
        
        Ax2 = subplot(3,1,3);
        hold(Ax2, 'on');
        
        r = sqrt(sum((traj(i).position-traj(i).position(1,:)).^2,2));
%         r = traj(i).position(:,1);
        
        plot(Ax2, traj(i).t, r, '.-', 'color', cm(i,:));
        
                
        drawnow
        
    end

    function MouseInput(varargin)
        
        In = varargin{2};
        
        switch state
            
            case 'all'
                
                switch In.Button
                    
                    case 1      
                        % Left click
                        
                        % Find closer traj                        
                        [~, mi] = min(arrayfun(@(x) sum((x.position(1,:)-In.IntersectionPoint(1:2)).^2), traj));
                        
                        showOne(mi);
                        
                        
                    case 2
                        % Right click
                        
                end
                
            case 'one'
                
                showAll();
%                 showOne(253);
                
        end
        
    end

end