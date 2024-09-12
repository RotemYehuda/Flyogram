function movieBehaviorAnalysis(colorPalette, timeInterval, ratio)
    % Set default value for colorPalette
    if nargin < 1
        colorPalette = 'Happy';
    end
    
    % Set default value for timeInterval
    if nargin < 2
        timeInterval = 'Frame';
    end
    
    % Set default value for ratio
    if nargin < 3
        ratio = 0.75;
    end
    
    addpath("W:\rotem and daniel BioProject\plotScripts\functions")
    
    % Call the combined function to get file names and behavior labels
    [filesNames, numBehaviors, behaviorLabels, condition, numFlies] = extractFilesAndLabels();
    
    % Create 'etogram' folder in the current directory
    outputDir = fullfile(pwd, 'MovieEthogram');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Create a new directory for the current run based on fly number and time interval
    runDir = fullfile(outputDir, sprintf('moviePer%s', timeInterval));
    
    if isfolder(runDir)
        rmdir(runDir, 's');
    end
    mkdir(runDir);

    % Initialize a cell array to store combined scores matrices
    combinedScoresMatrices = cell(1, numFlies);  
    maxFrames = 0;

    % Loop through each fly to create and store the combined scores matrices
    for flyNum = 1:numFlies
        % Create the combined scores matrix for the current fly
        [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(...
            filesNames, numBehaviors, flyNum);
        
        % Store the combined scores matrix in the cell array
        combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        
        % Update total frames
        if numFrames > maxFrames
            maxFrames = numFrames;
        end
    end
    
    summedScoresMatrixFileName = fullfile(runDir, 'summedScoresMatrix.csv');
    summedScoresPerIntervalFileName = fullfile(runDir, sprintf('summedScoresPer%s.csv', timeInterval));
    normalizedMatFileName = fullfile(runDir, sprintf('normalizedMat%s.csv', timeInterval));

    [defaultThresholds, normalizedBehaviorMat] = ...
        processMovieData(combinedScoresMatrices, numBehaviors,...
        maxFrames, numFlies, timeInterval, ratio, summedScoresMatrixFileName, summedScoresPerIntervalFileName, normalizedMatFileName);

    % Convert the data to a table
    defaultThresholdsTable = table(behaviorLabels, defaultThresholds, 'VariableNames', {'Behavior', 'Default threshold'});
    saveTableToCSV(runDir,  sprintf('defaultThresholds_%s', timeInterval), defaultThresholdsTable);

    % Call the threshold GUI function
    thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);

    finalThresholdsTable = table(behaviorLabels, thresholds, 'VariableNames', {'Behavior', 'Final threshold'});
    saveTableToCSV(runDir,  sprintf('finalThresholds_%s', timeInterval), finalThresholdsTable);

    % Apply thresholds
    binaryBehaviorMat = applyThresholds(...
        normalizedBehaviorMat, behaviorLabels, thresholds, numBehaviors);

    % Save binaryBehaviorMat as a CSV file
    binaryBehaviorMatFileName = fullfile(runDir, sprintf('binaryBehaviorMat_%s.csv', timeInterval));
    writematrix(binaryBehaviorMat, binaryBehaviorMatFileName);
    
    conditionName = strrep(condition,'_',' ');
    % Plotting
    switch timeInterval
        case 'Frame'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Frame',...
                ['Total movie behavior per frame- ' conditionName]);
        case 'Second'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Time (sec)',...
                ['Total movie behavior per second- ' conditionName]);
        case 'Minute'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Time(min)',...
                ['Total movie behavior per minute- ' conditionName]);
    end

    % Set figure size and resolution
    set(gcf, 'Units', 'inches');
    set(gcf, 'Position', [0, 0, 6, 5]);
    
    % Save the figure in PNG format with specified resolution
    saveas(gcf, fullfile(runDir, sprintf('MovieBehavior_%s_%s.png', condition, timeInterval)), 'png');
end