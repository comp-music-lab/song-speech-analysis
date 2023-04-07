function analysis_contourpca
    %%
    addpath(strcat(userpath, filesep, 'lib2', filesep, 'PCAMV'));
    filename = {'contour_song', 'contour_desc', 'contour_inst', 'contour_recit'};

    %%
    C = 80;

    for i=1:numel(filename)
        filepath = strcat('../output/analysis/Stage2/', filename{i}, '.csv');
        X = readmatrix(filepath);

        [~, ~, ~, ~, explained, ~] = pca(X, 'algorithm','als');
        explained_csum = cumsum(explained);
        idx = find(explained_csum >= C, 1, 'first');
        fprintf('%s - %d/%d (%3.2f, %3.4f%%)\n', filename{i}, idx, numel(explained_csum), C, 100*idx/numel(explained_csum));
    end
end

%{
Sgm = wishrnd(diag(ones(5, 1)), 7);
Mu = mvnrnd(zeros(5, 1), inv(Sgm.*6));
x = mvnrnd(Mu, inv(Sgm), 300);
[coeff, score, ~, ~, ~, Mu_x] = pca(x);

Y = score*coeff' + Mu_x;
latent =  var(score, 0)';
explained = latent./sum(latent).*100;
%}

%{
x = mvnrnd(zeros(5, 1), diag(ones(5, 1)), 300);
[coeff, score, ~, ~, ~, Mu_x] = pca(x);

Y = score*coeff' + Mu_x;
latent =  var(score, 0)';
explained = latent./sum(latent).*100;
%}