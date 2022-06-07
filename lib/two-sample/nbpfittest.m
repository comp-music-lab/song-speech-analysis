classdef nbpfittest < handle
    properties(Constant)
        LABEL_X = 0;
        LABEL_Y = 1;
        G = @(p) norminv(p, 0, 1);
    end
    
    properties
        c, L
        h_mu, h_var
    end
    
    methods
        function obj = nbpfittest(c, L, mode)
            obj.c = c;
            obj.L = L;
            
            if strcmp('robust', mode)
                obj.h_mu = @median;
                obj.h_var = @(x) quantile(x, 0.75) - quantile(x, 0.25);
            elseif strcmp('normal', mode)
                obj.h_mu = @mean;
                obj.h_var = @(x) sqrt(var(x));
            end
        end
        
        function lnbf = test(obj, x, y)
            xy = obj.h_standardization([x; y]);
            
            label_x = obj.LABEL_X .* ones(length(x), 1);
            label_y = obj.LABEL_Y .* ones(length(y), 1);

            [record, idx] = obj.partition(xy, [label_x; label_y], obj.G, 0, 1, obj.L, '');
            lnbf = obj.oddsratio(record, idx, obj.c, obj.L);
        end
        
        function [record, idx] = partition(obj, x, label, G, p_0, p_1, L, eps)
            N = length(x);
            N_x = numel(find(label == obj.LABEL_X));
            N_y = numel(find(label == obj.LABEL_Y));

            record_i = [N, N_x, N_y, p_0, p_1];
            idx_i = {eps};

            if length(eps) >= L || N == 1 || 1 == numel(unique(x))
                record = record_i;
                idx = idx_i;
            elseif N == 0
                record = [];
                idx = [];
            else
                x_0 = G(p_0);
                x_1 = G(p_1);

                p_m = (p_0 + p_1)/2;
                x_m = G(p_m);

                idx_l = x_0 < x & x <= x_m;
                idx_r = x_m < x & x <= x_1;

                [record_l, idx_l] = obj.partition(x(idx_l), label(idx_l), G, p_0, p_m, L, strcat(eps, '0'));
                [record_r, idx_r] = obj.partition(x(idx_r), label(idx_r), G, p_m, p_1, L, strcat(eps, '1'));

                record = [record_i; record_l; record_r];
                idx = [idx_i; idx_l; idx_r];
            end
        end

        function lnbf = oddsratio(obj, record, idx, c, L)
            M = size(record, 1);

            L_pooled = 0;
            for m=1:M
                n = record(m, 1);

                if record(m, 2) > 0 && record(m, 3) > 0 && length(idx{m}) ~= L
                    m_left = find(strcmp(idx(:), strcat(idx{m}, '0')));

                    if ~isempty(m_left)
                        k = record(m_left, 1);
                    else
                        k = 0;
                    end

                    l = length(idx{m});
                    al = c*(l + 1)^2;
                    be = al;

                    L_pooled = L_pooled + obj.logmarginal(k, n, al, be);
                end
            end

            L_1 = 0;
            for m=1:M
                n = record(m, 2);

                if record(m, 2) > 0 && record(m, 3) > 0 && length(idx{m}) ~= L
                    m_left = find(strcmp(idx(:), strcat(idx{m}, '0')));

                    if ~isempty(m_left)
                        k = record(m_left, 2);
                    else
                        k = 0;
                    end

                    l = length(idx{m});
                    al = c*(l + 1)^2;
                    be = al;

                    L_1 = L_1 + obj.logmarginal(k, n, al, be);
                end
            end

            L_2 = 0;
            for m=1:M
                n = record(m, 3);

                if record(m, 2) > 0 && record(m, 3) > 0 && length(idx{m}) ~= L
                    m_left = find(strcmp(idx, strcat(idx{m}, '0')));

                    if ~isempty(m_left)
                        k = record(m_left, 3);
                    else
                        k = 0;
                    end

                    l = length(idx{m});
                    al = c*(l + 1)^2;
                    be = al;

                    L_2 = L_2 + obj.logmarginal(k, n, al, be);
                end
            end

            lnbf = L_pooled - (L_1 + L_2);
        end

        function [posterior_H0, posterior_H1] = posterior(obj, priorodds, lnbf)
            posterior_H0 = 1./(1 + 1./(priorodds .* exp(lnbf)));
            posterior_H1 = 1 - posterior_H0;
        end
        
        function xy = h_standardization(obj, xy)
            %{
            mu = median(xy);
            sd = quantile(xy, 0.75) - quantile(xy, 0.25);
            %}
            mu = obj.h_mu(xy);
            sd = obj.h_var(xy);
            
            if sd == 0
                sd = 1;
            end

            xy = (xy - mu)./sd;
        end

        function p = logmarginal(obj, x, n, al, be)
            p = gammaln(x + al) + gammaln(n - x + be) - gammaln(n + al + be)...
                + gammaln(al + be) - gammaln(al) - gammaln(be);
        end
    end
end