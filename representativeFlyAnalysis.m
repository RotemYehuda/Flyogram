function representativeFlyAnalysis(colorPalette, timeInterval, ratio)
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

    conditionDirs = createConditionDirectories(allDataInTbl, 'representativeFlyEthogram');
    
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

        moviesThresholdMatrix = zeros(numBehaviors,length(uniqueMovies));
        normalizedMoviesMats = cell(length(uniqueMovies), 1);

        maxNumFrames = 0;

        singleFliesMatrices = [];

        % Create a folder named 'conditionMovies' within the condition directory
        conditionMoviesDir = fullfile(conditionDirs{i}, 'moviesScoresMatrices');
        if ~exist(conditionMoviesDir, 'dir')
            mkdir(conditionMoviesDir);
        end
        
        numFramesPerInterval = getNumFramesPerInterval(timeInterval);

        % Loop over each unique movie and combining the data into one table
        for j = 1:length(uniqueMovies)
            % Filter data for the current movie
            movieData = conditionData(groupedMovieData == j, :);

            movieName = getMovieName(movieData.name_of_the_file{1});

            [combinedScoresMatrices, numFlies, maxFrames] = ...
                extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies);

            singleFliesMatrices = [singleFliesMatrices, combinedScoresMatrices];

            maxNumFrames = max([maxNumFrames, maxFrames]);

            summedScoresMatrixFileName = fullfile(conditionMoviesDir , sprintf('summedScoresMatrix_%s.csv', movieName));
            summedScoresPerIntervalFileName = fullfile(conditionMoviesDir, sprintf('summedScoresPer%s_%s.csv', timeInterval, movieName));
            normalizedMatFileName = fullfile(conditionMoviesDir, sprintf('normalizedMatPer%s_%s.csv', timeInterval, movieName));

            [defaultThresholds, normalizedBehaviorMat] = ...
                processMovieData(combinedScoresMatrices,...
                numBehaviors, maxFrames, numFlies,...
                timeInterval, ratio,summedScoresMatrixFileName,...
                summedScoresPerIntervalFileName, normalizedMatFileName);

            moviesThresholdMatrix(:, j) = defaultThresholds;
            normalizedMoviesMats{j} = normalizedBehaviorMat;
        end

        conditionThresholds = mean(moviesThresholdMatrix, 2);

        % Prepare column names
        movieNames = cellfun(@(x) getMovieName(x), conditionData.name_of_the_file, 'UniformOutput', false);
        uniqueMovieNames = unique(movieNames, 'stable');
        columnNames = [{'Behavior'}, uniqueMovieNames', {'avgThreshold'}];

        data = [behaviorLabels, num2cell(moviesThresholdMatrix), num2cell(conditionThresholds)];
        
        % Convert the data to a table
        dataTable = cell2table(data, 'VariableNames', columnNames);
        saveTableToCSV(conditionDirs{i}, sprintf('%s_thresholds', uniqueConditions{i}), dataTable);

        thresholdedMoviesMats = cell(length(uniqueMovies), 1);
        for j = 1:length(uniqueMovies)
            thresholdedMoviesMats{j} = applyThresholds(normalizedMoviesMats{j},...
                behaviorLabels, conditionThresholds, numBehaviors);
        end

        conditionMatrix = computeGeneralConditionMat(thresholdedMoviesMats,...
            maxNumFrames, behaviorLabels, numBehaviors, timeInterval);

        if strcmp(timeInterval, 'Second') || strcmp(timeInterval, 'Minute')
            for matrixIdx = 1:length(singleFliesMatrices)
                singleFlyMatrix = singleFliesMatrices{matrixIdx};

                % Calculate summed scores per interval
                summedScoresPerInterval = calculateSummedScoresPerInterval(...
                    singleFlyMatrix, numBehaviors, size(singleFlyMatrix, 2), numFramesPerInterval);
                
                % Normalize by dividing by the number of frames per interval
                normalizedBehaviorMat = summedScoresPerInterval / numFramesPerInterval;
                
                singleFliesMatrices{matrixIdx} = applyThresholds(normalizedBehaviorMat,...
                    behaviorLabels, conditionThresholds, numBehaviors);
            end
        end

        representativeFlyMatrix = computeRepresentativeFly(conditionMatrix,...
            singleFliesMatrices);

        tempConditionName = uniqueConditions{i};
        conditionName = strrep(tempConditionName,'_',' ');

        % Use the plotBehaviorMatrix function to visualize the common behavior per frame
        switch timeInterval
            case 'Frame'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Frame', ['RepresentiveFly per frame - ' conditionName]);
            case 'Second'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Second', ['RepresentiveFly per second - ' conditionName]);
            case 'Minute'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Minute', ['RepresentiveFly per minute - ' conditionName]);
        end

        % Set figure size and resolution
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, 0, 6, 5]);

        % Save the figure in PNG format with specified resolution
        saveas(gcf, fullfile(conditionDirs{i}, ['RepresentiveFly_' conditionName '.png']), 'png');        
    end
end