function binaryBehaviorMat = applyThresholds(normalizedMatrix, behaviorLabels, thresholds, numBehaviors)
    % Create a structure to store behavior labels and their corresponding thresholds
    behaviorThresholds = struct();

    % Iterate over each behavior label and its corresponding adjusted threshold value
    for i = 1:numel(behaviorLabels)
        behaviorThresholds(i).label = behaviorLabels{i};
        behaviorThresholds(i).threshold = thresholds(i);
    end

    binaryBehaviorMat = normalizedMatrix;

    % Apply the thresholding operation using the adjusted thresholds
    for behaviorIdx = 1:numBehaviors
        % Get the adjusted threshold for the current behavior
        threshold = behaviorThresholds(behaviorIdx).threshold;

        % Apply the thresholding operation
        binaryBehaviorMat(behaviorIdx, binaryBehaviorMat(behaviorIdx, :) < threshold) = 0;
        binaryBehaviorMat(behaviorIdx, binaryBehaviorMat(behaviorIdx, :) >= threshold) = 1;
    end
end
