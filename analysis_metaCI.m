function analysis_metaCI(esinfofile, outputfile, q)
    %%
    T = readtable(esinfofile);
    featurelist = unique(T.feature);
    
    mu = linspace(0, 1, 4096);
    
    %%
    addpath('./lib/meta-analysis/');
    varNames = {'feature', 'mean', 'CI_diff', 'CI_sim_l', 'CI_sim_u'};
    varTypes = {'string', 'double', 'double', 'double', 'double'};
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    for i=1:numel(featurelist)
        idx = strcmp(T.feature, featurelist{i});
        Y = T.diff(idx);
        sgm = T.stderr(idx);
        CI = exactCI(Y, sgm, mu, q);
        
        results(end + 1, :) = table(featurelist(i), CI(1), CI(2), CI(3), CI(4));
    end

    %%
    writetable(results, outputfile);
end