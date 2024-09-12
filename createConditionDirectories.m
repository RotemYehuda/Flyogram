function paths = createConditionDirectories(alldataintbl, folderName)
    % Get unique conditions
    conditions = unique(alldataintbl.condition);
    
    % Initialize cell array to store paths
    paths = cell(length(conditions), 1);
    
    for i = 1:length(conditions)
        % Get the current condition
        condition = conditions{i};
        
        % Find the rows that match the current condition
        conditionRows = alldataintbl(strcmp(alldataintbl.condition, condition), :);
        
        % Extract the first file path for the condition
        filePath = conditionRows.name_of_the_file{1};
        
        % Extract the directory path from the file path
        [parentDir, ~, ~] = fileparts(filePath);
        
        % Create the specified folder directory path
        specifiedDir = fullfile(parentDir, folderName);
        
        % Remove existing ConditionEthogram directory if it exists and create a new one
        if isfolder(specifiedDir)
            rmdir(specifiedDir, 's');
        end
        mkdir(specifiedDir);
        
        % Store the path in the cell array
        paths{i} = specifiedDir;
    end
    
    % Display a message indicating completion
    disp(['Directories created with folder name: ', folderName]);
end
