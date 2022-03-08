function Out = getEventsFeature(this, feature, Idx)

arguments
    this
    feature
    Idx double = 1:this.nEv
end

switch feature

    case {1, 'Skewness'}
        Out = [this.E(Idx).skew];

    case {2, 'Slope'}
        if this.use_rho 
            Out = [this.E(Idx).s];
        else
            Out = [this.E(Idx).s]*this.sigma_x;
        end        

    case {3, 'Amplitude'}
        if this.use_rho 
            Out = [this.E(Idx).A];
        else
            Out = [this.E(Idx).A]*this.sigma_x;
        end  

    case {4, 'Ramp duration'}
        Out = [this.E(Idx).A]./[this.E(Idx).s];

    case {5, 'Saturation duration'}
        Out = [this.E(Idx).sat];
        
    case {6, 'Number of points'}
        Out = [this.E(Idx).n];

    case {7, 'Decay time'}
        Out = [this.E(Idx).tau];

    case {8, 'Fit SE'}
        Out = [this.E(Idx).se];

end