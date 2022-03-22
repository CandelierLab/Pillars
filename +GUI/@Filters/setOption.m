function setOption(this,~,~, name)

rho2r = @(x) this.sigma_x*x;

switch name

    case 'use_r'

        this.use_rho = false;
        this.menu.options.use_r.Checked = 'on';
        this.menu.options.use_rho.Checked = 'off';
        
        this.initFilters

    case 'use_rho'

        this.use_rho = true;
        this.menu.options.use_r.Checked = 'off';
        this.menu.options.use_rho.Checked = 'on';

        this.initFilters
        
    case 'dist_pdf'

        this.disp.marg = this.elms.pdf_marg.Value || this.elms.pdf_both.Value;
        this.disp.filt = this.elms.pdf_filt.Value || this.elms.pdf_both.Value;
        this.Update

    case 'export2WS'

        Events = this.E(this.sub);

        % Add r-based quantities
        for i = 1:numel(Events)
            Events(i).A_r = rho2r(Events(i).A);
            Events(i).s_r = rho2r(Events(i).s);
        end

        assignin('base', 'Events', Events);

        fprintf('------------------------------------\n');
        fprintf('Successfully imported %i events in the ''Events'' variable of the workspace.\n', numel(this.sub));

    case 'export2file'

        fname = uiputfile('*.mat');
        if fname

             Events = this.E(this.sub);

             % Add r-based quantities
             for i = 1:numel(Events)
                 Events(i).A_r = rho2r(Events(i).A);
                 Events(i).s_r = rho2r(Events(i).s);
             end

            save(fname, 'Events');

            fprintf('------------------------------------\n');
            fprintf('Successfully saved %i events in ''%s''.\n', numel(this.sub), fname);

        end
end