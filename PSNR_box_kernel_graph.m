% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
% Rows: Logic types (EAL1 to EAL9 + PAL)
% Columns: Bit Widths (4-bit, 5-bit, 6-bit, 7-bit, 8-bit)
PSNR_Values = [
    27.20,  23.06,  17.09,  12.78,  6.13;   % EAL1
    29.07,  0.0,    23.74,  0.0,    13.71;  % EAL2
    29.07,  27.59,  23.72,  17.77,  13.42;  % EAL3
    29.50,  28.58,  24.87,  17.32,  13.32;  % EAL4
    26.82,  22.41,  16.29,  11.26,  5.15;   % EAL5
    29.44,  28.16,  23.99,  17.26,  13.12;  % EAL6
    29.44,  28.23,  24.41,  21.68,  12.10;  % EAL7
    29.11,  27.25,  22.86,  14.64,  8.47;   % EAL8
    27.98,  24.88,  20.07,  13.23,  7.20;   % EAL9
    28.88,  27.16,  23.23,  17.32,  13.24   % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};

% --- DATA PROCESSING (INCREMENTAL LOGIC) ---
% 1. Reverse Columns: 8-bit (Smallest/Bottom) -> 4-bit (Largest/Top)
Filled_Values = fliplr(PSNR_Values);

% 2. Fill missing 0 values (Gap Filling)
%    If a value is 0, carry over the previous value so the graph doesn't dip.
for i = 1:size(Filled_Values, 1)
    for j = 2:size(Filled_Values, 2)
        if Filled_Values(i, j) == 0
            Filled_Values(i, j) = Filled_Values(i, j-1);
        end
    end
end

% 3. Calculate Incremental Differences for Stacking
Plot_Data = zeros(size(Filled_Values));
Plot_Data(:, 1) = Filled_Values(:, 1); % Base (8-bit)
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

% --- COLORS (Stack Order) ---
% 1 (Bottom): 8-bit (Green) -> ... -> 5 (Top): 4-bit (Blue)
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
% Calculate Max Y based on the filled values (since that represents total height)
max_y = max(max(Filled_Values));
% Increase Y-limit to create empty space at top-left for the legend
ylim([0, max_y * 1.40]); 

set(gca, 'XTick', x);
set(gca, 'XTickLabel', logicNames);
set(gca, 'FontSize', 11);
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'Color', 'w');                 

xlabel('Approximation Logic', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('PSNR value of Original i/p image v/s o/p image of box kernel (dB)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('PSNR COMPARISON (BOX KERNEL)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');

% --- REMOVE GRID ---
grid off;

% --- PROFESSIONAL COMPACT LEGEND BOX ---
legend_rows = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% Legend Coordinates (Positioned in new empty space at Top-Left)
box_x = 0.6;                 % Far left
box_y = max_y * 1.38;        % High up
box_w = 1.8;                 % Compact Width
box_h = max_y * 0.22;        % Compact Height

% Draw Boundary
rectangle('Position', [box_x, box_y - box_h, box_w, box_h], ...
    'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceColor', 'none'); 

% Spacing
start_x = box_x + 0.1;        
start_y = box_y - (max_y * 0.025);         
row_spacing = max_y * 0.04;   
patch_width = 0.12;            
patch_height = max_y * 0.02;  
gap_small = 0.03;              
label_offset = 0.4;           

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
    
    current_x = current_x + 0.08;
    
    % Draw Patches (Bottom-Up order: Green first)
    % 4-bit (k=1) includes layers 1-5. 8-bit (k=5) includes layer 1.
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
    text(current_x + 0.02, current_y, ')', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

% --- ADDING TEXT LABELS ---
% Use the flipped original values to match the stack order
original_flipped = fliplr(PSNR_Values);

for i = 1:size(Filled_Values, 1) % Rows
    for j = 1:size(Filled_Values, 2) % Columns
        
        val_position = Filled_Values(i, j);
        val_original = original_flipped(i, j);
        
        if val_original > 0
            % Text at the TOP BOUNDARY of the cumulative stack
            y_pos = val_position;
            
            x_pos = i + (barWidth / 2) + 0.02; 
            
            txt_str = sprintf('%.2f', val_original);
            
            text(x_pos, y_pos, txt_str, ...
                'FontSize', 10, ...           
                'Color', 'r', ...            
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle'); 
        end
    end
end