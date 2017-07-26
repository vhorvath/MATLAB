%% Foreced van der Pol oscillator parameter sweep with parallel computation
% Run form root folder!

% Problem setup
    As = (1:10) * 2;
    omegas = (0:10) * 0.5;
    ic = [2, 0];
    duration = 300;

% Generation of tasks
    futures = repmat(parallel.FevalFuture, numel(As) * numel(omegas), 1);

    N = 1;
    for i = 1:numel(As)
        for j = 1:numel(omegas)
            mu = 5;
            A = As(i);
            omega = omegas(j);
            futures(N) = parfeval(@Examples.Sweep.VP_integrate, 2, mu, A, omega, ic, duration);
            N = N + 1;        
        end
    end

% Fetching results
    R = swapped(numel(As), numel(omegas));

    for i = 1:numel(futures)
        [completedIdx, T, Y] = fetchNext(futures);
        R{completedIdx} = [T, Y];
        fprintf('%d\n', i);
    end

