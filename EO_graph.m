% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
% Rows: Logic types (EAL1 to EAL9 + PAL)
% Columns: Bit Widths (4-bit, 5-bit, 6-bit, 7-bit, 8-bit)
EO_Values = [
    11468800, 12795904, 13791232, 13791232, 15097600;   % EAL1
    13631488, 0,        15597568, 0,        16334848;   % EAL2
    9699328,  11468800, 12795904, 13791232, 14537728;   % EAL3
    11468800, 12795904, 13791232, 14537728, 15097600;   % EAL4
    13172736, 14417920, 15233024, 15766528, 161115712;  % EAL5 (Large value kept)
    11468800, 12795904, 13791232, 14537728, 15097600;   % EAL6
    15728640, 16252928, 16646144, 16646144, 16711680;   % EAL7
    15728640, 16252928, 16646144, 16646144, 16711680;   % EAL8
    15728640, 16252928, 16515072, 16646144, 16711680;   % EAL9
    6029312,  7602176,  8945664,  10092544, 11071488    % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};

% --- DATA PROCESSING (Incremental Logic & Filling) ---
Filled_Values = EO_Values;
% 1. Fill missing 0 values with previous bit's value
for i = 1:size(Filled_Values, 1)
    for j = 2:size(Filled_Values, 2)
        if Filled_Values(i, j) == 0
            Filled_Values(i, j) = Filled_Values(i, j-1);
        end
    end
end

% 2. Calculate Differences for Stacking
Plot_Data = zeros(size(Filled_Values));
Plot_Data(:, 1) = Filled_Values(:, 1);
for j = 2:size(Filled_Values, 2)
    Plot_Data(:, j) = Filled_Values(:, j) - Filled_Values(:, j-1);
end

% --- PLOTTING ---
figure('Position', [100, 100, 1400, 800], 'Color', 'w'); 

x = 1:size(Plot_Data, 1);
b = bar(x, Plot_Data, 'stacked');

% --- STYLING ---
barWidth = 0.5; 
for i = 1:length(b)
    b(i).BarWidth = barWidth;
end

% --- COLORS ---
customColors = [
    0.00, 0.45, 0.74;  % 4-bit (Blue)
    0.85, 0.33, 0.10;  % 5-bit (Orange)
    0.93, 0.69, 0.13;  % 6-bit (Yellow)
    0.49, 0.18, 0.56;  % 7-bit (Purple)
    0.47, 0.67, 0.19   % 8-bit (Green)
];

for i = 1:length(b)
    b(i).FaceColor = customColors(i,:);
end

% --- AXES SETTINGS ---
max_y = max(max(Filled_Values));
ylim([0, max_y * 1.15]); % Slight headroom

set(gca, 'XTick', x);
set(gca, 'XTickLabel', logicNames);
set(gca, 'FontSize', 11);
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'Color', 'w');                 

xlabel('Approximation Logic', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Error Order (EO)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
title('Error Order (EO) Values Breakdown', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');

% --- REMOVE GRID ---
grid off;

% --- ULTRA-COMPACT LEGEND BOX (SCALED FOR EO) ---
bit_labels = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% Positioning Variables (Scaled relative to max_y)
box_x = 1.8;      
box_y = max_y * 1.12;       % Top of box near the max Y limit
box_w = 1.8;                % Width (X-axis units)
box_h = max_y * 0.18;       % Height relative to graph scale

% Draw the boundary box
rectangle('Position', [box_x, box_y - box_h, box_w, box_h], ...
    'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceColor', 'none'); 

% Internal Spacing (Scaled)
start_x = box_x + 0.1;        
start_y = box_y - (max_y * 0.02);         
row_spacing = max_y * 0.035;   % Vertical spacing between rows
patch_width = 0.12;            % X-axis units
patch_height = max_y * 0.015;  % Y-axis units
gap_small = 0.03;              
label_offset = 0.4;           

% Loop rows: 8-bit down to 4-bit
for bit_idx = 5:-1:1
    current_y = start_y - ((5 - bit_idx) * row_spacing);
    current_x = start_x;
    
    % 1. Label "X-bit :"
    text(current_x, current_y, [bit_labels{bit_idx} ':'], ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
    
    current_x = current_x + label_offset;
    
    % 2. Open Bracket "("
    text(current_x, current_y, '(', ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    
    current_x = current_x + 0.08;
    
    % 3. Draw Patches and '+' signs
    for layer = 1:bit_idx
        % Draw Square Patch
        rectangle('Position', [current_x, current_y - (patch_height/2), patch_width, patch_height], ...
            'FaceColor', customColors(layer, :), ...
            'EdgeColor', 'k', 'LineWidth', 0.5);
        
        current_x = current_x + patch_width + gap_small;
        
        % Draw '+' sign if not last
        if layer < bit_idx
             text(current_x, current_y, '+', ...
                'FontSize', 6, 'FontWeight', 'bold', 'Color', 'k', ...
                'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
             current_x = current_x + gap_small + 0.05;
        end
    end
    
    % 4. Closing Bracket ")"
    text(current_x + 0.02, current_y, ')', ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

% --- ADDING TEXT LABELS TO BARS ---
for i = 1:size(EO_Values, 1) 
    for j = 1:size(EO_Values, 2) 
        val_original = EO_Values(i, j);
        val_position = Filled_Values(i, j);
        
        if val_original > 0
            y_pos = val_position;
            x_pos = i + (barWidth / 2) + 0.02; 
            
            % Using %.0f for Integers
            txt_str = sprintf('%.0f', val_original);
            
            text(x_pos, y_pos, txt_str, ...
                'FontSize', 6, ...           
                'Color', 'r', ...            
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle'); 
        end
    end
end