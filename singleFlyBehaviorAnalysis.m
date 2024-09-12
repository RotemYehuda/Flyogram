function singleFlyBehaviorAnalysis(colorPalette, timeInterval, ratio)
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
    outputDir = fullfile(pwd, 'SingleFlyEthogram');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Call chooseFlyNumGUI function to get the fly number
    flyNum = chooseFlyNumGUI(numFlies);

    % Create a new directory for the current run based on fly number and time interval
    runDir = fullfile(outputDir, sprintf('flyNum%d_%s', flyNum, timeInterval));
    
    % If the directory exists, append a unique identifier
    if exist(runDir, 'dir')
        counter = 1;
        while exist(runDir, 'dir')
            runDir = fullfile(outputDir, sprintf('flyNum%d_%s(%d)', flyNum, timeInterval, counter));
            counter = counter + 1;
        end
    end
    
    % Create the directory
    mkdir(runDir);
        
    % Function to process and plot behavior for a single fly
    function processSingleFly(flyNum)
        % Create the combined scores matrix
        [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(filesNames, numBehaviors, flyNum);

        numFramesPerInterval = getNumFramesPerInterval(timeInterval);

        % Initialize matrix to store summed behavior scores per interval
        summedScoresPerInterval = calculateSummedScoresPerInterval(...
            combinedScoresMatrix, numBehaviors, numFrames, numFramesPerInterval);

        % Thresholding part for per second and per minute analyses
        if strcmp(timeInterval, 'Second') || strcmp(timeInterval, 'Minute')
            % Save the summedScoresPerInterval as a CSV file
            summedScoresMatrixFileName = fullfile(runDir, sprintf('fly%d_SummedScores_%s.csv', flyNum, timeInterval));
            writematrix(summedScoresPerInterval, summedScoresMatrixFileName);

            % Calculate the default thresholds
            defaultThresholds = adjustedThreshold(summedScoresPerInterval, ratio, numFramesPerInterval);
            
            defaultThresholdsTable = table(behaviorLabels, defaultThresholds, 'VariableNames', {'Behavior', 'Default threshold'});
            saveTableToCSV(runDir,  sprintf('fly%d_defaultThresholds_%s', flyNum, timeInterval), defaultThresholdsTable);
     
            normalizedBehaviorMat = summedScoresPerInterval / numFramesPerInterval;
            
            % Save the normalizedBehaviorMat as a CSV file
            normalizedBehaviorMatFileName = fullfile(runDir, sprintf('fly%d_normalizedMatrix_%s.csv', flyNum, timeInterval));
            writematrix(normalizedBehaviorMat, normalizedBehaviorMatFileName);

            % Call the threshold GUI function
            thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);
        
            finalThresholdsTable = table(behaviorLabels, thresholds, 'VariableNames', {'Behavior', 'Final threshold'});
            saveTableToCSV(runDir,  sprintf('fly%d_finalThresholds_%s', flyNum, timeInterval), finalThresholdsTable);
            
            % Apply thresholds
            binaryBehaviorMat = applyThresholds(...
                normalizedBehaviorMat, behaviorLabels, thresholds, numBehaviors);
        else
            binaryBehaviorMat = summedScoresPerInterval;
        end

        % Save the binaryBehaviorMat as a CSV file
        binaryBehaviorMatFileName = fullfile(runDir, sprintf('fly%d_binaryMatrix_%s.csv', flyNum, timeInterval));
        writematrix(binaryBehaviorMat, binaryBehaviorMatFileName);

        conditionName = strrep(condition,'_',' ');

        % Use the plotBehaviorMatrix function to visualize the common behavior per interval
        switch timeInterval
            case 'Frame'
                timeLabel = 'Frame';
                plotTitle = ['Single fly behavior per frame - ' conditionName ' FlyNum ' num2str(flyNum)];
            case 'Second'
                timeLabel = 'Time (sec)';
                plotTitle = ['Single fly behavior per second - '  conditionName ' FlyNum ' num2str(flyNum)];
            case 'Minute'
                timeLabel = 'Time (min)';
                plotTitle = ['Single fly behavior per minute - '  conditionName ' FlyNum ' num2str(flyNum)];
        end

        plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, timeLabel, plotTitle);

        % Set figure size and resolution
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, 0, 6, 5]);
        
        % Save the figure in PNG format with specified resolution
        saveas(gcf, fullfile(runDir, sprintf('FlyNum_%d_%s.png', flyNum, timeInterval)), 'png');
    end

    % Check if flyNum is 0, if so, plot for all flies
    if flyNum == 0
        for flyIdx = 1:numFlies
            processSingleFly(flyIdx);
        end
    else
        processSingleFly(flyNum);
    end
end
