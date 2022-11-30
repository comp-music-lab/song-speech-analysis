function ma_power(esinfodir, al, be, numsim)
    %%
    addpath('./lib/meta-analysis/');
    testdiff = {'f0', 'IOI rate', '-|Δf0|'};
    testsim = {'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    
    mu_null_diff = 0.5;
    mu_0_diff = normcdf(0.4/sqrt(2));
    mu_null_sim = 0.5;
    Dlt = normcdf(0.4/sqrt(2)) - mu_null_sim;

    %%
    esinfo = [...
            readtable(strcat(esinfodir, 'results_effectsize_acoustic_song-desc_Infsec.csv'));...
            readtable(strcat(esinfodir, 'results_effectsize_seg_song-desc_Infsec.csv'))...
            ];
    
    %% Impute zero standard error in the pilot data (Yoruba, sign of f0 slope)
    % Zero standard error occurred because the signs of f0 slope of singing
    % and spoken description are both all -1. ([-1, -1, -1, -1] in singing
    % and [-1, -1, -1, -1, -1, -1, -1] in spoken description). Therefore the
    % hypothetical standard error of the relative effect is estimated by assuming
    % at least one of the observations was +1. First, test both patterns that
    % one of the elements is 1 in singing and spoken description.
    % Then take the smaller value (i.e. closer to zero) for the hypothetical standard error.
    if esinfo.stderr(strcmp(esinfo.lang, 'Yoruba') & strcmp(esinfo.feature, 'Sign of f0 slope')) == 0
        A = [-1, -1, -1, -1];
        B = [-1, -1, -1, -1, -1, -1, -1];
        addpath('./lib/two-sample/');

        Z = A;
        Z(1) = 1;
        [~, tau_A] = pb_effectsize(Z, B);
        Z = B;
        Z(1) = 1;
        [~, tau_B] = pb_effectsize(A, Z);
        stderr = min(tau_A, tau_B);

        esinfo.stderr(strcmp(esinfo.lang, 'Yoruba') & strcmp(esinfo.feature, 'Sign of f0 slope')) = stderr;
    end

    %%
    for i=1:numel(testdiff)
        idx = strcmp(esinfo.feature, testdiff{i});

        Y = esinfo.diff(idx);
        sgm = esinfo.stderr(idx);

        K = numel(Y);
        mu_F = sum(sgm.^-2 .* Y)/sum(sgm.^-2);
        tausq_hat = max((sum(sgm.^-2 .* (Y - mu_F).^2) - (K - 1))/(sum(sgm.^-2) - sum(sgm.^-4)/sum(sgm.^-2)), 0);

        power = analyticalpow(sgm, al, mu_0_diff, mu_null_diff, tausq_hat);

        sgm_L = sgm;
        sgm_mu = sqrt(mean(sgm.^2));
        while power < be
            sgm_L(end + 1) = sgm_mu;
            power = analyticalpow(sgm_L, al, mu_0_diff, mu_null_diff, tausq_hat);
        end

        N = numel(sgm_L);

        %%
        [CI, ~, mu_hat] = exactCI(linspace(min(Y), max(Y), 1024), Y, sgm, al*2, mu_null_diff);
        fprintf('(song-desc) diff: %s (%3.4f-%3.4f-Inf, tau = %3.4f) - %d studies for beta = %3.4f (est. %3.4f) and alpha = %3.4f\n',...
            testdiff{i}, CI(1), mu_hat, sqrt(tausq_hat), N, be, power, al);
    end
    
    %%
    for i=1:numel(testsim)
        idx = strcmp(esinfo.feature, testsim{i});

        Y = esinfo.diff(idx);
        sgm = esinfo.stderr(idx);

        K = numel(Y);
        mu_F = sum(sgm.^-2 .* Y)/sum(sgm.^-2);
        tausq_hat = max((sum(sgm.^-2 .* (Y - mu_F).^2) - (K - 1))/(sum(sgm.^-2) - sum(sgm.^-4)/sum(sgm.^-2)), 0);

        sgm_m = sqrt(mean(sgm.^2 + tausq_hat));
        n_max = 0;
        power = 0;
        wf = waitbar(0, 'Simulating...');
        for j=1:numsim
            waitbar(j/numsim, wf, 'Simulating...');
            [n_j, pwr] = simequivpow(mu_null_sim - 0.5, sgm_m, al, be, Dlt);
            if n_max < n_j
                n_max = n_j;
                power = pwr;
            end
        end
        close(wf);

        %%
        [CI, ~, mu_hat] = exactCI(linspace(min(Y), max(Y), 1024), Y, sgm, al, mu_null_diff);
        fprintf('(song-desc) sim: %s (%3.4f-%3.4f-%3.4f, tau = %3.4f) - %d studies for beta = %3.4f (est. %3.4f) and alpha = %3.4f\n',...
            testsim{i}, CI(1), mu_hat, CI(2), sqrt(tausq_hat), n_max, be, power, al);
    end
end