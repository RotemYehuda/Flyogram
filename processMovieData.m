function [defaultThresholds, normalizedBehaviorMat] = processMovieData(...
    combinedScoresMatrices, numBehaviors,...
    maxFrames, numFlies, timeInterval,...
    ratio, summedScoresfileName, summedScoresPerIntervalFileName, normalizedMatFileName)

    % Initialize the summed combined scores matrix
    summedScoresMatrix = zeros(numBehaviors, maxFrames);

    % Sum the combined scores matrices
    for flyNum = 1:numFlies
        summedScoresMatrix = summedScoresMatrix + combinedScoresMatrices{flyNum};
    end

    % Save the summedScoresMatrix as a CSV file
    writematrix(summedScoresMatrix, summedScoresfileName);

    numFramesPerInterval = getNumFramesPerInterval(timeInterval);
    
    % Calculate the number of frames per interval times the number of flies
    RF = numFramesPerInterval * numFlies;
    
    % Initialize matrix to store summed behavior scores per interval
    summedScoresPerInterval = calculateSummedScoresPerInterval(...
        summedScoresMatrix, numBehaviors, maxFrames, numFramesPerInterval);

    % Save the summedScoresPerInterval as a CSV file
    writematrix(summedScoresPerInterval, summedScoresPerIntervalFileName);

    % Calculate the default thresholds 
    defaultThresholds = adjustedThreshold(summedScoresPerInterval, ratio, RF);

    % Normalize the behavior matrix
    normalizedBehaviorMat = summedScoresPerInterval / RF;
    writematrix(normalizedBehaviorMat, normalizedMatFileName);
end
