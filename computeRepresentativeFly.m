function representativeFlyMatrix = computeRepresentativeFly(conditionMatrix, singleFliesMatrices)
    numFlies = size(singleFliesMatrices, 2);

    % Initialize the loss array
    lossArray = zeros(1, numFlies);
    
    % Calculate the behavior probabilities
    behaviorProbabilities = calculateLossFunctionWeights(conditionMatrix);

    % Compute the loss for each single fly matrix
    for flyIdx = 1:numFlies
        singleFlyMatrix = singleFliesMatrices{flyIdx};
       
        % Pad the singleFlyMatrix with zeros if it has fewer columns
        if size(singleFlyMatrix, 2) < size(conditionMatrix, 2)
            paddingSize = size(conditionMatrix, 2) - size(singleFlyMatrix, 2);
            singleFlyMatrix = [singleFlyMatrix, zeros(size(singleFlyMatrix, 1), paddingSize)];
        end

        absDiff = abs(conditionMatrix - singleFlyMatrix);
        weightedAbsDiff = bsxfun(@times, absDiff, behaviorProbabilities);
        lossArray(flyIdx) = sum(weightedAbsDiff, 'all');
    end
    
    % Find the index with the minimum loss
    [~, minIndex] = min(lossArray);
    
    % Return the representative fly matrix and its index
    representativeFlyMatrix = singleFliesMatrices{minIndex};
end
