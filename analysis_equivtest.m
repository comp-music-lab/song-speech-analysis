function analysis_equivtest(esinfofile, outputfile, al)
    %%
    T = readtable(esinfofile);
    featurelist = {'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    
    center = 0.5;
    Dlt = normcdf(0.4/sqrt(2)) - center;

    %%
    addpath('./lib/meta-analysis/');
    varNames = {'feature', 'pvalue' 'reject'};
    varTypes = {'string', 'double', 'double'};
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    support = linspace(0, 1, 512)';
    for i=1:numel(featurelist)
        idx = strcmp(T.feature, featurelist{i});
        
        if sum(idx) > 0
            Y = T.diff(idx);
            sgm = T.stderr(idx);
            [reject, pval] = equivtest_meta(Y, sgm, support, Dlt, al, center);
            
            results(end + 1, :) = table(featurelist(i), pval, reject);
        end
    end

    %%
    writetable(results, outputfile);
end