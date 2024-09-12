function conditionMatrix = computeGeneralConditionMat(thresholdedMats,...
    maxNumFrames, behaviorLabels, numBehaviors, timeInterval)
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);   

    numIntervals = ceil(maxNumFrames / numFramesPerInterval); 

    % Get the number of movies for the current condition
    numMovies = length(thresholdedMats);
    
    % Sum all thresholded matrices for the current condition
    summedMatrix = zeros(numBehaviors, numIntervals);

    for movieIdx = 1:numMovies
        currentMatrix = thresholdedMats{movieIdx};

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
        conditionMatrix = applyThresholds(normalizedMatrix,...
            behaviorLabels, defaultThresholds, numBehaviors);

end