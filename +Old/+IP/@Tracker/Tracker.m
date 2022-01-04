classdef Tracker < matlab.mixin.Copyable
    %Tracker | A class for performing tracking 
    
    % === PROPERTIES ======================================================
    
    properties
        
        % Input
        param = struct('name', {}, 'active', {}, 'hard', {}, 'soft', {})
        aggregation = 'addition'
        assembly = struct('hard', {}, 'soft', {})
        
        % Filters
        filters = struct()
        
        % Output
        traj = struct('t', {})
        
        % Internal use
        reset = true
        values = struct()
        iter = 0
        lidx        
        nparam = 0
        
    end
    
    % === METHODS =========================================================
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Tracker(varargin)
            
            
        end
        
    end
end

