function setOption(this,~,~, name)

switch name

    case 'use_r'

        this.use_rho = false;
        this.menu.options.use_r.Checked = 'on';
        this.menu.options.use_rho.Checked = 'off';
        this.Update

    case 'use_rho'

        this.use_rho = true;
        this.menu.options.use_r.Checked = 'off';
        this.menu.options.use_rho.Checked = 'on';
        this.Update
        
    case 'dist_pdf'

        this.disp.marg = this.elms.pdf_marg.Value || this.elms.pdf_both.Value;
        this.disp.filt = this.elms.pdf_filt.Value || this.elms.pdf_both.Value;
        
        this.Update
end