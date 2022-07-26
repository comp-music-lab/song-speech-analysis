function [h_opt, h, R] = kdebandwidth_cr(X, numnorm)
    %% Reference
    % Chen, Y.-C., Genovese, C. R., Ho, S. & Wasserman, L. (2015). Optimal Ridge Detection using Coverage Risk, in Proc. NIPS. 
    
    %% Assumption
    % Gaussian kernels are used.

    if nargin < 2
        numnorm = 1;
    end

    %%
    J = 128;
    n = numel(X);
    h_s = 1.06 * min(1.34^(-1)*(quantile(X, 0.75) - quantile(X, 0.25)), std(X)) * n^(-1/5);
    h = rand(J, 1) .* h_s;
    R = zeros(J, 1);

    N = 1024;
    support = linspace(min(X) - h_s*5, max(X) + h_s*5, N);
    
    B = 256;
    
    fw = waitbar(0, 'Wait ...');
    for j=1:J
        waitbar(j/J, fw, 'Wait...');
        R_b = 0;
        M = 0;

        parfor b=1:B
            idx_X = randperm(n, floor(n/2));
            idx_Y = setdiff(1:n, idx_X);

            X_b = X(idx_X);
            Y_b = X(idx_Y);

            f_hat = kde(support, X_b, h(j));
            [~, locs] = findpeaks(f_hat);
            R_hat = support(locs);

            f_bs = kde(support, Y_b, h(j));
            [~, locs] = findpeaks(f_bs);
            R_bs = support(locs);

            W = arrayfun(@(U_hat) hausdorffdist(U_hat, R_bs, numnorm), R_hat);
            W_tilde = arrayfun(@(U_bs) hausdorffdist(U_bs, R_hat, numnorm), R_bs);

            D = W + W_tilde';
            R_b = R_b + sum(D, 'all');

            M = M + numel(D);
        end

        %{
        f_hat = kde(support, X, h(j));
        [~, locs] = findpeaks(f_hat);
        R_hat = support(locs);
        
        eps = h(j).*normrnd(0, 1, [n, B]);
        parfor b=1:B
            Y = datasample(X, n, 'Replace', true) + eps(:, b);

            f_bs = kde(support, Y, h(j));
            [~, locs] = findpeaks(f_bs);
            R_bs = support(locs);
    
            %W = hausdorffdist(R_hat(randi(numel(R_hat), 1)), R_bs, numnorm);
            %W_tilde = hausdorffdist(R_bs(randi(numel(R_bs), 1)), R_hat, numnorm);
            W = arrayfun(@(U_hat) hausdorffdist(U_hat, R_bs, numnorm), R_hat);
            W_tilde = arrayfun(@(U_bs) hausdorffdist(U_bs, R_hat, numnorm), R_bs);

            D = W + W_tilde';
            R_b = R_b + sum(D, 'all');

            M = M + numel(D);
        end
        %}

        R(j) = 0.5*R_b/M;
    end
    close(fw);

    %%
    [~, idx] = min(R);
    h_opt = h(idx);
end

%{
mu = [3, 0.7, -1];
sgm = [1.2, 0.7, 0.4];
n = [67, 48, 39];

X = [];
for i=1:numel(mu)
    X = [X; normrnd(mu(i), sgm(i), [n(i), 1])];
end

[h, h_list, R] = kdebandwidth_cr(X);
support = linspace(min(X) - h*4, max(X) + h*4, 1024);
f = kde(support, X, h);

f_true = 0;
for i=1:numel(mu)
    f_true = f_true + n(i)/sum(n).*normpdf(support, mu(i), sgm(i));
end

figure(1);
clf; cla;
subplot(2, 1, 1);
scatter(h_list, log(R), 'Marker', '.');
subplot(2, 1, 2);
plot(support, f);
hold on
plot(support, f_true, '-.m')
scatter(X, zeros(sum(n), 1), 'Marker', '|');
hold off
%}