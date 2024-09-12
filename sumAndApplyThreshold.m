function thresholdedSumMatrices = sumAndApplyThreshold(thresholdedMatrices, thresholdFraction, maxNumFrames, numBehaviors, timeInterval)

    numFramesPerInterval = getNumFramesPerInterval(timeInterval);

    numIntervals = ceil(maxNumFrames / numFramesPerInterval);

    % Initialize the output cell array
    numConditions = length(thresholdedMatrices);
    thresholdedSumMatrices = cell(numConditions, 1);
    
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
            
            % Ensure currentMatrix has at least maxNumFrames columns
            if currentNumIntervals < numIntervals
                % Pad currentMatrix with zeros to match maxNumFrames columns
                currentMatrix = [currentMatrix zeros(numBehaviors, numIntervals - currentNumIntervals)];
            end

            summedMatrix = summedMatrix + currentMatrix;
        end
        
        % Apply the threshold based on the number of movies
        threshold = thresholdFraction * numMovies;
        thresholdedMatrix = summedMatrix >= threshold;
        thresholdedSumMatrices{condIdx} = double(thresholdedMatrix);
    end
end
