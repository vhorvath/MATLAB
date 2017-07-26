%% Analyzing each individual time series
% Parameter swep must be run first
% Run form root folder!

    F = zeros(numel(As), numel(omegas));
    S = zeros(numel(As), numel(omegas));

    for i = 1:numel(As)
        for j = 1:numel(omegas)
            [f, sdev] = Examples.Sweep.VP_frequency(R{i, j});
            F(i, j) = f;
            S(i, j) = sdev;
        end
    end
    
%% Plotting results
    [XX, YY] = meshgrid(omegas, As);
    scatter3([XX(:)], [YY(:)], [F(:)], 30, 'o', 'k', 'filled');
    
    hold all;
    contourf(XX, YY, -log10(S));
    c = colorbar();
    c.Label.String = '-log_{10}(stdev(f))';
    
    xlabel('\Omega');
    ylabel('A');
    zlabel('f');
    view(2);