function ma_power
    %%
    addpath('./lib/meta-analysis/');
    datadir = './output/20220819/';
    type = {{'inst', 'desc'}, {'song', 'desc'}, {'song', 'recit'}};
    
    for j=1:numel(type)
        result = [...
            readtable(strcat(datadir, 'results_Marsden-all_', type{j}{1}, '-', type{j}{2}, '.csv'));...
            readtable(strcat(datadir, 'results_Marsden-complete_', type{j}{1}, '-', type{j}{2}, '.csv'))...
            ];
    
        featurelist = unique(result.feature);
    
        %%
        al = 0.05/numel(featurelist);
        be = 0.95;
        mu_null = 0.5;
        mu = linspace(0, 1, 512);
    
        for i=1:numel(featurelist)
            idx = strcmp(result.feature, featurelist{i});
            Y = result.diff(idx);
            sgm = result.stderr(idx);
            K = numel(Y);
    
            %%
            mu_0 = exactCI(Y, sgm, mu, 0.5);
    
            mu_F = sum(sgm.^-2 .* Y)/sum(sgm.^-2);
            tausq_hat = max((sum(sgm.^-2 .* (Y - mu_F).^2) - (K - 1))/(sum(sgm.^-2) - sum(sgm.^-4)/sum(sgm.^-2)), 0);
            power_org = analyticalpow(sgm, al, mu_0, mu_null, tausq_hat);

            %%
            power = power_org;
            L = 0;
            sgmsq_hat = mean(sgm.^2);
            while power < be
                L = L + 1;
                sgm_L = [sgm; repmat(sqrt(sgmsq_hat), [L, 1])];
                
                power = analyticalpow(sgm_L, al, mu_0, mu_null, tausq_hat);
            end
    
            fprintf('(%s-%s) %s - %d studies for beta = %3.4f (est. %3.4f) and alpha = %3.4f\n', ...
                type{j}{1}, type{j}{2}, featurelist{i}, K + L, be, power, al);
        end
    end
end