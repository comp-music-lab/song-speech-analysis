function h_hat = kdebandwidth_lp(X)
    %% Reference
    % Chiu, S.-T. (1992). An Automatic Bandwidth Selector for Kernel Density Estimation. Biometrika, 79(4), 771-782.
    % Chiu, S.-T. (1996). A Comparative Review of Bandwidth Selection for Kernel Density Estimation. Statistica Sinica, 6(1), 129-145.

    %% Assumptions behind the implementation
    % The Gaussian function is used for a kernel function.

    %% Sample code
    %{
    figure(1);
    clf; cla;

    for j=1:4
        X = [normrnd(1.5, 1, [51*j, 1]); normrnd(-1, 0.7, [47*j, 1]); normrnd(-4.0, 0.4, [54*j, 1])];
        
        tic;
        h = kdebandwidth_lp(X);
        x = linspace(min(X) - 3, max(X) + 3, 1024);
        f = kde(x, X, h);
        t = toc;
        
        g = (normpdf(x, 1.5, 1) + normpdf(x, -1, 0.7) + normpdf(x, -4.0, 0.4))./3;

        subplot(4, 1, j);
        plot(x, f);
        hold on
        plot(x, g, '-.m');
        hold off
        title(['bandwidth = ', num2str(h, '%3.3f'), ', elapsed time = ', num2str(t, '%3.3f'), ' seconds, n = ', num2str(numel(X), '%d')]);
    end
    %}

    %% Step 1 - Estimation of the empirical characteristic function
    J = 2048;
    lmd = linspace(-10*pi, 10*pi, J);
    
    phi = arrayfun(@(lmd_i) sum(exp(1i.*lmd_i.*X)), lmd);    
    n = size(X, 1);
    phi = phi./n;

    %% Step 2 - Cut-off frequency selection
    M = 1024;
    Sgm = rand(M, 1).*max(lmd);
    abslmd = abs(lmd);
    P = abs(phi).^2;
    
    CV = arrayfun(@(Sgm_i) trapz(lmd(abslmd < Sgm_i), P(abslmd < Sgm_i)), Sgm);
    CV = -1/(2*pi).*CV + (4.*Sgm)./(2*pi*n);

    [~, idx] = min(CV);
    Sgm_h = Sgm(idx);

    %% Step 3 - Bandwidth selection by the approximate cross-validation
    M = 1024;
    h_rot = 1.06*min(1.34^(-1) * (quantile(X, 0.75) - quantile(X, 0.25)), std(X, 1))*n^(-0.2); %Use the rule-of-thumb as the maximum bandwidth.
    h = rand(M, 1).*h_rot;

    P_Sgm = P(abslmd < Sgm_h);
    lmd_Sgm = lmd(abslmd < Sgm_h);
    w2 = (1/n) * 1/(2*sqrt(pi));
    W = @(h_i) exp(-0.5.*(lmd_Sgm.*h_i).^2);

    S = arrayfun(@(h_i) 1/(2*pi).*trapz(lmd_Sgm, (P_Sgm - 1/n).*(1 - W(h_i)).^2) + (1/h_i).*w2, h);
    
    [~, idx] = min(S);
    h_hat = h(idx);
end