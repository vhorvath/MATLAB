function [f, sdev] = VP_frequency(TY, threshold)
    T = TY(:, 1);
    Y2 = TY(:, 3);
    if ~exist('threshold', 'var')
        threshold = mean(Y2) + range(Y2) / 3;
    end
    
    peaks = strfind(Y2' > threshold, [0 1]);
    Ts = diff(T(peaks));
    f = 1 / mean(Ts);
    sdev = std(1./Ts);
end

