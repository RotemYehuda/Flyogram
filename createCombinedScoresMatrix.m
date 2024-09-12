function [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(allBehaviors, numBehaviors, flyNum)
    % Load data for each behavior and extract postprocessed scores
    allScores = cell(1, numBehaviors);
    for behaviorIdx = 1:numBehaviors
        behaviorData = load(allBehaviors{behaviorIdx});
        allScores{behaviorIdx} = behaviorData.allScores.postprocessed{flyNum};
    end

    % Determine the number of frames
    numFrames = length(allScores{1});

    % Initialize a matrix to store the scores
    combinedScoresMatrix = zeros(numBehaviors, numFrames);

    % Convert each vector to a row in the matrix
    for behaviorIdx = 1:numBehaviors
        combinedScoresMatrix(behaviorIdx, :) = allScores{behaviorIdx};
    end
    disp("Successfully created matrix for all the behaviors.");
end