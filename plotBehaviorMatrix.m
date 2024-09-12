% The labels order set manually
function plotBehaviorMatrix(colorPalette, matrix, behaviorLabels, x_label, plot_title)
    % Needed for the colors order
    matrix(:, end) = 1;

    desiredOrder = { 'Walk', 'Stop', 'Turn', 'Touch',...
        'Long Distance Approach', 'Short Distance Approach',...
        'Long Lasting Interaction',...
         'Social Clustering', 'Grooming', 'Song', 'Chain',...
         'Chase', 'Jump'};

    % Filter desiredOrder to include only behaviors present in behaviorLabels
    filteredDesiredOrder = desiredOrder(ismember(desiredOrder, behaviorLabels));

    % Find indices of behaviors in filteredDesiredOrder
    [~, idx] = ismember(filteredDesiredOrder, behaviorLabels);
    existingOrder = idx(idx > 0);

    % Find indices of behaviors in behaviorLabels that are not in filteredDesiredOrder
    remainingIdx = setdiff(1:length(behaviorLabels), existingOrder);
    
    % Combine the indices to create the final order
    finalOrder = [existingOrder, remainingIdx];
    
    % Reorder the matrix and behavior labels according to the final order
    reorderedMatrix = matrix(finalOrder, :);
    reorderedBehaviorLabels = behaviorLabels(finalOrder);

    % Scale each row's values by its index if they are greater than or equal to the threshold
    for i = 1:size(reorderedMatrix, 1)
        reorderedMatrix(i, reorderedMatrix(i, :) == 1) = i;
    end

    % % Remove the last column of the reordered matrix
    % % cheating for the minute ethogram
    % reorderedMatrix(:, end-1:end) = [];

    % Create a figure
    figure;
    
    imagesc(reorderedMatrix);
    
    happyColors = [
                255/255 255/255 255/255;  % White
                204/255 0/255   204/255;  % Medium Purple
                0/255   204/255 204/255;  % Cyan / Aqua
                255/255 102/255 0/255;    % Orange
                102/255 204/255 0/255;    % Lime Green
                204/255 0/255   0/255;    % Red
                102/255 0/255   204/255;  % Purple
                255/255 204/255 0/255;    % Yellow
                0/255   51/255  255/255;  % Bright Blue
                231/255 14/255  134/255;  % Hot Pink
                14/255  231/255 111/255;  % Mint Green
                231/255 111/255 14/255;   % Pumpkin Orange
                14/255  134/255 231/255;  % Light Blue
                79/255  44/255  27/255;   % Dark Brown
                ];

    % Ensure there are enough colors
    if strcmpi(colorPalette, 'Happy')
        if size(reorderedMatrix, 1) > size(happyColors, 1)
            happyColors = [happyColors; happyColors(2:end, :)]; % Repeat colors if needed
        end
        % Set the colormap
        colormap(happyColors(1:length(reorderedBehaviorLabels) + 1, :));
    elseif strcmpi(colorPalette, 'Rainbow')
        cmap = [1 1 1; jet(size(reorderedMatrix, 1))];
        colormap(cmap);
    else
       cmap = [1 1 1; jet(size(reorderedMatrix, 1))];
       colormap(cmap);
    end

    % Set common labels
    title(plot_title);
    xlabel(x_label);

    % Set y-axis ticks to show the behaviors
    yticks(1:size(reorderedMatrix, 1));
    yticklabels(reorderedBehaviorLabels);

    disp("Successfully plotted the behavior matrix.");
end
