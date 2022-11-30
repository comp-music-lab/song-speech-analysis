function analysis_metaCI(esinfofile, outputfile, al)
    %%
    T = readtable(esinfofile);
    featurelist = unique(T.feature);
    
    testdiff = {'f0', 'IOI rate', '-|Δf0|'};
    testsim = {'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};

    %%
    addpath('./lib/meta-analysis/');
    varNames = {'feature', 'mean', 'CI_l', 'CI_u'};
    varTypes = {'string', 'double', 'double', 'double'};
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    mu_null = 0.5;
    
    for i=1:numel(featurelist)
        if sum(strcmp(featurelist{i}, testdiff)) == 1
            al = al * 2;
        end

        idx = strcmp(T.feature, featurelist{i});
        Y = T.diff(idx);
        sgm = T.stderr(idx);
        mu = linspace(min(Y), max(Y), 1024);
        [CI, ~, mu_hat] = exactCI(mu, Y, sgm, al, mu_null);
        
        results(end + 1, :) = table(featurelist(i), mu_hat, CI(1), CI(2));
    end

    %%
    writetable(results, outputfile);
end