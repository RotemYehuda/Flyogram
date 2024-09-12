function summedScoresPerInterval = calculateSummedScoresPerInterval(combinedScoresMatrix, numBehaviors, numFrames, numFramesPerInterval)
    % Determine the number of intervals
    numIntervals = ceil(numFrames / numFramesPerInterval);
    
    % Initialize matrix to store summed behavior scores per interval
    summedScoresPerInterval = zeros(numBehaviors, numIntervals);
    
    % Loop over each interval
    for intervalIdx = 1:numIntervals
        % Define start and end frames for the current interval
        startFrame = (intervalIdx - 1) * numFramesPerInterval + 1;
        endFrame = min(intervalIdx * numFramesPerInterval, numFrames);
    
        % Extract scores for the current interval for each behavior
        scoresInterval = combinedScoresMatrix(:, startFrame:endFrame);
    
        % Sum the scores for each behavior for the current interval
        summedScoresPerInterval(:, intervalIdx) = sum(scoresInterval, 2);
    end
end
