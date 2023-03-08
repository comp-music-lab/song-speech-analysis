function analysis_metaCI(esinfofile, outputfile, al)
    %%
    T = readtable(esinfofile);
    featurelist = unique(T.feature);
    
    testdiff = {'f0', 'IOI rate', '-|Δf0|'};

    %%
    addpath('./lib/meta-analysis/');
    varNames = {'feature', 'pvalue', 'mean', 'CI_l', 'CI_u'};
    varTypes = {'string', 'double', 'double', 'double', 'double'};
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    mu_null = 0.5;
    
    for i=1:numel(featurelist)
        if sum(strcmp(featurelist{i}, testdiff)) == 1
            al = al * 2;
        end

        idx = strcmp(T.feature, featurelist{i});
        Y = T.diff(idx);
        sgm = T.stderr(idx);
        [CI, pval, mu_hat] = exactCI(Y, sgm, al, mu_null);
        
        results(end + 1, :) = table(featurelist(i), pval, mu_hat, CI(1), CI(2));
    end

    %%
    writetable(results, outputfile);
end