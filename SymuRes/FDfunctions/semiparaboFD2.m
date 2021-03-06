function P = semiparaboFD2(n,param)
% P = semiparaboFD2(n,param)
% Compute the semi-parabolic Fundamental Diagram function
% (n < nc: linear part, n > nc: parabolic part)
%
% Nov 2019 - Guilhem Mariotte
%
% INPUTS
%---- n     : scalar or vector, accumulation [veh], range of n must be between 0 and nj
%---- param : vector, parameters of the FD function = [nj nc Pc]
%
% OUTPUTS
%---- P : scalar or vector (same size as n), production [veh.m/s]

nj = param(1); % jam accumulation (max. accumulation) [veh]
nc = param(2); % critical accumulation [veh]
Pc = param(3); % critical production (max. production) [veh.m/s]

u = Pc/nc; % free-flow speed [m/s]

P = (0 <= n).*(n <= nc).* u.*n + ...
    (nc < n).*(n < nj).*  (Pc./(nj - nc).^2.*(nj - n).*(nj + n - 2*nc));

end