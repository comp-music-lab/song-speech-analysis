function intervaldev = ft_intervaldev(interval)
    %%
    X = interval(:);
    X = X + 10.*(rand(numel(X), 1) - 0.5);
    
    %%
    X = sort(X);
    n = numel(X);
    h = linspace(std(X)*(log(n)/n), 1.06*min(std(X), (quantile(X, 0.75) - quantile(X, 0.25))/1.34)*n^(-0.2), 128);
    C_tol = cell(numel(h), 1);
    
    X = gpuArray(cast(X, 'single'));
    h = gpuArray(cast(h, 'single'));

    fw = waitbar(0, 'Wait...');
    for j=1:numel(h)
        waitbar(j/numel(h), fw, 'Wait...');

        %f_X = arrayfun(@(X_i) mean(normpdf(X, X_i, h(j))), X);
        f_X = mean(normpdf(X - X', 0, h(j)), 2);
        thresh = normpdf(0, 0, h(j))/n * (0.01*n);
        idx = find(f_X > thresh);

        C = meanshift(X(idx), X(idx)', 0.1, h(j));
        C_tol{j} = uniquetol(C, 1e-2);
    end
    close(fw);
    
    %%
    K = cellfun(@(C) numel(C), C_tol);
    K_unq = [K(1), 1, 1];
    for i=2:numel(K)
        if K(i - 1) ~= K(i)
            K_unq(end + 1, :) = [K(i), i, 1];
        else
            K_unq(end, 3) = K_unq(end, 3) + 1;
        end
    end
    
    [~, idx] = max(K_unq(:, 3));
    idx_h = K_unq(idx, 2);
    
    %%
    %f_X = arrayfun(@(X_i) mean(normpdf(X, X_i, h(idx_h))), X);
    f_X = mean(normpdf(X - X', 0, h(idx_h)), 2);
    thresh = normpdf(0, 0, h(idx_h))/n * (0.01*n);
    idx = find(f_X > thresh);

    C = meanshift(X(idx), X(idx)', 0.1, h(idx_h));
    [C_h, ~, IC] = uniquetol(C, 1e-2);
    
    intervaldev = [];
    for k=1:numel(C_h)
        intervaldev = [intervaldev; abs(C_h(k) - X(idx(IC == k)))];
    end

    %{
    if numel(idx) ~= numel(X)
        idx_d = setdiff(1:numel(X), idx);

        for j=1:numel(idx_d)
            T_i = [T_i; min(abs(X(idx_d(j)) - C_h))];
        end
    end
    %}

    %%{
    fobj = figure;
    fobj.Position = [6, 383, 461, 471];

    X = gather(X);
    support = linspace(min(X) - 10, max(X) + 10, 512);
    h_opt = gather(h(idx_h));
    f_X = arrayfun(@(x_i) mean(normpdf(x_i, X, h_opt)), support);

    subplot(3, 1, 1);
    plot(h, K);
    yl = ylim();
    hold on
    stem(h(idx_h), yl(2), 'Marker', 'none');
    hold off
    
    subplot(3, 1, 2);
    scatter(support, f_X, 'Marker', '.');
    yl = ylim();
    hold on
    stem(C_h, yl(2).*ones(numel(C_h), 1), 'Marker', 'none');
    scatter(X, zeros(numel(X), 1), 'Marker', '|');
    hold off
    
    subplot(3, 1, 3);
    histogram(intervaldev);
    xlim([0, 800]);
    %}
end