function finalMatrices = conditionThresholds(thresholdedMatrices,...
    maxNumFrames, behaviorLabels, numBehaviors, timeInterval)
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);

    numIntervals = ceil(maxNumFrames / numFramesPerInterval);

    % Initialize the output cell array
    numConditions = length(thresholdedMatrices);
    finalMatrices = cell(numConditions, 1);
    
    % Loop through each condition
    for condIdx = 1:numConditions
        % Get the number of movies for the current condition
        numMovies = length(thresholdedMatrices{condIdx});
        
        % Sum all thresholded matrices for the current condition
        summedMatrix = zeros(numBehaviors, numIntervals);

        for movieIdx = 1:numMovies
            currentMatrix = thresholdedMatrices{condIdx}{movieIdx};

            % Add to summed matrix, adjusting for different frame counts
            [~, currentNumIntervals] = size(currentMatrix);
            
            % Ensure currentMatrix has at least numIntervals columns
            if currentNumIntervals < numIntervals
                % Pad currentMatrix with zeros to match numIntervals columns
                currentMatrix = [currentMatrix zeros(numBehaviors, numIntervals - currentNumIntervals)];
            end

            summedMatrix = summedMatrix + currentMatrix;
        end

        upper_quarter_values = quantile(summedMatrix, 0.75, 2);
        defaultThresholds = upper_quarter_values / numMovies;
        defaultThresholds(defaultThresholds < 0.3) = 0.3;

        normalizedMatrix = summedMatrix / numMovies;
        finalMatrices{condIdx} = applyThresholds(normalizedMatrix,...
            behaviorLabels, defaultThresholds, numBehaviors);
    end
end