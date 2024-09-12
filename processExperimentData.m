function allDatainTbl = processExperimentData(allBehaviors)
    % Generate experiment tables from folders
    expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
    [suggestedPath, ~, ~] = fileparts(expGroups{1});
    savePath = suggestedPath;
    numOfGroups = length(expGroups);

    groupNameDir = expGroups';
    NumberofMovie = {1:numOfGroups}';
    condition = {};

    for j = 1:numOfGroups
        fileNamePath = groupNameDir(j); % all path file name
        findStr = strfind(fileNamePath, "\"); % search for a specific str to extract conditionName
        findStr = cell2mat(findStr);
        vecLen = length(findStr);
        char_fileNamePath = char(fileNamePath);
        condition{j} = char_fileNamePath(findStr(vecLen - 1) + 1:findStr(vecLen) - 1);
        if strfind(char_fileNamePath, "Male")
            sex{j} = "Males";
        elseif strfind(char_fileNamePath, "Female")
            sex{j} = "Females";
        else
            sex{j} = [];
        end

        NumberofMovie{j} = j;
    end

    condition = condition';
    sex = sex';
    NumberofMovie = NumberofMovie';

    experimentTables = table(groupNameDir, NumberofMovie, condition, sex);

    % Process behaviors using experiment tables and behavior names
    counter = 0;
    cellBehavior = cell(0, 5 + length(allBehaviors));

    for numberMovie = 1:numOfGroups
        name_of_the_file = char(experimentTables{numberMovie, 1});
        name_of_the_condition = experimentTables{numberMovie, 3};
        number_of_movie = experimentTables{numberMovie, 2};

        cd(name_of_the_file)

        for jj = 1:length(allBehaviors)
            load(cell2mat(allBehaviors(jj)))
            ii = length(allScores.postprocessed);

            for numFly = 1:ii
                behaviorPerFileScore = allScores.postprocessed{1, numFly};
                cellBehavior{numFly + counter, 1} = numFly;
                cellBehavior{numFly + counter, 2} = name_of_the_file;
                cellBehavior{numFly + counter, 3} = numberMovie;
                cellBehavior{numFly + counter, 4} = char(experimentTables.sex{numberMovie});
                cellBehavior{numFly + counter, 5} = name_of_the_condition;
                cellBehavior{numFly + counter, jj + 5} = behaviorPerFileScore;
            end
        end

        counter = counter + ii;
    end

    % Process behavior data to create a table
    Title_old = ["fly", "name_of_the_file", "movie_number", "sex", "condition"];
    TitleNames = [Title_old, allBehaviors]; 
    TitleNames = regexprep(TitleNames, '.mat', '');
    allDatainTbl = cell2table(cellBehavior, 'VariableNames', TitleNames);

    % Check if the conditions contain digits and sort accordingly
    conditionNumeric = regexp(allDatainTbl.condition, '\d+', 'match');
    conditionHasDigits = ~cellfun('isempty', conditionNumeric);

    if any(conditionHasDigits)
        % Extract numeric part of condition and sort table
        conditionNumeric = cellfun(@(x) str2double(x{1}), conditionNumeric(conditionHasDigits));
        sortedConditionIdx = find(conditionHasDigits);
        [~, sortIdx] = sort(conditionNumeric);
        sortedIdx = sortedConditionIdx(sortIdx);
        allDatainTbl = allDatainTbl([sortedIdx; find(~conditionHasDigits)], :);
    end

    disp("Successfully processed the experiment data.");
end
