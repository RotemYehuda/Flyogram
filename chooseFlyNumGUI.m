function flyNumber = chooseFlyNumGUI(numFlies)
    % Create a dialog window to prompt the user for input
    dlgTitle = 'Select Fly Number';
    prompt = ['Select the fly number (between 0 and ' num2str(numFlies) ', where 0 means all flies):'];
    numLines = 1;
    defaultInput = {'1'};
    flyNumber = inputdlg(prompt, dlgTitle, numLines, defaultInput);

    % Convert the input to a numeric value
    flyNumber = str2double(flyNumber{1});
    
    % Check if the input is valid
    if ~isempty(flyNumber) && isnumeric(flyNumber) && flyNumber >= 0 && flyNumber <= numFlies
        % If valid, do nothing as the value is already stored in flyNumber
    else
        % If not valid, set flyNumber to default value
        flyNumber = 1;
        msgbox('Invalid input. Default number 1 was chosen.', 'Warning', 'warn');
    end
    disp("Successfully set fly number.");
end
