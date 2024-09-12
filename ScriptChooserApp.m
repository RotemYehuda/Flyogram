 classdef ScriptChooserApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
        UIFigure        matlab.ui.Figure
        ActionDropDown  matlab.ui.control.DropDown
        FrequencyDropDown matlab.ui.control.DropDown
        PaletteDropDown matlab.ui.control.DropDown
        RatioDropDown   matlab.ui.control.DropDown
        RunButton       matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Load available options into drop-down menus at startup
            app.ActionDropDown.Items = {'Single fly', 'Movie', 'Condition', 'Representative Fly'};
            app.FrequencyDropDown.Items = {'Frame', 'Second', 'Minute'};
            app.PaletteDropDown.Items = {'Happy', 'Rainbow'};
            app.RatioDropDown.Items = {'0.75', '0.65'};
        end

        % Helper function to enable/disable UI components
        function setUIComponentsEnabled(app, enableState)
            app.ActionDropDown.Enable = enableState;
            app.FrequencyDropDown.Enable = enableState;
            app.PaletteDropDown.Enable = enableState;
            app.RatioDropDown.Enable = enableState;
            app.RunButton.Enable = enableState;
        end

        % Button pushed function: RunButton
        function runButtonPushed(app, ~)
            % Disable UI components
            setUIComponentsEnabled(app, 'off');

            selectedAction = app.ActionDropDown.Value;
            selectedFrequency = app.FrequencyDropDown.Value;
            selectedPalette = app.PaletteDropDown.Value;
            selectedRatio = str2double(app.RatioDropDown.Value);
            
            % Execute the selected script
            switch [selectedAction, ' Per ', selectedFrequency]
                case 'Single fly Per Frame'
                    singleFlyBehaviorAnalysis(selectedPalette,...
                        'Frame', selectedRatio);
                case 'Single fly Per Second'
                    singleFlyBehaviorAnalysis(selectedPalette,...
                        'Second', selectedRatio);
                case 'Single fly Per Minute'
                    singleFlyBehaviorAnalysis(selectedPalette,...
                        'Minute', selectedRatio);
                case 'Movie Per Frame'
                    movieBehaviorAnalysis(selectedPalette,...
                        'Frame', selectedRatio);
                case 'Movie Per Second'
                    movieBehaviorAnalysis(selectedPalette,...
                        'Second', selectedRatio);
                case 'Movie Per Minute'
                    movieBehaviorAnalysis(selectedPalette,...
                        'Minute', selectedRatio);
                case 'Condition Per Frame'
                    conditionBehaviorAnalysis(selectedPalette,...
                        'Frame', selectedRatio);
                case 'Condition Per Second'
                    conditionBehaviorAnalysis(selectedPalette,...
                        'Second', selectedRatio);
                case 'Condition Per Minute'
                    conditionBehaviorAnalysis(selectedPalette,...
                        'Minute', selectedRatio);
                case 'Representative Fly Per Frame'
                    representativeFlyAnalysis(selectedPalette, 'Frame', selectedRatio);
                case 'Representative Fly Per Second'
                    representativeFlyAnalysis(selectedPalette, 'Second', selectedRatio);
                case 'Representative Fly Per Minute'
                    representativeFlyAnalysis(selectedPalette, 'Minute', selectedRatio);

                otherwise
                    % Handle invalid selection
                    disp('Invalid script selection');
            end

            % Re-enable UI components
            setUIComponentsEnabled(app, 'on');
            
            % Ask if the user wants to enter more movies
            answer = questdlg('Do you want to create more plots?', ...
                              'Enter More Movies', ...
                              'Yes', 'No', 'No');
            if strcmp(answer, 'No')
                % Close the UI figure if the user doesn't want to enter more movies
                close(app.UIFigure);
            else
                % Reset dropdowns to their default values if the user wants to enter more movies
                app.ActionDropDown.Value = app.ActionDropDown.Items{1};
                app.FrequencyDropDown.Value = app.FrequencyDropDown.Items{1};
                app.PaletteDropDown.Value = app.PaletteDropDown.Items{1};
                app.RatioDropDown.Value = app.RatioDropDown.Items{1};
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 300 240];
            app.UIFigure.Name = 'Script Chooser';

            % Create ActionDropDown
            uilabel(app.UIFigure, 'Text', 'Action', 'Position', [20 190 100 22]);
            app.ActionDropDown = uidropdown(app.UIFigure);
            app.ActionDropDown.Position = [20 170 120 22];

            % Create FrequencyDropDown
            uilabel(app.UIFigure, 'Text', 'Frequency', 'Position', [160 190 100 22]);
            app.FrequencyDropDown = uidropdown(app.UIFigure);
            app.FrequencyDropDown.Position = [160 170 120 22];

            % Create PaletteDropDown
            uilabel(app.UIFigure, 'Text', 'Color palette', 'Position', [160 120 100 22]);
            app.PaletteDropDown = uidropdown(app.UIFigure);
            app.PaletteDropDown.Position = [160 100 120 22];
            
            % Create RatioDropDown
            uilabel(app.UIFigure, 'Text', 'Threshold ratio', 'Position', [20 120 100 22]);
            app.RatioDropDown = uidropdown(app.UIFigure);
            app.RatioDropDown.Position = [20 100 120 22];

            % Create Information Button next to RatioDropDown
            infoButton = uibutton(app.UIFigure, 'push');
            infoButton.Text = '?';
            infoButton.Position = [120 125 20 22];
            infoButton.ButtonPushedFcn = @(~, ~) showExplanation(app);
        
            % Callback function to show/hide the explanation
            function showExplanation(app)
                % Create Explanation Figure
                explanationFigure = uifigure('Position', [410 100 300 150], 'Name', 'Explanation');
                
                % Create Explanation Label
                explanationText = sprintf('The ratio according to which the threshold value\nof each behavior will be calculated.\nThe recommended default value is 0.75,\n\nHowever, for the purpose of creating an ethogram\nof conditions according to a large number of\nmovies, or conditions with high variability,\nwe would reccomend lowering the value to 0.65.');
                uilabel(explanationFigure, 'Text', explanationText, 'Position', [20 10 270 150]);
        
                % Wait for the explanation figure to be deleted
                waitfor(explanationFigure);
            end

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @runButtonPushed, true);
            app.RunButton.Position = [120 20 60 22];
            app.RunButton.Text = 'Run';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ScriptChooserApp
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code to execute before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end

