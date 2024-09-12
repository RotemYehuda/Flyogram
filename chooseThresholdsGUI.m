function thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds)
    % Number of behaviors
    numBehaviors = length(behaviorLabels);

    % Define fixed dimensions for the figure and components
    figWidth = 400;
    figHeightNoScroll = 60 + numBehaviors * 30 + 50;  % Height without scrolling
    maxVisibleBehaviors = 13;
    
    % Determine if scrolling is needed
    if numBehaviors > maxVisibleBehaviors
        % Calculate height for scrolling
        figHeight = 60 + maxVisibleBehaviors * 30 + 50; % Fixed height with scrolling
        useScroll = true;
    else
        % No scrolling needed
        figHeight = figHeightNoScroll;
        useScroll = false;
    end

    % Create a figure window for the dialog
    fig = uifigure('Name', 'Select Thresholds', 'Position', [100, 100, figWidth, figHeight]);
    
    % Add title at the top of the figure
    titleLabel = uilabel(fig, 'Text', 'Select Thresholds', 'FontSize', 16, 'FontWeight', 'bold', ...
                         'Position', [140, figHeight - 35, figWidth - 20, 30]);

    % Create a panel for content
    if useScroll
        % Create a scrollable panel with fixed width
        scrollPanel = uipanel(fig, 'Position', [10, 60, figWidth - 20, figHeight - 70], 'Scrollable', 'on', ...
                              'BorderType', 'none');

        % Create a uipanel to hold the scrollable content
        contentPanel = uipanel(scrollPanel, 'Position', [0, 0, figWidth - 20, numBehaviors * 30 + 20], ...
                               'BorderType', 'none');
    else
        contentPanel = uipanel(fig, 'Position', [10, 60, figWidth - 20, numBehaviors * 30 + 20], ...
                               'BorderType', 'none');
    end

    % Create edit fields and labels dynamically
    editFields = gobjects(numBehaviors, 1);
    labels = gobjects(numBehaviors, 1);
    for i = 1:numBehaviors
        % Create a label for each behavior
        labels(i) = uilabel(contentPanel, 'Text', behaviorLabels{i}, 'HorizontalAlignment', 'right', ...
                            'Position', [10, numBehaviors * 30 - i * 30 + 10, 150, 22]);

        % Create an edit field for each threshold
        editFields(i) = uieditfield(contentPanel, 'numeric', 'Limits', [0, 1], 'Value', defaultThresholds(i), ...
                                    'Position', [170, numBehaviors * 30 - i * 30 + 10, 100, 22]);
    end

    % Calculate the positions for the OK and Cancel buttons
    buttonWidth = 100;
    buttonHeight = 30;
    figWidth = fig.Position(3);
    startX = (figWidth - (2 * buttonWidth + 10)) / 2; % 10 is space between buttons

    % Create OK and Cancel buttons
    okBtn = uibutton(fig, 'push', 'Text', 'OK', 'Position', [startX, 10, buttonWidth, buttonHeight], ...
                     'ButtonPushedFcn', @(btn, event) onOkButtonPressed(fig, editFields));
    cancelBtn = uibutton(fig, 'push', 'Text', 'Cancel', 'Position', [startX + buttonWidth + 10, 10, buttonWidth, buttonHeight], ...
                         'ButtonPushedFcn', @(btn, event) onCancelButtonPressed(fig));

    % Wait for the figure to close
    uiwait(fig);
    
    % Nested functions to handle button actions
    function onOkButtonPressed(fig, editFields)
        % Collect thresholds from edit fields
        thresholds = arrayfun(@(ef) ef.Value, editFields);
        % Validate inputs
        validInputs = ~isnan(thresholds) & thresholds >= 0.0 & thresholds <= 1.0;
        thresholds(~validInputs) = 0.5;  % Set invalid inputs to default value (0.5)
        if any(~validInputs)
            uialert(fig, 'Invalid input(s). Default number 0.5 was chosen for invalid threshold(s).', 'Warning');
        end

        uiresume(fig);  % Resume the UI to return the thresholds
        delete(fig);  % Close the figure
    end

    function onCancelButtonPressed(fig)
        delete(fig);  % Close the figure
        return;
    end
end
