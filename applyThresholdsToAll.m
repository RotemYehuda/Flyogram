function thresholdedMatrices = applyThresholdsToAll(normalizesMatsCell, behaviorLabels, thresholds, numBehaviors)
    % Initialize the output cell array
    numConditions = length(normalizesMatsCell);
    thresholdedMatrices = cell(numConditions, 1);
    
    % Loop through each condition
    for condIdx = 1:numConditions
        % Get the number of movies for the current condition
        numMovies = length(normalizesMatsCell{condIdx});
        
        % Initialize cell array for the current condition's thresholded matrices
        thresholdedMatrices{condIdx} = cell(numMovies, 1);
        
        % Loop through each movie in the current condition
        for movieIdx = 1:numMovies
            % Get the normalized matrix for the current movie
            normalizedMatrix = normalizesMatsCell{condIdx}{movieIdx};
            
            % Apply the threshold to the normalized matrix
            thresholdedMatrix = applyThresholds(normalizedMatrix,...
                behaviorLabels, thresholds, numBehaviors);
            
            % Store the thresholded matrix
            thresholdedMatrices{condIdx}{movieIdx} = thresholdedMatrix;
        end
    end
end
