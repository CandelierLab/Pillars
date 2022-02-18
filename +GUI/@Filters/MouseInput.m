function MouseInput(this,~,hit,panel)

switch panel

    case 'image'    % === IMAGE ===========================================

        switch hit.Button

            case 1  % --- Leftclick

                % Find closest
                d2 = (hit.IntersectionPoint(1)-this.pos.x).^2 + (hit.IntersectionPoint(2)-this.pos.y).^2;
                [~,I] = sort(d2, 'ascend');

                this.sel.traj = I(1:this.nSel.traj);
                this.sel.event = [];

                this.Update();

        end

    case 'trace'    % === TRACE ===========================================

        switch hit.Button

            case 1  % --- Leftclick

                % --- Find pillar 
                idx = this.sel.traj(floor(hit.IntersectionPoint(2)));

                % --- Find event

                I = find([this.E(:).idx]==idx);
                if isempty(I), return; end

                t1 = arrayfun(@(x) x.frames(1)+0.01, this.E(I));
                t2 = arrayfun(@(x) x.frames(end)-0.01, this.E(I));
                [~, mi] = min(min(abs(t1-hit.IntersectionPoint(1)), abs(t2-hit.IntersectionPoint(1))));

                this.sel.event = I(mi);

                this.Update('event');

        end
end

% switch hit.Button
%          
%     case 1
%         in = 'leftclick';
%         
%     case 2
%         in = 'middleclick';
%         
%     case 3
%         in = 'rightclick';
%         
% end
