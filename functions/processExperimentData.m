function allDatainTbl = processExperimentData(allBehaviors)
    % This function processes experiment data by allowing the user to select
    % multiple folders for each experimental group, assign a name to each group,
    % and then extract and compile behavior data from those folders.
    %
    % Inputs:
    % - allBehaviors: A cell array containing the file names of behavior data.
    %
    % Output:
    % - allDatainTbl: A table containing the processed data from all experiments,
    %   including behavior scores and associated metadata.

    % Initialize variables
    allGroupData = {};  % Cell array to store data for all groups
    groupNames = {};    % Cell array to store group names

    % Loop to allow user to select folders for each group
    while true
        % Prompt user to select folders for the current group
        groupFolders = uipickfiles('Prompt', 'Select folders for the current group');
        if isequal(groupFolders, 0) || isempty(groupFolders)
            break;  % Exit loop if user cancels or doesn't select any folders
        end

        % Prompt user to enter a name for the current group
        groupName = inputdlg('Enter a name for this group:', 'Group Name', [1 50]);
        if isempty(groupName)
            break;  % Exit loop if user cancels or doesn't enter a name
        end
        groupName = groupName{1};

        % Store the selected folders and group name
        allGroupData{end+1} = groupFolders;
        groupNames{end+1} = groupName;

        % Ask if the user wants to add another group
        choice = questdlg('Do you want to add another group?', 'Add Another Group', 'Yes', 'No', 'No');
        if strcmp(choice, 'No')
            break;  % Exit loop if user chooses not to add another group
        end
    end

    % Initialize a cell array to store behavior data
    cellBehavior = cell(0, 4 + numel(allBehaviors) * 1);  % Preallocate size for all behavior scores in one row.

    % Process each group
    movieCounter = 0;
    for groupIdx = 1:length(allGroupData)
        groupFolders = allGroupData{groupIdx};
        groupName = groupNames{groupIdx};

        % Process each folder within the current group
        for folderIdx = 1:length(groupFolders)
            folderPath = groupFolders{folderIdx};
            movieCounter = movieCounter + 1;  % Increment movie number
            cd(folderPath);

            % Initialize a container for behavior scores for all flies
            flyData = {};

            % Loop through each behavior file and collect data per fly
            for behaviorIdx = 1:length(allBehaviors)
                behaviorFile = allBehaviors{behaviorIdx};
                if exist(behaviorFile, 'file')
                    load(behaviorFile, 'allScores');
                    numFlies = length(allScores.postprocessed);

                    % Expand data matrix as needed
                    for flyIdx = 1:numFlies
                        % If first time encountering this fly, initialize its row
                        if behaviorIdx == 1
                            flyData{flyIdx, 1} = movieCounter; % Movie number
                            flyData{flyIdx, 2} = flyIdx;       % Fly number
                            flyData{flyIdx, 3} = folderPath;   % Folder path
                            flyData{flyIdx, 4} = groupName;    % Group name
                        end
                        
                        % Add this behavior score to this fly's row
                        flyData{flyIdx, 4 + behaviorIdx} = allScores.postprocessed{flyIdx};
                    end
                else
                    warning('Behavior file %s not found in folder %s.', behaviorFile, folderPath);
                end
            end

            % Append all flies' data for this movie to the final cell array
            cellBehavior = [cellBehavior; flyData];
        end
    end

    % Create a table from the cell array containing behavior data
    variableNames = [{'MovieNumber', 'FlyNumber', 'FolderPath', 'GroupName'}, allBehaviors];
    allDatainTbl = cell2table(cellBehavior, 'VariableNames', variableNames);

    % Sort the table based on MovieNumber and FlyNumber
    allDatainTbl = sortrows(allDatainTbl, {'MovieNumber', 'FlyNumber'});

    % Display a success message
    disp('Successfully processed the experiment data.');
end
