classdef Focus < matlab.mixin.Copyable
    %Focus | A class for I/O management
    
    % === PROPERTIES ======================================================
    
    properties
        
        tag
        
        Dir
        File
        
        W
        H
        T
        
        refFrame
        mmap   
        
        verbose
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Focus(varargin)
            
            % --- Input ---------------------------------------------------
            
            p = inputParser;
            p.addRequired('tag', @ischar);                      % tag
            p.addParameter('verbose', true, @islogical);       % Verbose
            p.parse(varargin{:});
            
            this.tag = p.Results.tag;
            this.verbose = p.Results.verbose;
            
            % -------------------------------------------------------------
            
            if this.verbose
                
                fprintf('=== %s =========================\n', this.tag);
                
            end
            
            % --- Directories ---------------------------------------------
            
            this.Dir = struct('root', '');
            
            % Root            
            this.Dir.root = Focus.getRoot();
            
            if ~isempty(this.Dir.root)
                
                % --- Data
                
                this.Dir.Data = [this.Dir.root 'Data' filesep];
                
                % --- Programs
                
                this.Dir.Programs = [this.Dir.root 'Programs' filesep];
                
                % --- Files
                
                this.Dir.Files = [this.Dir.root 'Files' filesep this.tag filesep];
                
                % --- Figures
                
                this.Dir.Figures = [this.Dir.root 'Figures' filesep];
                
                
                % --- Movies
                
                this.Dir.Movies = [this.Dir.root 'Movies' filesep];
                
            end
            
            % --- Files ---------------------------------------------------
            
            this.File = struct( ...
                'video', [this.Dir.Data this.tag '.avi'], ...
                'refFrame', [this.Dir.Data this.tag '.png'], ...
                'mmap', [this.Dir.Data this.tag '.mat'], ...
                'trajectories', [this.Dir.Files 'trajectories.mat']);
            
            % --- Movie properties ----------------------------------------
            
            VR = VideoReader(this.File.video);
            this.T = VR.NumFrames;
            this.W = VR.Width;
            this.H = VR.Height;
            
            % --- Reference frame -----------------------------------------
            
            if exist(this.File.refFrame, 'file')
                this.refFrame = imread(this.File.refFrame);
            else
                
                if this.verbose
                    fprintf('  * Saving reference frame ...');
                    tic
                end
                
                tmp = readFrame(VR);
                
                % Smooth (for jpeg compression artifact)
                GL = imgaussfilt(double(tmp(:,:,1)), 1);
                
                % Flatten background intensities
                ML = medfilt2(tmp(:,:,1), [1 1]*100, 'symmetric');
                
                Ref = GL - imgaussfilt(double(ML), 5);
                this.refFrame = uint8((Ref-min(Ref(:)))/(max(Ref(:))-min(Ref(:)))*255);
                                
                imwrite(this.refFrame, this.File.refFrame);
                
                if this.verbose
                    fprintf(' %.02f sec\n', toc);
                    tic
                end
            end
            
            % --- Memory map ----------------------------------------------
            
            if exist(this.File.mmap, 'file')
                
                this.mmap = memmapfile(this.File.mmap, 'Format', {'double' [this.H this.W] 'frame' }, ...
                    'Repeat', this.T, 'Writable', true);
    
            end
            
        end
        
    end
    
    % === STATIC METHODS ==================================================
    
    methods(Static)
        
        % --- Get root ----------------------------------------------------
        function R = getRoot()
           
            R = [];
            
            switch computer
                
                case 'PCWIN64'
                    
                case 'GLNXA64'
                    test = {'/home/ljp/Science/Projects/Misc/Pillars/' ...
                        '/home/raphael/Science/Projects/Misc/Pillars/'};
            end
            
            for i = 1:numel(test)
                if exist(test{i}, 'dir')
                    R = test{i};
                    break;
                end
            end
            
            
        end
        
        % --- List tags ---------------------------------------------------
        
        function L = taglist()
            
            %
            % TO DO: Add recursion in subfolders
            %
            
            R = Focus.getRoot();
            D = dir([R 'Data']);
            
            L = {};
            
            for i = 1:numel(D)
                
                % Skip . and ..
                if ismember(D(i).name, {'.', '..'})
                    continue
                end
            
                [~, L{end+1}] = fileparts(D(i).name);
                
            end
            
            L = unique(L);
            
        end
        
   end
    
end

