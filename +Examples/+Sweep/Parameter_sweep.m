%% Foreced van der Pol oscillator parameter sweep single core
% Run form root folder!

    As = (1:10) * 2;
    omegas = (0:10) * 0.5;
    ic = [2, 0];
    duration = 300;

    R = swapped(numel(As), numel(omegas));
    N = 1;
    for i = 1:numel(As)
        for j = 1:numel(omegas)
            mu = 5;
            A = As(i);
            omega = omegas(j);
            [T, Y] = Examples.Sweep.VP_integrate(mu, A, omega, ic, duration);
            R{i, j} = [T, Y];
            fprintf('%d\n', N);
            N = N + 1;        
        end
    end