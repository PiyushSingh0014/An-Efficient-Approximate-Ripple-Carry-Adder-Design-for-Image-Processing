% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
% Rows: Logic types (EAL1 to EAL9 + PAL)
% Columns: Bit Widths (4-bit, 5-bit, 6-bit, 7-bit, 8-bit)
ACC_Values = [
    31.64,    23.7304,  17.7978,  13.3483,   10.01129;   % EAL1
    18.75,    0,        7.0312,   0,         2.6367;     % EAL2
    42.1875,  31.64,    23.73,    17.7978,   13.33483;   % EAL3
    31.6406,  23.73,    17.797,   13.3483,   10.011;     % EAL4
    21.484,   14.06,    9.204,    6.02416,   3.9428;     % EAL5
    31.6406,  23.7304,  17.7978,  13.34838,  10.01129;   % EAL6
    6.25,     3.125,    1.5625,   0.78125,   0.390625;   % EAL7
    6.25,     3.125,    1.5625,   0.78125,   0.390625;   % EAL8
    6.25,     3.125,    1.5625,   0.78125,   0.390625;   % EAL9
    64.0625,  54.6875,  46.679,   39.84375,  34.0087     % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};

% --- DATA PROCESSING (INCREMENTAL LOGIC) ---
% 1. Reverse Columns: 8-bit (Smallest/Bottom) -> 4-bit (Largest/Top)
Filled_Values = fliplr(ACC_Values);

% 2. Fill missing 0 values (Gap Filling)
for i = 1:size(Filled_Values, 1)
    for j = 2:size(Filled_Values, 2)
        if Filled_Values(i, j) == 0
            Filled_Values(i, j) = Filled_Values(i, j-1);
        end
    end
end

% 3. Calculate Incremental Differences
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

% --- COLORS ---
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
max_y = max(max(Filled_Values));
ylim([0, max_y * 1.15]); 

set(gca, 'XTick', x);
set(gca, 'XTickLabel', logicNames);
set(gca, 'FontSize', 11);
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'Color', 'w');                 

xlabel('Approximation Logic', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Accuracy (%)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
title('Accuracy', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');

grid off;

% --- PROFESSIONAL COMPACT LEGEND BOX ---
legend_rows = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% Legend Coordinates
box_x = 1.8;      
box_y = max_y * 1.12;       
box_w = 1.8;                
box_h = max_y * 0.18;       

% Draw Boundary
rectangle('Position', [box_x, box_y - box_h, box_w, box_h], ...
    'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceColor', 'none'); 

% Spacing
start_x = box_x + 0.1;        
start_y = box_y - (max_y * 0.02);         
row_spacing = max_y * 0.035;   
patch_width = 0.12;            
patch_height = max_y * 0.015;  
gap_small = 0.03;              
label_offset = 0.4;           

% Draw Legend Items
for k = 1:5
    current_y = start_y - ((k-1) * row_spacing);
    current_x = start_x;
    
    % Label
    text(current_x, current_y, [legend_rows{k} ':'], ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
    
    current_x = current_x + label_offset;
    
    % Open Bracket
    text(current_x, current_y, '(', ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    
    current_x = current_x + 0.08;
    
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
    text(current_x + 0.02, current_y, ')', ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

% --- ADDING TEXT LABELS ---
original_flipped = fliplr(ACC_Values); % For referencing original values

for i = 1:size(Filled_Values, 1) % Rows
    for j = 1:size(Filled_Values, 2) % Columns
        
        val_position = Filled_Values(i, j);
        val_original = original_flipped(i, j);
        
        if val_original > 0
            y_pos = val_position;
            x_pos = i + (barWidth / 2) + 0.02; 
            
            txt_str = sprintf('%.2f', val_original);
            
            text(x_pos, y_pos, txt_str, ...
                'FontSize', 6, ...           
                'Color', 'r', ...            
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle'); 
        end
    end
end