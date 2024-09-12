function saveTableToCSV(folderPath, fileName, dataTable)
    % Check if the folder exists, if not, create it
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
    
    % Define the full output file path
    outputFileName = fullfile(folderPath, [fileName, '.csv']);
    
    % Save the table to the specified CSV file
    writetable(dataTable, outputFileName);
    
    % Display a message indicating where the file was saved
    disp(['Table saved to ', outputFileName]);
end
