function numFramesPerInterval = getNumFramesPerInterval(timeInterval)
    switch timeInterval
        case 'Frame'
            numFramesPerInterval = 1;
        case 'Second'
            numFramesPerInterval = 30;
        case 'Minute'
            numFramesPerInterval = 30 * 60;
        otherwise
            error('Invalid time interval specified.');
    end
end