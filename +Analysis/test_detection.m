clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% --- Data tag

tag = 'g4dmemf12';
% tag = 'g4dmemf12-3';
% tag = 'g4dmemf12-4';
% tag = 'g4gcb';
% tag = 'g4gcb-2';

i = 245;
% i = 208;

% --- Thresholds

th_phi = pi/3;

force = false;

% -------------------------------------------------------------------------

F = Focus(tag);

% =========================================================================

% --- Load pilars

if ~exist('Pc', 'var') || force
    
    fprintf('Loading checked pillars ...');
    tic
    
    tmp = load(F.File.trajectories);
    P = tmp.P;
    Pc = P([P(:).checked]);
    
    fprintf(' %.02f sec\n', toc);
    
end

Z = Pc(i).x-Pc(i).bx + 1i*(Pc(i).y-Pc(i).by);
R = abs(Z)';
A = angle(Z)';

mR = median(R);
s0 = mR*27/32;
mu = s0*sqrt(pi/2);
sigma = s0*sqrt(2-pi/2);

th_R = mu+5*sigma;

% Preparation
avail = true(F.T,1);
G = {};

while true
    
    % Locate maxixum
    [Rm, mi] = max(avail.*R);
    
    if Rm < th_R
        break;
    end
    
    % Initialize new group
    G{end+1} = mi;
    Aref = A(mi);
    dsearch = true(1,2);
    
    while true
        
        % --- Checks
        
        if dsearch(1)
            if G{end}(1)==1 || ~avail(G{end}(1)-1)
                dsearch(1) = false;
            end
        end
        
        if dsearch(2)
            if G{end}(end)==F.T || ~avail(G{end}(end)+1)
                dsearch(2) = false;
            end
        end
        
        % --- Select next candidate
        
        if all(dsearch)
            
            I = [G{end}(1)-1 G{end}(end)+1];
            [~, ml] = max(R(I));
            ci = I(ml);            
            
        elseif dsearch(1)
            
            ml = 1;
            ci = G{end}(1)-1;
            
        elseif dsearch(2)
            
            ml = 2;
            ci = G{end}(end)+1;
            
        else
    
            % Dilate group
            % G{end} = [G{end}(1)-1 G{end} G{end}(end)+1];
            
            % Update availability
            avail(G{end}) = false;
            
            break;
        end
        
        % --- Compare directions
        
        dphi = mod(A(ci)-Aref+pi, 2*pi) - pi;
        
        if abs(dphi)<=th_phi
            
            % Aggregate            
            G{end} = union(G{end}, ci);
            
            % Update
            Aref = angle(sum(Z(G{end})));
            
        else
            
            % Stop on this side
            dsearch(ml) = false;
            continue
            
        end
        
    end
    
    if ~any(avail)
        break;
    end
    
end

% === Display =============================================================

figure(1)
clf

ax1 = subplot(3,1,1:2);
hold on

plot(R, '-', 'color', [1 1 1]*0.75)
plot(R, '.', 'color', lines(1))

% for i = 5
%     line([1 F.T], [1 1]*(mu+i*sigma), 'color', 'k', 'LineStyle', '--');
% end
% 
% cm = jet(numel(G));
% 
% for i = 1:numel(G)
%     
%     plot(G{i}, R(G{i}), '.-', 'color', cm(i,:));
%         
% end

box on
grid on

xlabel('t')
ylabel('r');

ax2 = subplot(3,1,3);
hold on

plot(A, '-', 'color', [1 1 1]*0.75)
plot(A, '.', 'color', lines(1))

% for i = 1:numel(G)
%     
%     plot(G{i}, A(G{i}), '.-', 'color', cm(i,:));
%         
% end

box on
grid on
ylim([-1 1]*pi)
set(gca, 'YTick', -pi:pi/2:pi)
set(gca, 'YTickLabel', {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});

xlabel('t')
ylabel('\phi');

linkaxes([ax1 ax2], 'x');