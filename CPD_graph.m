% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
% Rows: Logic types (EAL1 to EAL9 + PAL)
% Columns: Bit Widths (4-bit, 5-bit, 6-bit, 7-bit, 8-bit)
CPD_Values = [
    513, 441, 369, 298, 226;  % EAL1
    584, 0,   441, 0,   298;  % EAL2
    584, 513, 441, 369, 298;  % EAL3
    584, 513, 441, 369, 298;  % EAL4
    752, 726, 700, 674, 648;  % EAL5
    568, 496, 424, 352, 281;  % EAL6
    739, 710, 680, 651, 622;  % EAL7
    713, 684, 655, 626, 597;  % EAL8
    568, 496, 424, 352, 281;  % EAL9
    584, 513, 441, 369, 298   % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};

% --- DATA PROCESSING (INCREMENTAL LOGIC) ---
% 1. Reverse Columns: 8-bit (Smallest/Bottom) -> 4-bit (Largest/Top)
Filled_Values = fliplr(CPD_Values);

% 2. Fill missing 0 values (Gap Filling)
for i = 1:size(Filled_Values, 1)
    for j = 2:size(Filled_Values, 2)
        if Filled_Values(i, j) == 0
            Filled_Values(i, j) = Filled_Values(i, j-1);
        end
    end
end

% 3. Calculate Incremental Differences
%    (Next Layer - Previous Layer)
Plot_Data = zeros(size(Filled_Values));
Plot_Data(:, 1) = Filled_Values(:, 1); % Base (8-bit)
for j = 2:size(Filled_Values, 2)
    diff = Filled_Values(:, j) - Filled_Values(:, j-1);
    % Clamp negative differences to 0 to prevent graph errors
    Plot_Data(:, j) = max(diff, 0); 
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

% --- COLORS (Stack Order) ---
% 1 (Bottom): 8-bit (Green) ... 5 (Top): 4-bit (Blue)
customColors = [
    0.47, 0.67, 0.19;  % 1: 8-bit (Green) - BOTTOM
    0.49, 0.18, 0.56;  % 2: 7-bit (Purple)
    0.93, 0.69, 0.13;  % 3: 6-bit (Yellow)
    0.85, 0.33, 0.10;  % 4: 5-bit (Orange)
    0.00, 0.45, 0.74   % 5: 4-bit (Blue)  - TOP
];

for i = 1:length(b)
    b(i).FaceColor = customColors(i,:);
end

% --- AXES SETTINGS ---
% Calculate Max Y based on Filled_Values (Total Height)
max_y = max(max(Filled_Values));

% Increase Y-limit to create empty space at top-left for the legend
ylim([0, max_y * 1.35]); 

set(gca, 'XTick', x);
set(gca, 'XTickLabel', logicNames);
set(gca, 'FontSize', 11);
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'Color', 'w');                 

xlabel('Approximation Logic', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Critical Path Delay (ps)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
title('Critical Path Delay (CPD)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');

% --- REMOVE GRID ---
grid off;

% --- PROFESSIONAL COMPACT LEGEND BOX ---
legend_rows = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% Legend Coordinates (Top-Left Area)
box_x = 0.6;                 
box_y = max_y * 1.32;        
box_w = 2.9;                 % Wide enough to fit everything
box_h = max_y * 0.22;        

% Draw Boundary
rectangle('Position', [box_x, box_y - box_h, box_w, box_h], ...
    'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceColor', 'none'); 

% Spacing
start_x = box_x + 0.1;        
start_y = box_y - (max_y * 0.025);         
row_spacing = max_y * 0.04;   
patch_width = 0.25;            
patch_height = max_y * 0.02;  
gap_small = 0.05;              
label_offset = 0.6;           

% Draw Legend Items
for k = 1:5
    current_y = start_y - ((k-1) * row_spacing);
    current_x = start_x;
    
    % Label
    text(current_x, current_y, [legend_rows{k} ':'], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
    
    current_x = current_x + label_offset;
    
    % Open Bracket
    text(current_x, current_y, '(', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    
    current_x = current_x + 0.1;
    
    % Draw Patches
    layers_to_draw = 6 - k; 
    
    for layer = 1:layers_to_draw
        rectangle('Position', [current_x, current_y - (patch_height/2), patch_width, patch_height], ...
            'FaceColor', customColors(layer, :), ...
            'EdgeColor', 'k', 'LineWidth', 0.5);
        
        current_x = current_x + patch_width + gap_small;
        
        % '+' Sign
        if layer < layers_to_draw
             text(current_x, current_y, '+', ...
                'FontSize', 6, 'FontWeight', 'bold', 'Color', 'k', ...
                'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
             current_x = current_x + gap_small + 0.05;
        end
    end
    
    % Closing Bracket
    text(current_x + 0.05, current_y, ')', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

% --- ADDING TEXT LABELS ---
original_flipped = fliplr(CPD_Values);
cumulative_stack = cumsum(Plot_Data, 2); 

for i = 1:size(Plot_Data, 1) % Rows
    for j = 1:size(Plot_Data, 2) % Columns
        
        val_original = original_flipped(i, j);
        val_position = cumulative_stack(i, j); 
        
        if val_original > 0
            % Text at the TOP BOUNDARY
            y_pos = val_position;
            x_pos = i + (barWidth / 2) + 0.02; 
            
            % Using %.0f for Integers
            txt_str = sprintf('%.0f', val_original);
            
            text(x_pos, y_pos, txt_str, ...
                'FontSize', 10, ...           
                'Color', 'r', ...            
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle'); 
        end
    end
end