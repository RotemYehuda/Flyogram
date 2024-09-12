function conditionBehaviorAnalysis(colorPalette, timeInterval, ratio)
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
    [filesNames, numBehaviors, behaviorLabels, ~, ~] = extractFilesAndLabels();
      
    % Process experiment data
    allDataInTbl = processExperimentData(filesNames);
    
    % Group the data by the "condition" column
    groupedData = findgroups(allDataInTbl.condition);
        
    % Get unique conditions
    uniqueConditions = unique(allDataInTbl.condition, 'stable');

    conditionsThresholdMatrix = zeros(numBehaviors,length(uniqueConditions));
    
    % Initialize array to store number of movies for each condition
    numMoviesForEachCondition = zeros(length(uniqueConditions), 1);

    normalizedConditionsMats = cell(length(uniqueConditions), 1);

    maxNumFrames = 0;

    conditionDirs = createConditionDirectories(allDataInTbl, 'ConditionEthogram');
    
    % Get total movies
    totalMovies = length(unique(allDataInTbl.movie_number, 'stable'));
    
    % Loop over each unique condition and combining the data into one table
    for i = 1:length(uniqueConditions)
        % Filter data for the current condition
        conditionData = allDataInTbl(groupedData == i, :);
        
        % Group the data by the "movie_number" column
        groupedMovieData = findgroups(conditionData.movie_number);
        
        % Get unique movies
        uniqueMovies = unique(conditionData.movie_number, 'stable');

        numMoviesForEachCondition(i) = length(uniqueMovies);

        normalizedMoviesMats = cell(length(uniqueMovies), 1);
        moviesThresholdMatrix = zeros(numBehaviors,length(uniqueMovies));

        % Create a folder named 'conditionMovies' within the condition directory
        conditionMoviesDir = fullfile(conditionDirs{i}, 'moviesScoresMatrices');
        if ~exist(conditionMoviesDir, 'dir')
            mkdir(conditionMoviesDir);
        end
      
        % Loop over each unique movie and combining the data into one table
        for j = 1:length(uniqueMovies)
            % Filter data for the current movie
            movieData = conditionData(groupedMovieData == j, :);

            movieName = getMovieName(movieData.name_of_the_file{1});

            [combinedScoresMatrices, numFlies, maxFrames] = ...
                extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies);

            maxNumFrames = max([maxNumFrames, maxFrames]);

            summedScoresMatrixFileName = fullfile(conditionMoviesDir , sprintf('summedScoresMatrix_%s.csv', movieName));
            summedScoresPerIntervalFileName = fullfile(conditionMoviesDir, sprintf('summedScoresPer%s_%s.csv', timeInterval, movieName));
            normalizedMatFileName = fullfile(conditionMoviesDir, sprintf('normalizedMatPer%s_%s.csv', timeInterval, movieName));

            [defaultThresholds, normalizedBehaviorMat] = ...
                processMovieData(combinedScoresMatrices,...
                numBehaviors, maxFrames, numFlies,...
                timeInterval, ratio, summedScoresMatrixFileName,...
                summedScoresPerIntervalFileName, normalizedMatFileName);

            moviesThresholdMatrix(:, j) = defaultThresholds;
            normalizedMoviesMats{j} = normalizedBehaviorMat;
        end

        conditionsThresholdMatrix(:, i) = mean(moviesThresholdMatrix, 2);
        normalizedConditionsMats{i} = normalizedMoviesMats;        
        
        % Prepare column names
        movieNames = cellfun(@(x) getMovieName(x), conditionData.name_of_the_file, 'UniformOutput', false);
        uniqueMovieNames = unique(movieNames, 'stable');
        columnNames = [{'Behavior'}, uniqueMovieNames', {'avgThreshold'}];

        data = [behaviorLabels, num2cell(moviesThresholdMatrix), num2cell(conditionsThresholdMatrix(:, i))];
        
        % Convert the data to a table
        dataTable = cell2table(data, 'VariableNames', columnNames);
        for j = 1:length(conditionDirs)
            saveTableToCSV(conditionDirs{j}, sprintf('%s_thresholds', uniqueConditions{i}), dataTable);
        end
    end

    defaultThresholds = min(conditionsThresholdMatrix, [], 2);

    % Call the threshold GUI function
    thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);
    
    % Prepare column names
    defaultColumnNames = [{'Behavior'}, uniqueConditions', {'defaultThreshold'}];
    finalColumnNames = [{'Behavior'}, uniqueConditions', {'finalThreshold'}];

    defaultData = [behaviorLabels, num2cell(conditionsThresholdMatrix), num2cell(defaultThresholds)];
    finalData = [behaviorLabels, num2cell(conditionsThresholdMatrix), num2cell(thresholds)];

    % Convert the data to a table
    defaultThresholdsTable = cell2table(defaultData, 'VariableNames', defaultColumnNames);
    finalThresholdsTable = cell2table(finalData, 'VariableNames', finalColumnNames);
    
    for i = 1:length(conditionDirs)
        saveTableToCSV(conditionDirs{i}, sprintf('defaultThresholds_%s', timeInterval), defaultThresholdsTable);
        saveTableToCSV(conditionDirs{i}, sprintf('finalThresholds_%s', timeInterval), finalThresholdsTable);
    end 

    thresholdedMatrices = applyThresholdsToAll(normalizedConditionsMats,...
        behaviorLabels, thresholds, numBehaviors);

    finalMatrices = conditionThresholds(thresholdedMatrices,...
        maxNumFrames, behaviorLabels, numBehaviors, timeInterval);

    % Loop over each condition and plot the common behavior matrix
    for i = 1:length(uniqueConditions)
        tempConditionName = uniqueConditions{i};
        conditionName = strrep(tempConditionName,'_',' ');
        behaviorsMat =  finalMatrices{i};
        
        % Use the plotBehaviorMatrix function to visualize the common behavior per frame
        switch timeInterval
            case 'Frame'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Frame', ['Condition behavior per frame - ' conditionName]);
            case 'Second'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Second', ['Condition behavior per second - ' conditionName]);
            case 'Minute'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Minute', ['Condition behavior per minute - ' conditionName]);
        end

        % Set figure size and resolution
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, 0, 6, 5]);
        
        % Save the figure in PNG format with specified resolution
        for j = 1:length(conditionDirs)
            % Save the figure in PNG format with specified resolution
            saveas(gcf, fullfile(conditionDirs{j}, ['ConditionBehavior_' conditionName '.png']), 'png');
        end 
        
    end
end