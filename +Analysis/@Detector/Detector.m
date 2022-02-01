classdef Detector < matlab.mixin.Copyable
    %Detector | A class for detecting events
    
    % === PROPERTIES ======================================================
    
    properties
        
        % --- Input
        
        % Trajectory
        Tr
        
        % --- Output
        
        % Events
        Candidates
        Events
        
        % --- Misc
        
        verbose
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Detector(Tr, arg)
            
            arguments
                Tr struct
                arg.verbose logical = true
            end

            this.Tr = Tr;
            this.verbose = arg.verbose;
                 
        end
        
   end
    
end

