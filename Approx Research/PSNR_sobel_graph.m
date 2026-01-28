% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
PSNR_Sobel_Values = [
    6.59,   6.68,   6.43,   6.17,   6.38;    % EAL1
    6.48,   0.0,    6.46,   0.0,    5.60;    % EAL2
    6.46,   6.48,   6.46,   6.25,   5.93;    % EAL3
    6.51,   6.44,   6.27,   5.69,   5.85;    % EAL4
    6.48,   6.40,   5.98,   5.30,   5.15;    % EAL5
    6.62,   6.67,   6.63,   5.87,   6.17;    % EAL6
    6.65,   6.82,   6.74,   6.64,   6.88;    % EAL7
    6.66,   6.74,   6.81,   6.46,   5.02;    % EAL8
    6.53,   6.57,   6.54,   6.23,   5.42;    % EAL9
    6.58,   6.76,   7.06,   7.04,   7.07     % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};
bitLabels = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% --- COLORS (Fixed Map) ---
% 1:4-bit(Blue), 2:5-bit(Orange), 3:6-bit(Yellow), 4:7-bit(Purple), 5:8-bit(Green)
fixedColors = [
    0.00, 0.45, 0.74;  % 4-bit (Blue)
    0.85, 0.33, 0.10;  % 5-bit (Orange)
    0.93, 0.69, 0.13;  % 6-bit (Yellow)
    0.49, 0.18, 0.56;  % 7-bit (Purple)
    0.47, 0.67, 0.19   % 8-bit (Green)
];

% --- PLOTTING SETUP ---
figure('Position', [50, 50, 1600, 900], 'Color', 'w');
hold on;
axis off; 

% Layout Parameters
num_groups = 10;
bar_width = 0.5;
group_spacing = 2.0; 
x_limit = num_groups * group_spacing + 1;

% --- MAIN LOOP ---
for i = 1:num_groups
    
    % 1. Get & Sort Data
    raw_vals = PSNR_Sobel_Values(i, :);
    valid_indices = find(raw_vals > 0);
    valid_vals = raw_vals(valid_indices);
    
    % Sort Ascending (Smallest at bottom, Largest at top)
    [sorted_vals, sort_idx] = sort(valid_vals);
    original_indices = valid_indices(sort_idx);
    
    % 2. Calculate Incremental Heights
    heights = zeros(size(sorted_vals));
    heights(1) = sorted_vals(1);
    for k = 2:length(sorted_vals)
        heights(k) = sorted_vals(k) - sorted_vals(k-1);
    end
    
    % --- DRAW BARS ---
    center_x = (i-1) * group_spacing + 1;
    start_x = center_x - bar_width/2;
    current_y = 0;
    
    for k = 1:length(sorted_vals)
        h = heights(k);
        col_idx = original_indices(k);
        c = fixedColors(col_idx, :);
        
        % Draw Bar Segment
        rectangle('Position', [start_x, current_y, bar_width, h], ...
            'FaceColor', c, 'EdgeColor', 'k', 'LineWidth', 0.8);
        
        % Red Value Label (High Contrast)
        text_val = sorted_vals(k);
        text(start_x + bar_width + 0.05, current_y + h, sprintf('%.2f', text_val), ...
            'Color', [0.8 0 0], 'FontSize', 7, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
            
        current_y = current_y + h;
    end
    
    % X-Axis Label (Black)
    text(center_x, -0.2, logicNames{i}, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    
    % --- DRAW INDIVIDUAL LEGEND BOX ---
    box_w = 1.6;
    box_h = 1.8; 
    box_x = center_x - box_w/2;
    box_y = current_y + 0.5; 
    
    % Box Background (Thicker Black Border)
    rectangle('Position', [box_x, box_y, box_w, box_h], ...
        'FaceColor', 'w', 'EdgeColor', 'k', 'LineWidth', 1.0);
    
    % Legend Title
    text(center_x, box_y + box_h - 0.15, [logicNames{i} ' Order'], ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');
    
    row_h = 0.25;
    curr_leg_y = box_y + box_h - 0.4;
    patch_size = 0.1;
    
    % Iterate Descending (Top of stack first)
    for k = length(sorted_vals):-1:1
        idx_k = original_indices(k); 
        label_str = bitLabels{idx_k};
        
        % Label: "X-bit :" (Bold Black)
        text(box_x + 0.1, curr_leg_y, [label_str ':'], ...
            'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k');
        
        % Open Bracket
        text(box_x + 0.5, curr_leg_y, '(', 'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k');
        
        % Draw Cumulative Patches
        px = box_x + 0.6;
        for p = 1:k
             pidx = original_indices(p);
             pc = fixedColors(pidx, :);
             
             rectangle('Position', [px, curr_leg_y - patch_size/2, patch_size, patch_size], ...
                 'FaceColor', pc, 'EdgeColor', 'none');
             
             px = px + patch_size + 0.02;
             
             % '+' Sign
             if p < k
                 text(px, curr_leg_y, '+', 'FontSize', 6, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');
                 px = px + 0.05;
             end
        end
        
        % Close Bracket
        text(px + 0.02, curr_leg_y, ')', 'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k');
        
        curr_leg_y = curr_leg_y - row_h;
    end
end

% --- MANUAL AXES ---
max_val_global = max(max(PSNR_Sobel_Values));
y_top = max_val_global + 3; 

% Y-Axis Line (Thick)
line([0, 0], [0, y_top], 'Color', 'k', 'LineWidth', 1.5);

% Y-Ticks & Labels (Bold)
yticks = 0:1:ceil(max_val_global);
for y = yticks
    line([-0.15, 0], [y, y], 'Color', 'k', 'LineWidth', 1.0);
    text(-0.25, y, num2str(y), 'HorizontalAlignment', 'right', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
end

% Y-Label
text(-1.8, y_top/2, 'PSNR value of Original i/p image v/s o/p image (dB) of Sobel kernel', 'Rotation', 90, ...
    'FontSize', 13, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');

% X-Axis Line (Thick)
line([0, x_limit], [0, 0], 'Color', 'k', 'LineWidth', 1.5);
text(x_limit/2, -1.2, 'Approximation Logic', ...
    'FontSize', 13, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');

% Title
text(x_limit/2, y_top + 0.5, 'PSNR COMPARISON (SOBEL KERNEL) ', ...
    'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');

% Adjust View
axis([-2.5, x_limit, -1.5, y_top + 1]);
axis off;