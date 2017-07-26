function varargout = VP_plot(TY)
    h = figure;
    
    hold all;
    plot(TY(:,1), TY(:, 2));
    plot(TY(:,1), TY(:, 3));
    
    if nargout == 1
        varargout{1} = h;
    end
end