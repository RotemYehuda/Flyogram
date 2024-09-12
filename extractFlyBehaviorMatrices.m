function [combinedScoresMatrices, numFlies, maxFrames] = extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies)
    % Determine the number of flies
    numFlies = height(movieData);
    
    % Initialize a cell array to store combined scores matrices for each fly
    combinedScoresMatrices = cell(1, numFlies);
    
    maxFrames = 0;

    if totalMovies > 2
        % Loop through each fly to create and store the combined scores matrices
        for flyNum = 1:numFlies
            % Extract the behavior data for the current fly
            behaviorData = movieData{flyNum, 6:end};
    
            % Determine the number of frames from the first behavior vector
            numFrames = numel(behaviorData{1});
    
            % Update total frames
            if numFrames > maxFrames
                maxFrames = numFrames;
            end
    
            % Initialize the matrix for the current fly
            combinedScoresMatrix = zeros(numBehaviors, numFrames);
            
            % Populate the matrix with behavior vectors
            for behaviorIdx = 1:numBehaviors
                combinedScoresMatrix(behaviorIdx, :) = behaviorData{behaviorIdx};
            end
            
            % Store the matrix in the cell array
            combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        end
    else
        % Loop through each fly to create and store the combined scores matrices
        for flyNum = 1:numFlies
            % Preallocate cell array to store individual behavior vectors
            behaviorData = cell(1, numBehaviors);

            % Iterate through each behavior to extract its vector
            for behaviorIdx = 1:numBehaviors
                % Extract the behavior vector for the current fly and behavior index
                behaviorData{behaviorIdx} = movieData{flyNum, 5 + behaviorIdx};
            end
    
            % Determine the number of frames from the first behavior vector
            numFrames = numel(behaviorData{1});
    
            % Update total frames
            if numFrames > maxFrames
                maxFrames = numFrames;
            end
    
            % Initialize the matrix for the current fly
            combinedScoresMatrix = zeros(numBehaviors, numFrames);
            
            % Populate the matrix with behavior vectors
            for behaviorIdx = 1:numBehaviors
                combinedScoresMatrix(behaviorIdx, :) = behaviorData{behaviorIdx};
            end
            
            % Store the matrix in the cell array
            combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        end
    end

    disp("Successfully created combined scores matrices for all flies.");
end
