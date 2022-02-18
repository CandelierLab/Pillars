classdef Detector < matlab.mixin.Copyable
    %Detector | A class for detecting events
    
    % === PROPERTIES ======================================================
    
    properties
        
        % --- Input
        
        % Trajectories
        P
        
        % Events        
        E
        
        % --- Misc
        
        verbose
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Detector(P, arg)
            
            arguments
                P struct = struct('x', {}, 'y', {});
                arg.verbose logical = true
            end

            this.P = P;
            this.verbose = arg.verbose;
                 
        end
        
    end

    methods (Static)
      y = model(x, t0, s, A, tau, sat)
      plotEvent(P, E, arg)
    end

end

