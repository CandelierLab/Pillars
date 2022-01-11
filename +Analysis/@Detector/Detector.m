classdef Detector < matlab.mixin.Copyable
    %Detector | A class for detecting events
    
    % === PROPERTIES ======================================================
    
    properties
        
        % --- Input
        
        % Trajectory
        Tr
        
        % --- Output
        
        % Events
        Ev = {}
        
        % --- Misc
        
        verbose
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Detector(varargin)
            
            % --- Input ---------------------------------------------------
            
            p = inputParser;
            p.addRequired('Tr', @(x) true);                    % tag
            p.addParameter('verbose', true, @islogical);       % Verbose
            p.parse(varargin{:});
            
            this.Tr = p.Results.Tr;
            this.verbose = p.Results.verbose;
            
            % -------------------------------------------------------------
         
            
            
        end
        
   end
    
end

