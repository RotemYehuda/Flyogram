function movieName = getMovieName(filePath)
    % Extract the movie name from the file path
    [~, name, ~] = fileparts(filePath);
    movieName = name;
end