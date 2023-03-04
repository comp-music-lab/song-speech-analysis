function coef = ft_f0declination(t_onset, t_break, f0, t_f0, debug)
    if nargin < 5
        debug = false;
    end

    %%
    if isempty(t_onset) || isempty(t_break)
        coef = NaN;
        return
    end
    
    %%
    t_seg = helper.h_phraseseg(t_onset, t_break);
    n_seg = t_seg.*0;
    for i=1:size(t_seg, 1)
        [~, n_seg(i, 1)] = min(abs(t_f0 - t_seg(i, 1)));
        [~, n_seg(i, 2)] = min(abs(t_f0 - t_seg(i, 2)));
    end

    %%
    reffreq = 440;
    f0 = 1200.*log2(f0./reffreq);

    coef = zeros(size(n_seg, 1), 1);
    R = zeros(2, size(n_seg, 1));
    
    for i=1:size(n_seg, 1)
        f0_i = f0(n_seg(i, 1):n_seg(i, 2));
        t_f0_i = t_f0(n_seg(i, 1):n_seg(i, 2));

        idx = ~isinf(f0_i);
        f0_idx = f0_i(idx);
        t_f0_idx = t_f0_i(idx);

        if ~isempty(f0_idx)
            try
                %R(:, i) = [ones(numel(t_f0_idx), 1), t_f0_idx(:)]\f0_idx(:);
                mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
                R(:, i) = mdl.Coefficients.Estimate;

                coef(i) = sign(R(2, i));
                %coef(i) = R(2, i);
            catch ME
                coef(i) = [];
                disp(getReport(ME));
            end
        else
            coef(i) = [];
        end
    end
    
    %%
    if debug
        figure;
        scatter(t_f0, f0, 'Marker', '.');
        hold on
        yl = ylim();
        for i=1:size(n_seg, 1)
            plot(t_f0(n_seg(i, 1)).*[1, 1], yl, '-.m');
            plot(t_f0(n_seg(i, 2)).*[1, 1], yl, '-.r');

            t_f0_i = t_f0(n_seg(i, 1):n_seg(i, 2));
            plot(t_f0_i, R(1, i) + R(2, i).*t_f0_i, 'k');
        end
        hold off
    end
end