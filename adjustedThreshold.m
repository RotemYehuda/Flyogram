function defaultThresholds = adjustedThreshold(summedScores, ratio, RF)
% Calculate the upper quarter value for each line of summedScores
    upper_quarter_values = quantile(summedScores, ratio, 2);
    
    % Find indices of upper quarter values that are zero
    tinyIndices = upper_quarter_values < 1;

    % Replace zero upper quarter values with a small number
    upper_quarter_values(tinyIndices) = 1;

    % Calculate the default thresholds 
    defaultThresholds = upper_quarter_values / RF;
    disp("Successfully set the default thresholds for single matrix.");
end
