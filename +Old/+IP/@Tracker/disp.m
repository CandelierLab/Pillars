function I = disp(this, varargin)
%Tracker.disp Tracker info display

fprintf('\n--- Tracker %s\n\n', repmat('-', [1 70]));

fprintf(' Trajectories: <strong>%i</strong> \n\n', numel(this.traj));
fprintf(' Iterations: %i \n', this.iter);
fprintf(' Parameters:\n');
for i = 1:this.nparam
    
    if this.param(i).active
        
        fprintf('   * <strong>%s</strong> ', this.param(i).name);
        
        % Hard costs
        fprintf('\tHard (%s', this.param(i).hard.method);
        switch this.param(i).hard.method
            case 'metric'
                fprintf(' - max: %.02f', this.param(i).hard.max);
        end
        fprintf(')');
        
        % Soft costs
        fprintf('\tSoft (%s', this.param(i).soft.method);
        fprintf(' - norm: %.02f)', this.param(i).soft.norm);
        
    else
        
        fprintf('   * %s ', this.param(i).name);
        
    end
    
    fprintf('\n');
end

% --- Filters

if isempty(this.filters)
    
    fprintf(' No filter.\n');
    
else

    F = fieldnames(this.filters);
    fprintf(' Filters:\n');
    
    for i = 1:numel(F)

        fprintf('   * %s [%.02f ; %.02f]', F{i}, this.filters.(F{i}));
        
    end
    
    fprintf('\n');
end

% --- Assembly

if isempty(this.assembly)

    fprintf(' No assembly.\n');
    
else

    fprintf(' Assembled:\n   * max: %.02f ; norm: %.02f\n', this.assembly.hard.max, this.assembly.soft.norm);

end


fprintf('\n');