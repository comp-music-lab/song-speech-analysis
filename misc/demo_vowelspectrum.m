function demo_vowelspectrum
    %%
    [x, fs] = audioread('../data/Stage 1 RR Audio/full-length/Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song.wav');
    t = (0:(numel(x) - 1))./fs;

    %%
    seg_a = [...
        1.548, 2.472;
        3.612, 3.828;
        4.096, 4.328;
        4.784, 5.008;
        6.168, 6.344;
        6.496, 6.664;
        7.368, 7.880;
        8.213, 8.446;
        8.950, 9.109;
        9.380, 9.594;
        10.285, 10.565;
        16.669, 16.968
        ];

    N = ceil(fs*max(seg_a(:, 2) - seg_a(:, 1)));
    K = size(seg_a, 1);
    P = cell(K, 1);
    F = cell(K, 1);
    
    for i=1:K
        [~, idx_st] = min(abs(seg_a(i, 1) - t));
        [~, idx_ed] = min(abs(seg_a(i, 2) - t));
        w = hann(idx_ed - idx_st + 1);

        x_i = x(idx_st:idx_ed);
        x_i = x_i./sqrt(mean(x_i.^2));
        P{i} = abs(fft(x_i.*w, N)).^2./N^2 * N/(idx_ed - idx_st + 1);
        %P{i} = abs(fft(x(idx_st:idx_ed).*w)).^2./(idx_ed - idx_st + 1)^2;
        F{i} = (0:(numel(P{i}) - 1)) .* fs/numel(P{i});
    end
    
    P_mu = zeros(N, 1);
    for i=1:K
        P_mu = P_mu + P{i};
    end
    P_mu = P_mu./K;
    F_mu = (0:(numel(P_mu) - 1)) .* fs/numel(P_mu);

    %%
    figure(1);
    clf; cla;
    for i=1:K
        subplot(K/2, 2, i);
        plot(F{i}, 10.*log10(P{i}));
        hold on
        plot(F_mu, 10.*log10(P_mu), '-.m');
        hold off
        xlim([10, 8000]);
        set(gca, 'XScale', 'log');
    end
end