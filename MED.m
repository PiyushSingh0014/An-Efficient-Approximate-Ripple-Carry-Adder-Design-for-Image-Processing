% Clear workspace
clc;
clear;
close all;

% --- DATA DEFINITION ---
MED_Values = [
    7.5,        15.5,        31.5,        63.5,        127.5;        % EAL1
    2.4375,     0.0,         9.9765625,   0.0,         40.053;       % EAL2
    1.75,       3.75,        7.75,        15.75,       31.75;        % EAL3
    2.875,      5.875,       11.875,      23.875,      47.875;       % EAL4
    4.46093,    9.125,       18.395,      36.890,      73.8510;      % EAL5
    5.51625,    11.1367,     22.3525,     44.76440,    89.573303;    % EAL6
    6.125,      12.26953125, 24.47949,    48.844726,   97.53948;     % EAL7
    5.3125,     10.65625,    21.328125,   42.6640625,  85.33203125;  % EAL8
    5.3125,     10.65625,    21.328125,   42.6640625,  85.33203125;  % EAL9
    3.5,        7.5,         15.5,        31.5,        63.5          % PAL
];

logicNames = {'EAL1', 'EAL2', 'EAL3', 'EAL4', 'EAL5', 'EAL6', 'EAL7', 'EAL8', 'EAL9', 'PAL'};

% --- DATA PROCESSING ---
Filled_Values = MED_Values;
for i = 1:size(Filled_Values, 1)
    for j = 2:size(Filled_Values, 2)
        if Filled_Values(i, j) == 0
            Filled_Values(i, j) = Filled_Values(i, j-1);
        end
    end
end

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
ylim([0, max_y * 1.1]); 

set(gca, 'XTick', x);
set(gca, 'XTickLabel', logicNames);
set(gca, 'FontSize', 11);
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'Color', 'w');                 

xlabel('Approximation Logic', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('MED (Mean Error Distance)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
title('MED Values', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');

% --- REMOVING GRID ---
grid off; % Completely remove dotted traces

% --- ULTRA-COMPACT LEGEND BOX ---
bit_labels = {'4-bit', '5-bit', '6-bit', '7-bit', '8-bit'};

% Legend Box Coordinates (Tight Fit)
box_x = 1.8;      
box_y = 138;      
box_w = 1.8;      % Very Narrow
box_h = 20;       % Very Short

% Draw the boundary box
rectangle('Position', [box_x, box_y - box_h, box_w, box_h], ...
    'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceColor', 'none'); 

% Internal Spacing (High Density)
start_x = box_x + 0.1;        
start_y = box_y - 2.5;         
row_spacing = 3.8;             % Very tight rows
patch_width = 0.12;            % Tiny square
patch_height = 2.0;            % Tiny square
gap_small = 0.03;              
label_offset = 0.4;           

% Loop rows: 8-bit down to 4-bit
for bit_idx = 5:-1:1
    current_y = start_y - ((5 - bit_idx) * row_spacing);
    current_x = start_x;
    
    % 1. Label "X-bit :"
    text(current_x, current_y, [bit_labels{bit_idx} ':'], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
    
    current_x = current_x + label_offset;
    
    % 2. Open Bracket "("
    text(current_x, current_y, '(', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
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
                'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k', ...
                'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
             current_x = current_x + gap_small + 0.05;
        end
    end
    
    % 4. Closing Bracket ")"
    text(current_x + 0.02, current_y, ')', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

% --- ADDING TEXT LABELS TO BARS ---
for i = 1:size(MED_Values, 1) 
    for j = 1:size(MED_Values, 2) 
        val_original = MED_Values(i, j);
        val_position = Filled_Values(i, j);
        
        if val_original > 0
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