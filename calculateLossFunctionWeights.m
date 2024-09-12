function behaviorProbabilities = calculateLossFunctionWeights(conditionMatrix)
    % Sum each row to get the count of occurrences of each behavior
    behaviorCounts = sum(conditionMatrix, 2);

    % Sum the entire matrix to get the total number of occurrences of all behaviors
    totalOccurrences = sum(conditionMatrix(:));

    % Calculate the probability for each behavior
    behaviorProbabilities = behaviorCounts / totalOccurrences;
end
