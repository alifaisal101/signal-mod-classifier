clc;
clear;

% Define architecture
layers_info = {
    'Input', '128x128x1';  
    'Conv1 + BN + ReLU + MaxPool', '16 filters';  
    'Conv2 + BN + ReLU + MaxPool', '32 filters';
    'Conv3 + BN + ReLU + MaxPool', '64 filters';  
};

% Visual settings
blockWidth = 4;
blockHeight = 1.2;
spacing = 2;
xCenter = 5;

figure;
hold on;
axis off;
set(gcf, 'Color', 'w');

% Draw conv blocks
yPositions = zeros(size(layers_info, 1), 1);

for i = 1:size(layers_info, 1)
    yPos = -i * (blockHeight + spacing);
    yPositions(i) = yPos;

    rectangle('Position', [xCenter - blockWidth/2, yPos, blockWidth, blockHeight], ...
              'FaceColor', [0.6, 0.8, 1], 'EdgeColor', 'b', 'LineWidth', 2);
    
    text(xCenter, yPos + 0.75, layers_info{i, 1}, ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');

    text(xCenter, yPos + 0.3, layers_info{i, 2}, ...
         'HorizontalAlignment', 'center', 'FontSize', 8);
end

% Connect layers with arrows
for i = 1:(length(yPositions) - 1)
    xArrow = xCenter;
    yStart = yPositions(i) - 0.1;
    yEnd = yPositions(i+1) + blockHeight + 0.1;
    plot([xArrow xArrow], [yStart yEnd], 'k-', 'LineWidth', 1.5);
    plot(xArrow, yEnd, 'kv', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
end

% === Fully Connected Layer (Neuron Circles) ===
fc_y = yPositions(end) - spacing - 1;
num_fc_neurons = 6;
radius = 0.2;
x_spacing = 0.7;

for i = 1:num_fc_neurons
    x = xCenter - (num_fc_neurons/2)*x_spacing + (i-0.5)*x_spacing;
    rectangle('Position', [x - radius, fc_y, radius*2, radius*2], ...
              'Curvature', [1, 1], 'EdgeColor', 'm', 'LineWidth', 2);
end

text(xCenter, fc_y + radius*2 + 0.3, 'Fully Connected Layer', 'HorizontalAlignment', 'center', 'FontSize', 9);

% Arrow from last conv block to FC
xArrow = xCenter;
yStart = yPositions(end) - 0.1;
yEnd = fc_y + radius*2 + 0.1;
plot([xArrow xArrow], [yStart yEnd], 'k-', 'LineWidth', 1.5);
plot(xArrow, yEnd, 'kv', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

% === Output Layer (Classes) ===
output_y = fc_y - spacing;
num_classes = 6;

for i = 1:num_classes
    x = xCenter - (num_classes/2)*x_spacing + (i-0.5)*x_spacing;
    rectangle('Position', [x - radius, output_y, radius*2, radius*2], ...
              'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 2);
    text(x, output_y - 0.25, sprintf('Class %d', i), 'HorizontalAlignment', 'center', 'FontSize', 7);
end

text(xCenter, output_y + radius*2 + 0.3, 'Output Layer (Softmax)', 'HorizontalAlignment', 'center', 'FontSize', 9);

% Arrow from FC to output
plot([xCenter xCenter], [fc_y - 0.1 output_y + radius*2 + 0.1], 'k-', 'LineWidth', 1.5);
plot(xCenter, output_y + radius*2 + 0.1, 'kv', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

% Save as image
saveas(gcf, 'hybrid_network_diagram.png');
fprintf('✅ Saved hybrid CNN + neuron-style diagram as "hybrid_network_diagram.png"\n');
