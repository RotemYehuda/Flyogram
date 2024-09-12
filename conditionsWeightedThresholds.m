function finalThresholds = conditionsWeightedThresholds(conditionsThresholds, numMoviesForEachCondition)
    addpath("W:\rotem and daniel BioProject\plotScripts\functions")
       
    % Calculate the weights array
    totalMovies = sum(numMoviesForEachCondition);
    weightsArray = numMoviesForEachCondition / totalMovies;

    % Transpose the weightsArray
    weights = weightsArray.';

    % Multiply each column by its corresponding weight
    weightedValues = conditionsThresholds .* weights;

    % Calculate the weighted mean for each row
    finalThresholds = sum(weightedValues, 2);

    disp("Successfully set the default thresholds for the conditions.");
end
