function [T, Y] = VP_integrate(mu, A, omega, ic, duration)
    [T, Y] = ode15s(@(t, y) van_der_Pol_ode(t, y, mu, A, omega), [0, duration], ic);
end

function dy = van_der_Pol_ode(t, y, mu, A, omega)
    vx = y(1);
    vy = y(2);
    dy = [vy; A * sin(omega * t) + mu * (1 - vx^2) * vy - vx];
end