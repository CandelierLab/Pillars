classdef pTracker < matlab.mixin.Copyable
    %pTracker | A class for pilar tracking 
    
    % === PROPERTIES ======================================================
    
    properties
        
       % Focus       
       F
       
       % Pilar trajectories
       P
       
       % --- Parameters
       
       % Kernel size
       ks = 41;
       
       % Baseline window size
       bws = 80;
       
       % Eignevector window size
       ews = 30;
       
       % --- Misc
       
       verbose = true;
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = pTracker(varargin)
            
            % --- Input ---------------------------------------------------
            
            p = inputParser;
            p.addRequired('F', @(x) isa(x, 'Focus'));     % Movie name
            p.addParameter('verbose', [], @islogical);    % Verbose
            p.parse(varargin{:});
            
            this.F = p.Results.F;
            
            this.verbose = p.Results.verbose;
            if isempty(this.verbose), this.verbose = this.F.verbose; end
                       
            % --- Trajectories --------------------------------------------
            
            this.P = struct();
            
        end
                
    end
end

