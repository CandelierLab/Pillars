function setOption(this,~,~, name)

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

        assignin('base', 'Events', this.E(this.sub));

        fprintf('------------------------------------\n');
        fprintf('Successfully imported %i events in the ''Events'' variable of the workspace.\n', numel(this.sub));

    case 'export2file'

        fname = uiputfile('*.mat');
        if fname
            Events = this.E(this.sub);
            save(fname, 'Events');

            fprintf('------------------------------------\n');
            fprintf('Successfully saved %i events in ''%s''.\n', numel(this.sub), fname);

        end
end