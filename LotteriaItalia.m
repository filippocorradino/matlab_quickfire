% LOTTERIA ITALIA SIMULATION
% During the Lotteria Italia extraction of 2020, 3 tickets out of 180 for
% the 2000 € prizes were extracted out of the same decade (only the units
% digit was different), out of a total of 6700000 tickets.
% The probability of this occurrence (3+ tickets extracted in the same
% decade for at least 1 of the decades) was calculated analytically by the
% guys of TAXI1729 to be approximately 1/652262.
% This script intends to verify the result through statistical simulation
% of the extractions.
%
% SETTINGS
% N : number of sold tickets overall
% E : number of extracted tickets overall
% T : size of the "bins" in which to divide the tickets
%     e.g. T = 10 means we divide them in contiguous decades
% K : number of tickets to be found in a same "bin" for a simulation to be
%     a "valid case" (as the one which actually happened)
% p : analytical estimate of the probability
%
% Credits for the confidence intervals calculation go to Francesca Panero.
%
% Tested with MATLAB R2018b

close all
clear variables
clc

N = 6700000;
E = 180;
T = 10;
K = 3;
p = 1/652262;

totcases = 0;
validcases = 0;

figure()
title("Probability convergence from statistical estimate")
hold on
xlabel("Simulations run")
ylabel("Probability inverse [1/p]")
grid on
grid minor
set(gcf,'color','w');
set(gca,'fontsize',12);
ylim([0 10^(ceil(log10(1/p)))])
% Initialization of graphical objects
href = plot(xlim, [1 1]./p, '--r', 'LineWidth', 2);
havg = plot(0, 1/p, '.b', 'MarkerSize', 10);
hbar = errorbar(0, 1/p, 0, 0, ...
    'LineStyle', 'none', 'LineWidth', 2, 'Color', [0.7 0.7 1.0]);
% Initialization of results vector
% Preallocation for 10000 valid cases
nalloc = 10000;
casesvec = nan(1, nalloc);
probsvec = nan(1, nalloc);
deltaneg = nan(1, nalloc);
deltapos = nan(1, nalloc);

% Loop only stops with a KeyboardInterrupt
while true
    % v is the vector of extracted tickets
    v = randi(N, 1, E);
    % Check for no repetitions in the tickets numbers
    % Otherwise skip the extraction
    if length(v) == length(unique(v))
        totcases = totcases + 1;
        % Convert to decades
        v = floor(v/T);
        % Check at least K tickets in the same T-ade of some other ticket
        if (length(v) - length(unique(v))) >= (K-1)
            % Detailed check for 3 tickets in same decade
            valid = false;
            for k = 1:length(v)
                if (sum(v == v(k)) >= K)
                    valid = true;
                end
            end
            if valid
                validcases = validcases + 1;
                fprintf("%d over %d\n", validcases, totcases)
                % Compute 95% confidence interval
                average = validcases/totcases;
                sigma2 = 1/(totcases-1) * ...
                    (validcases*(1-average)^2 + ...
                    (totcases-validcases)*average^2);
                err = 1.96*sqrt(sigma2/totcases);
                % Update vectors
                casesvec(validcases) = totcases;
                probsvec(validcases) = 1/average;
                deltaneg(validcases) = 1/average - 1/(average+err);
                deltapos(validcases) = 1/(average-err) - 1/average;
                % Update errorbars plot
                hbar.XData = casesvec;
                hbar.YData = probsvec;
                hbar.YNegativeDelta = deltaneg;
                hbar.YPositiveDelta = deltapos;
                uistack(hbar, 'bottom')
                % Update averages plot
                havg.XData = casesvec;
                havg.YData = probsvec;
                % Update reference line
                href.XData = xlim;
                uistack(href,'top')
                % Refresh plot visualization
                pause(0.1)
            end
        end
    end
end