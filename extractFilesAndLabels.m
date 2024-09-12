function [filesNames, numBehaviors, behaviorLabels, condition, numFlies] = extractFilesAndLabels()
    % Select example scores file for extracting names
    expGroups = uipickfiles('Prompt', 'Select experiment scores file');
    [suggestedPath, ~, ~] = fileparts(expGroups{1});
    savePath = suggestedPath;

    % extract the condition name
    components = strsplit(savePath, '\');
    condition = components{end - 1};

    cd(savePath);
    scoresfileName = "scores_*.mat";
    d_scores = dir(scoresfileName);
    scoresfileName = {d_scores.name};
    filesNames = scoresfileName;

    % Determine the number of behaviors
    numBehaviors = numel(filesNames);

    % Extract behavior names without prefixes
    behaviorLabels = cell(numBehaviors, 1);
    for behaviorIdx = 1:numBehaviors
        behaviorLabels{behaviorIdx} = strrep(filesNames{behaviorIdx}, 'scores_', '');
        behaviorLabels{behaviorIdx} = strrep(behaviorLabels{behaviorIdx}, '.mat', '');
        behaviorLabels{behaviorIdx} = strrep(behaviorLabels{behaviorIdx}, '_', ' ');
    end

    % Capitalize behavior labels
    behaviorLabels = capitalizeBehaviorLabels(behaviorLabels);

    % Load one of the scores files to determine the number of flies
    scoresMatrix = load(filesNames{1}).allScores.postprocessed;

    numFlies = size(scoresMatrix, 2);

    disp("Successfully extracted files names and behavior labels.");
end

function capitalizedLabels = capitalizeBehaviorLabels(behaviorLabels)
    capitalizedLabels = cell(size(behaviorLabels)); % Initialize the output cell array
    for i = 1:length(behaviorLabels)
        words = strsplit(behaviorLabels{i}, ' '); % Split the label into words
        capitalizedWords = cellfun(@(word) [upper(word(1)), lower(word(2:end))], words, 'UniformOutput', false); % Capitalize each word
        capitalizedLabels{i} = strjoin(capitalizedWords, ' '); % Join the capitalized words back together
    end
end

