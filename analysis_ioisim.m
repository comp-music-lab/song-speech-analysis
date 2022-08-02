function analysis_ioisim
    %%
    datadir = './data/Stage 1 RR Full/';
    subdir = {...
        'Patrick/', 'Patrick/', 'Patrick/', 'Patrick/',...
        'Florence/', 'Florence/', 'Florence/', 'Florence/',...
        'Dhwani/', 'Dhwani/', 'Dhwani/', 'Dhwani/',...
        'Shafagh/', 'Shafagh/', 'Shafagh/', 'Shafagh/',...
        'Yuto/', 'Yuto/', 'Yuto/', 'Yuto/'...
    };
    material = {...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_recit',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_inst',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_inst',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_recit',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_song',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_inst',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_recit',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220507_inst',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_desc',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_recit',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220224_inst',...
    };
    
    %%
    ioiratio = cell(numel(material), 1);

    for i=1:numel(material)
        onsetfilepath = strcat(datadir, subdir{i}, 'onset_', material{i}, '.csv');
        breakfilepath = strcat(datadir, subdir{i}, 'break_', material{i}, '.csv');

        [t_onset, t_break] = h_onsetbreak(onsetfilepath, breakfilepath);
        [~, ioiratio{i}] = helper.h_ioi(unique(t_onset), unique(t_break));
    end
    
    %% lpdensity
    %{
    addpath(strcat(userpath, '/lib2/Rcall/'));
    Rlib = 'C:\Users\yuto\AppData\Local\R\win-library\4.2\lpdensity';
    Rpath = 'C:\Program Files\R\R-4.2.1\bin\R.exe';
    Rclear();
    Rinit(Rlib, Rpath);

    for i=1:numel(ioiratio)
        X = ioiratio{i}(:);
        writetable(array2table(X), 'C:\Users\yuto\Documents\R\ToyProjects\kde\tmp.csv');
        %Rpush('X', X);
        %Rrun('f_X <- lpdensity(X, kernel="epanechnikov", bwselect="mse-dpi")');
        %result = Rpull('f_X');

        %fprintf('%3.3f, %s\n', pval(i), material{i});
    end
    %}

    %% Unimodal test
    %{
    addpath(strcat(userpath, '/lib2/Rcall/'));
    Rlib = 'multimode';
    Rpath = 'C:\Program Files\R\R-4.2.1\bin\R.exe';
    Rclear();
    Rinit(Rlib, Rpath);
    pval = zeros(numel(ioiratio), 1);

    for i=1:numel(ioiratio)
        X = ioiratio{i}(:);
        Rpush('X', X);
        Rrun('result <- modetest(X, mod0=1, method="ACR", B=1000)');
        result = Rpull('result');
        pval(i) = result.p_value;

        fprintf('%3.3f, %s\n', pval(i), material{i});
    end
    %}

    %% Evidence accumulation with mean-shift
    %%{
    addpath('./lib/KDE/');
    T = cell(numel(ioiratio), 1);

    support = linspace(1e-8, 1 - 1e-8, 512);
    
    %{
    support_Y = linspace(-5, 5, 512);
    a = 0; b = 1;
    support = normcdf(support_Y).*(b - a);
    scaling = 1./normpdf(norminv((support(:) - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));
    %}

    for i=1:numel(ioiratio)
        X = ioiratio{i}(:);
        %{
        Y = ioiratio{i}(:);
        X = norminv((Y - a)./(b - a), 0, 1);
        %}

        X = sort(X);
        n = numel(X);
        h = linspace(std(X)*(log(n)/n), 1.06*min(std(X), (quantile(X, 0.75) - quantile(X, 0.25))/1.34)*n^(-0.2), 128);
        A = zeros(n, n);
        C_tol = cell(numel(h), 1);
        I = 1:n;

        for j=1:numel(h)
            f_X = arrayfun(@(X_i) normpdf(X, X_i, h(j)), X, 'UniformOutput', false);
            f_X = mean(cat(2, f_X{:}), 2);
            thresh = normpdf(0, 0, h(j))/n * 2;
            idx = find(f_X > thresh);

            C = meanshift(X(idx), X(idx)', 1e-8, h(j));
            %C = normcdf(C.*(b - a), 0, 1) + a;
            [C_tol{j}, ~, IC] = uniquetol(C, 1e-6);
            I_X = I(idx);

            for k=1:numel(C_tol{j})
                idx = find(IC == k);

                if numel(idx) > 2
                    for l=1:numel(idx)
                        A(I_X(idx(l)), I_X(idx)) = A(I_X(idx(l)), I_X(idx)) + 1;
                    end
                end
            end
        end

        A = A./numel(h);

        %%
        Z = linkage(A, 'average');
        
        %%
        K = cellfun(@(C) numel(C), C_tol);
        K_unq = unique(K);
        L = zeros(numel(K_unq), 1);
        for k=1:numel(L)
            idx_b = find(K == K_unq(k), 1, 'first');
            idx_d = find(K < K_unq(k), 1, 'first');

            if isempty(idx_d)
                idx_d = numel(h);
            end
            L(k) = h(idx_d) - h(idx_b);
        end

        [~, idx] = max(L);
        idx_h = find(K == K_unq(idx), 1, 'first');
        
        %%
        f_X = arrayfun(@(X_i) normpdf(X, X_i, h(idx_h)), X, 'UniformOutput', false);
        f_X = mean(cat(2, f_X{:}), 2);
        thresh = normpdf(0, 0, h(idx_h))/n * 2;
        idx = find(f_X > thresh);

        C = meanshift(X(idx), X(idx)', 1e-8, h(idx_h));
        [C_h, ~, IC] = uniquetol(C, 1e-6);
        
        T_i = [];
        for k=1:numel(C_h)
            T_i = [T_i; abs(C_h(k) - X(idx(IC == k)))];
        end

        %{
        if numel(idx) ~= numel(X)
            idx_d = setdiff(1:numel(X), idx);

            for j=1:numel(idx_d)
                T_i = [T_i; min(abs(X(idx_d(j)) - C_h))];
            end
        end
        %}

        T{i} = T_i;

        %%
        f_X = kde(support, X, h(idx_h));

        %{
        f_X = arrayfun(@(X_i) normpdf(support_Y(:), X_i, h(idx_h)), X, 'UniformOutput', false);
        f_X = mean(cat(2, f_X{:}), 2);
        f_X = f_X.*scaling;
        X = Y;
        %}

        C_opt = C_tol{idx_h};

        fobj = figure;
        fobj.Position = [30, 190, 375, 800];

        subplot(5, 1, 1);
        imagesc(A);
        title(material{i}, 'Interpreter', 'none');
        subplot(5, 1, 2);
        dendrogram(Z);
        subplot(5, 1, 3);
        for j=1:numel(h)
            scatter(C_tol{j}, h(j).*ones(numel(C_tol{j}), 1), 'MarkerEdgeColor', 'b', 'Marker', '.');
            hold on
        end
        scatter(X, zeros(numel(X), 1), 'Marker', '|');
        plot([0, 1], h(idx_h).*[1, 1], '-.m');
        hold off
        xlim([0, 1]);
        subplot(5, 1, 4);
        plot(support, f_X);
        area = trapz(support, f_X);
        title(['Area = ', num2str(area, '%3.3f')]);
        hold on
        for j=1:numel(C_opt)
            [~, idx] = min(abs(support - C_opt(j)));
            stem(support(idx), f_X(idx));
        end
        scatter(X, zeros(numel(X), 1), 'Marker', '|');
        hold off
        subplot(5, 1, 5);
        histogram(T{i});
        xlim([0.0, 0.6]);

        drawnow
    end
    %}

    %% Total barcode length + 95% cutoff
    %{
    support = linspace(-0.2, 1.2, 512);
    addpath('./lib/rkde/');
    IC = zeros(numel(ioiratio), 1);

    for i=1:numel(ioiratio)
        X = ioiratio{i}(:);
        h = linspace(std(X)*(log(numel(X))/numel(X)), std(X), 512);

        C = cell(numel(h), 1);
        I = cell(numel(h), 1);
        
        for j=1:numel(h)
            f_X = wrapper_rkde(X, support, h(j));

            thresh = normpdf(0, 0, h(j))./numel(X) * 2;
            [~, locs, ~, L] = findpeaks(f_X, 'MinPeakHeight', thresh);

            C{j} = support(locs);
            
            if j > 1 && numel(C{j - 1}) == 1 && numel(C{j}) == 1
                break;
            end
            
            I{j} = zeros(numel(C{j}), 1);
            BL_norm = L./sum(L);
            
            if j == 1
                totalBL = BL_norm;
                I{j} = 1:numel(C{j});
            else
                for k=1:numel(C{j})
                    [~, idx_I] = min(abs(C{j - 1} - C{j}(k)));
                    I{j}(k) = I{j - 1}(idx_I);
    
                    totalBL(I{j}(k)) = totalBL(I{j}(k)) + BL_norm(k);
                end
            end
        end
        
        totalBL = totalBL./sum(totalBL);
        [P, idx_P] = sort(totalBL, 'ascend');
        P_sum = cumsum(P);
        idx_u = find(P_sum > 0.05, 1, 'first');
        idx_L = idx_P(idx_u:end);

        C_E = C{1}(idx_L);
        
        %%
        %IC(i) = mean(-log(totalBL(idx_L)));
        %[idx_K, C_opt]= kmeans(X(:), numel(C_E), 'Start', C_E(:));

        %%
        figobj = figure;
        figobj.Position = [660, 660, 800, 300];
        
        h_cv = [];
        offset = 0;
        while isempty(h_cv)
            idx = find(cellfun(@(I_i) numel(I_i), I) == (numel(idx_L) + offset), 1, 'first');
            h_cv = h(idx);
            offset = offset + 1;
        end

        subplot(1, 2, 1);

        f_X = wrapper_rkde(X, support, h_cv);

        plot(support, f_X);
        hold on
        [~, locs_pk] = findpeaks(f_X);
        for j=1:numel(C_E)
            [~, idx_m] = min(abs(support(locs_pk) - C_E(j)));
            stem(support(locs_pk(idx_m)), f_X(locs_pk(idx_m)), 'Color', '#D95319');
        end
        scatter(X, zeros(numel(X), 1), 'Marker', '|');
        hold off
        title(material{i}, 'Interpreter', 'none');
        
        subplot(1, 2, 2);
        [~, idx_p] = sort(totalBL, 'asc');
        for j=1:numel(totalBL)
            plot([0, totalBL(idx_p(j))], j.*[1, 1], 'Color', '#0072BD');
            scatter(totalBL(idx_p(j)), j, 'Marker', 'x', 'MarkerEdgeColor', '#0072BD');
            hold on
        end
        hold off

        drawnow();
    end
    %}

    %% Bottleneck Bootstrap
    %{
    addpath('./lib/KDE/', './lib/rkde/', './lib/PH/');
    if count(py.sys.path, '') == 0
        insert(py.sys.path, int32(0), '');
    end
    
    support = linspace(-5, 5, 512);
    a = 0; b = 1;
    support_Y = normcdf(support).*(b - a);
    scaling = 1./normpdf(norminv((support_Y - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));

    for i=1:numel(ioiratio)
        Z = ioiratio{i}(:);

        X = norminv((Z - a)./(b - a), 0, 1);
        
        %{
        n = [60, 40, 50];
        a = gamrnd(2, 2);
        b = gamrnd(1, 2);
        mu = normrnd(0, 3);
        sgm = gamrnd(2, 1);
        mu2 = normrnd(0, 4);
        sgm2 = gamrnd(2, 1);
        X = [gamrnd(a, b, [n(1), 1]); normrnd(mu, sgm, [n(2), 1]); normrnd(mu2, sgm2, [n(3), 1])];
        support = linspace(min(X) - 10, max(X) + 10, 512);
        f = n(1)/sum(n).*gampdf(support, a, b) + n(2)/sum(n).*normpdf(support, mu, sgm) + n(3)/sum(n).*normpdf(support, mu2, sgm2);
        fffob = figure; fffob.Position = [117, 741, 557, 212]; plot(support, f);
        %}

        h = unique([linspace(1e-4, 1e-3, 20), linspace(1e-3, 1e-2, 20), linspace(1e-2, 1e-1, 20), linspace(1e-1, 1e-0, 10)]);

        N = zeros(numel(h), 1);
        S = zeros(numel(h), 1);
        c_dg = zeros(numel(h), 1);
    
        al = 0.10;
        B = 1000;
        
        T_dg = zeros(B, 1);
    
        %%
        fw = waitbar(0, 'Wait...');
        for j=1:numel(h)
            waitbar(j/numel(h), fw, 'Wait...');

            %f_X = wrapper_rkde(X, support, h(j));
            f_X = kde(support, X, h(j));
            f_X = f_X .* scaling;

            [t_b, ~, ~, L_X] = findpeaks(f_X(:));
            PD = [t_b - L_X, t_b];
            
            parfor b=1:B
                Y = datasample(X, numel(X));
                %f_Y = wrapper_rkde(Y, support, h(j));
                f_Y = kde(support, Y, h(j));
                f_Y = f_Y.*scaling;

                [t_b, ~, ~, L_Y] = findpeaks(f_Y(:));
                PD_b = [t_b - L_Y, t_b];
                T_dg(b) = bottleneckdist(PD_b, PD);
            end
            c_dg(j) = quantile(T_dg, 1 - al);
            
            %%
            N(j) = sum(L_X > c_dg(j));
            S(j) = sum((L_X - c_dg(j)).*(L_X > c_dg(j)));
        end
        close(fw);
        
        idx_N = N == max(N);
        S_max = max(S(idx_N));
        idx_h = S == S_max;

        %f_X = wrapper_rkde(X, support, h(idx_h));
        f_X = kde(support, X, h(idx_h));
        f_X = f_X.*scaling;
        X = Z;

        [~, locs, ~, L_X] = findpeaks(f_X);
        idx_C = locs(L_X > c_dg(idx_h));

        fobj = figure;
        fobj.Position = [25, 240, 385, 490];
        subplot(3, 1 ,1);
        scatter(h, N);
        subplot(3, 1 ,2);
        scatter(h, S);
        subplot(3, 1, 3);
        plot(support_Y, f_X);
        hold on
        stem(support_Y(idx_C), f_X(idx_C));
        scatter(X, zeros(numel(X), 1), 'Marker', '|');
        hold off
        title(material{i}, 'Interpreter', 'none');

        drawnow;
    end
    %}

    %%
    addpath('./lib/two-sample/');
    for i=1:5
        d = pb_effectsize(T{1 + (i - 1)*4}, T{3 + (i - 1)*4});
        fprintf('%3.3f, %s, %s\n', d, material{1 + (i - 1)*4}, material{3 + (i - 1)*4});
    end

    for i=1:5
        d = pb_effectsize(T{1 + (i - 1)*4}, T{4 + (i - 1)*4});
        fprintf('%3.3f, %s, %s\n', d, material{1 + (i - 1)*4}, material{3 + (i - 1)*4});
    end
end

function analysis_ioisim_old
    %%
    outputdir = './output/20220705/';
    datainfofile = {...
        'datainfo_Marsden-complete_song-desc.csv',...
        'datainfo_Marsden-complete_song-recit.csv',...
        'datainfo_Marsden-complete_inst-desc.csv',...
        };
    L = [10, 15, 20, 25, 30, 40, 50, 60, Inf];
    
    addpath('./lib/KDE/');

    %%
    onsetfilepath = [];
    breakfilepath = [];
    audiofilepath = [];
    dataname = [];
    for i=1:numel(datainfofile)
        T = readtable(datainfofile{i});
        onsetfilepath = [onsetfilepath; strcat(T.path, 'onset_', T.dataname, '.csv')];
        breakfilepath = [breakfilepath; strcat(T.path, 'break_', T.dataname, '.csv')];
        audiofilepath = [audiofilepath; strcat(T.audiofilepath, T.dataname, '.wav')];
        dataname = [dataname; T.dataname];
    end

    onsetfilepath = unique(onsetfilepath);
    breakfilepath = unique(breakfilepath);
    audiofilepath = unique(audiofilepath);
    dataname = unique(dataname);

    %%
    h_tdakmeans(onsetfilepath, breakfilepath, dataname);

    %%
    %h_period(onsetfilepath, breakfilepath, dataname);
    
    %%
    %h_pulseclarity(audiofilepath, dataname);

    %%
    %h_recurrence(onsetfilepath, breakfilepath, dataname);

    %%
    %h_comparison(onsetfilepath, breakfilepath, dataname);

    %%
    %h_sim(onsetfilepath, breakfilepath, L, dataname, outputdir);
end

function h_tdakmeans(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}, X{2}, X{end - 2}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);
    
    %%
    addpath('./lib/PH/');
    if count(py.sys.path, '') == 0
        insert(py.sys.path,int32(0), '');
    end

    %{
    addpath(strcat(userpath, '/lib2/Rcall/'));
    Rlib = 'ks';
    Rpath = 'C:\Program Files\R\R-4.0.2\bin\R.exe';
    Rclear();
    Rinit(Rlib, Rpath);
    %}

    %%
    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        datatype = cell(N, 1);

        statistic = cell(N, 1);

        for n=1:N
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            [~, ioiratio] = helper.h_ioi(unique(t_onset), unique(t_break));
            
            X = ioiratio;
            a = -0.1;
            b = 1.1;
            support_x = linspace(a + 1e-12, b - 1e-12, 1024);
            M = numel(X);

            %%
            h_min = std(X)*(log(M)/M);
            h_max = std(X);
            h = linspace(h_min, h_max, 256);

            %{
            Rpush('X', X(:));
            Rrun('h_cv <- hlscv(X, deriv.order=0, bw.ucv=TRUE)');
            h_lscv = Rpull('h_cv');
            Rclear();
            %}
            
            %h(:) = kdebandwidth_lp(X)*0.5;

            %{
            h_ini = kdebandwidth_lp(X);
            %h_ini = kdebandwidth_lscv(X);
            density_X = kde(support_x, X, h_ini);
            B = 1024;
            Y = zeros(B, numel(X));
            for k=1:B
                Y(k, :) = datasample(X, M);
            end
            
            L = zeros(numel(h), 1) + Inf;
            L_B = zeros(B, 1);
            for j=1:numel(h)
                parfor k=1:B
                    density_Y = kde(support_x, Y(k, :), h(j));
                    L_B(k) = sum((density_X - density_Y).^2);
                end

                L(j) = mean(L_B);

                if j > 1 && L(j) > L(j - 1)
                    break;
                end
            end

            [~, idx_min] = min(L);
            h_bs = h(idx_min);

            h(:) = h_bs;
            %}

            %%
            PD = cell(numel(h), 1);
            BL = cell(numel(h), 1);
            locs = cell(numel(h), 1);
            idx_L = cell(numel(h), 1);

            for j=1:numel(h)
                density = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), X, 'UniformOutput', false);
                density = mean(cat(1, density{:}), 1);
                [t_birth, locs{j}, ~, prmn] = findpeaks(density);
                t_death = t_birth - prmn;

                PD{j} = [t_death; t_birth]';
                BL{j} = (t_birth - t_death)';
            end
            
            %{
            %% drop (Tomato)
            fobj = figure;
            fobj.Position = [190, 310, 1624, 680];

            subplot(1, 2, 1);
            for j=1:numel(h)
                [L, idx_st] = sort(BL{j}, 'asc');
                dL = diff(L);
                
                scatter(L, h(j) + zeros(numel(L), 1), 'MarkerEdgeColor', 'b', 'Marker', '.');
                hold on

                if numel(BL{j}) == 1 && numel(BL{j - 1}) == 1
                    break
                end
            end
            hold off
            title(dataname{idx(n)}, 'Interpreter', 'none');

            subplot(1, 2, 2);
            for j=1:numel(h)
                scatter(X, h(j) + zeros(numel(X), 1), 'MarkerEdgeColor', 'Y', 'Marker', '|');
                scatter(support_x(locs{j}), h(j) + zeros(numel(locs{j}), 1), 'MarkerEdgeColor', 'b', 'Marker', '.');
                hold on

                if numel(locs{j}) == 1 && numel(locs{j - 1}) == 1
                    break
                end
            end
            hold off
            
            drawnow
            %}

            %% simple modal clustering
            %{
            B = 2000;
            h_B = zeros(B, 1);
            parfor j=1:B
                Y = datasample(X, M);
                h_B(j) = kdebandwidth_lp(Y);
            end
            
            al = 0.01;
            h_B = sort(h_B);
            h_al = h_B(floor((1 - al/2)*B));
            
            Y = X(:);
            y = X(:)';
            c = meanshift(Y, y, 1e-8, h_al);
            C = uniquetol(c, 1e-6);
            
            %{
            idx_B = floor(al/2 * B):floor((1 - al/2)*B);
            C = cell(numel(idx_B), 1);
            parfor j=1:numel(idx_B)
                c = meanshift(Y, y, 1e-8, h_B(idx_B(j)));
                C{j} = uniquetol(c, 1e-6);
            end

            figure;
            for j=1:numel(C)
                scatter(C{j}, h_B(idx_B(j)).*ones(numel(C{j}), 1), 'Marker', '.', 'MarkerEdgeColor', 'b');
                hold on
            end
            hold off
            %}

            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);
            nummodes(1) = numel(C);
            idx_L{1} = zeros(numel(C), 1);
            for k=1:numel(C)
                [~, idx_L{1}(k)] = min(abs(support_x - C(k)));
            end
            %}

            %% cutoff
            %{
            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);

            for j=1:numel(j)
                if size(PD{j}, 1) == 1
                    break;
                end
                
                [L, idx_st] = sort(BL{j}, 'desc');
                S = cumsum(L)./sum(L);
                idx_cutoff = find(S > 0.6, 1, 'first');
                idx_L{j} = idx_st(1:idx_cutoff);
                nummodes(j) = numel(idx_L{j});

                %{
                L = BL{j}./max(BL{j});
                idx_L{j} = L > 0.25;
                nummodes(j) = sum(idx_L{j});
                dlt_al(j) = (max(abs(PD{j}(~idx_L{j}, 1) - PD{j}(~idx_L{j}, 2))) + min(abs(PD{j}(idx_L{j}, 1) - PD{j}(idx_L{j}, 2))))/2;
                %}

                dlt_al(j) = (max(abs(PD{j}(setdiff(1:numel(L), idx_L{j}), 1) - PD{j}(setdiff(1:numel(L), idx_L{j}), 2))) + min(abs(PD{j}(idx_L{j}, 1) - PD{j}(idx_L{j}, 2))))/2;
            end
            %}
            
            %% Outlier (similar to Adler & Agami, 2019)
            %{
            nummodes = zeros(numel(h), 1);

            parfor j=1:numel(h)
                if size(PD{j}, 1) > 2
                    L = PD{j}(:, 2) - PD{j}(:, 1);
                    x_q1 = quantile(L, 0.25);
                    x_q2 = quantile(L, 0.50);
                    x_q3 = quantile(L, 0.75);
                    IQR = x_q3 - x_q1;
    
                    L_l = L(L <= x_q2);
                    L_u = L(L >= x_q2);
                    h_kernel = @(x_i, x_j) ((x_j - x_q2) - (x_q2 - x_i))./(x_j - x_i);
                    H = arrayfun(@(x_i) h_kernel(x_i, L_u), L_l, 'UniformOutput', false);
                    H = cat(1, H{:});
                    mc = median(H);
    
                    if mc >= 0
                        L_lb = x_q1 - 1.5*exp(-4*mc)*IQR;
                        L_ub = x_q3 + 1.5*exp(3*mc)*IQR;
                    else
                        L_lb = x_q1 - 1.5*exp(-3*mc)*IQR;
                        L_ub = x_q3 + 1.5*exp(4*mc)*IQR;
                    end
                    
                    idx_L{j} = find((L < L_lb) | (L > L_ub));
                    nummodes(j) = numel(idx_L{j});
                end
            end
            %}

            %% persistence entropy, Atienza et al. (2019)
            %{
            nummodes = zeros(numel(h), 1);

            for j=1:1
                L = PD{j}(:, 2) - PD{j}(:, 1);
                idx_L{j} = h_persistentEntropy(L);
                nummodes(j) = numel(idx_L{j});
            end
            %}

            %% Sommerfeld et al. (2017)
            %{
            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);

            al = 0.05;
            K = 2000;
            dlt = zeros(K, 1);

            J = 1;
            S = floor(M*(1 - exp(-1))) + 1;
            
            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');
                
                if size(PD{j}, 1) == 1
                    break;
                end

                density = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), X, 'UniformOutput', false);
                density = mean(cat(1, density{:}), 1);
                
                parfor k=1:K
                    %%
                    %Y = datasample(X, M);
                    Y = datasample(X, S);
                    while numel(uniquetol(Y, 1e-6)) ~= S
                        Y = [Y, datasample(X, J)];
                    end

                    Y = Y + h(j).*normrnd(0, 1, size(Y));
                    density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Y, 'UniformOutput', false);
                    density_Y = mean(cat(1, density_Y{:}), 1);

                    dlt(k) = max(abs(density - density_Y));
                end
                dlt_al(j) = quantile(dlt, 1 - al);

                idx_al = (PD{j}(:, 2) - PD{j}(:, 1)) > dlt_al(j);
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}
            
            %% Fasy et al. (2014) + subsampling
            %{
            nummodes = zeros(numel(h), 1);

            al = 0.05;
            K = 400;
            dlt = zeros(K, 1);

            I = 20;
            y_i = zeros(I, 1);
            b = round(M.^(linspace(0.5, 0.98, I)'));
            J = 200;
            t = repmat(rand(J, 1)*0.5, [1, 2]);
            t(:, 2) = 1 - t(:, 2);
            
            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end
                
                for idx_b=1:numel(b)
                    parfor k=1:K
                        %%
                        Y = datasample(X, b(idx_b), 'Replace', false);
                        
                        density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Y, 'UniformOutput', false);
                        density_Y = mean(cat(1, density_Y{:}), 1);
    
                        [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                        t_death_b = t_birth_b - prmn;
                        PD_b = [t_death_b; t_birth_b]';
                        dlt(k) = bottleneckdist(PD_b, PD{j});
                    end

                    y_ij = log(quantile(dlt, t(:, 2)) - quantile(dlt, t(:, 1)));
                    y_i(idx_b) = mean(y_ij);
                end

                y_ = mean(y_i);
                log_ = mean(log(b));
                al_IJ = -sum((y_i - y_).*(log(b) - log_))/sum((log(b) - log_).^2);
                tau = M^al_IJ;

                dlt_al = tau*quantile(dlt, 1 - al);

                %dlt_al = svmsample(X, al, PD{j}, h(j), support_x);

                idx_al = ~((PD{j}(:, 1) + dlt_al) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %% Comaniciu et al. (2001)
            %y = adaptivemeanshift(X(:), X(:)', 1e-6, h(1));

            %% Fasy et al. (2014)
            %{
            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);

            al = 0.05;
            K = 2000;
            dlt = zeros(K, 1);
            
            fw = waitbar(0, 'Wait...');
            for j=1:1
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end
                
                tic;
                parfor k=1:K
                    %%
                    Y = datasample(X, M);
                    h_Y = kdebandwidth_lp(Y);
                    
                    %density_Y = debiasedkde(support_x, Y, h_Y);
                    density_Y = kde(support_x, Y, h_Y);
                    %density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h_Y), Y, 'UniformOutput', false);
                    %density_Y = mean(cat(1, density_Y{:}), 1);

                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_b = [t_death_b; t_birth_b]';

                    dlt(k) = bottleneckdist(PD_b, PD{j});
                end
                dlt_al(j) = quantile(dlt, 1 - al);

                idx_al = ~((PD{j}(:, 1) + dlt_al(j)) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al(j)));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}
            
            %% Fasy et al. (2014) - sufficient m/n bootstrap
            %{
            nummodes = zeros(numel(h), 1);

            al = 0.05;
            K = 2000;
            dlt = zeros(K, 1);

            m_1 = round(M^(1 + log(2/3)/log(M)));
            eta_m = round(1 + M*(1 - exp(-m_1/M)));
            
            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end
                
                parfor k=1:K
                    %%
                    Y = datasample(X, m_1);
                    Y = uniquetol(Y, 1e-6);

                    if numel(Y) > eta_m
                        Y = Y(randperm(numel(Y), eta_m));
                    elseif numel(Y) < eta_m
                        X_d = setdiff(X, Y);
                        Y = [Y, X_d(randperm(numel(X_d), eta_m - numel(Y)))];
                    end

                    Y = Y + h(j).*normrnd(0, 1, size(Y));
                    
                    density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Y, 'UniformOutput', false);
                    density_Y = mean(cat(1, density_Y{:}), 1);

                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_b = [t_death_b; t_birth_b]';
                    dlt(k) = bottleneckdist(PD_b, PD{j});
                end
                dlt_al = quantile(dlt, 1 - al);

                %dlt_al = svmsample(X, al, PD{j}, h(j), support_x);

                idx_al = ~((PD{j}(:, 1) + dlt_al) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %% Fasy et al. (2014) - sequential bootstrap
            %{
            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);

            al = 0.05;
            K = 3000;
            dlt = zeros(K, 1);

            J = 1;
            S = floor(M*(1 - exp(-1))) + 1;
            
            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');

                if j > 1 && size(PD{j}, 1) == 1
                    break;
                end

                support_x = linspace(-h(j)*5, 1 + h(j)*5, 1024);

                parfor k=1:K
                    %%
                    Y = datasample(X, S);
                    while numel(uniquetol(Y, 1e-6)) ~= S
                        Y = [Y, datasample(X, J)];
                    end

                    h_Y = h(j);
                    Y = Y + h_Y.*normrnd(0, 1, size(Y));
                    
                    density_Y = kde(support_x, Y, h_Y);
                    %density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h_Y), Y, 'UniformOutput', false);
                    %density_Y = mean(cat(1, density_Y{:}), 1);
                    %density_Y = debiasedkde(support_x, Y, h(j));

                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_b = [t_death_b; t_birth_b]';

                    dlt(k) = bottleneckdist(PD_b, PD{j});
                end
                dlt_al(j) = quantile(dlt, 1 - al);

                idx_al = ~((PD{j}(:, 1) + dlt_al(j)) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al(j)));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %% Fasy et al. (2014) - double bootstrap
            %{
            nummodes = zeros(numel(h), 1);
            dlt_al = zeros(numel(h), 1);

            al = 0.05;
            K = 500;
            KK = 50;
            dlt = zeros(K, 1);
            dlt_K = zeros(KK, 1);

            I = (1:(KK + 1))./(KK + 1);
            idx_C = find(I < (1 - al), 1, 'last');

            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end
                
                for k=1:K
                    %%
                    Y = datasample(X, M);
                    Z = Y + h(j).*normrnd(0, 1, size(Y));

                    density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Z, 'UniformOutput', false);
                    density_Y = mean(cat(1, density_Y{:}), 1);
                    
                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_Y = [t_death_b; t_birth_b]';

                    parfor kk=1:KK
                        Z = datasample(Y, M);
                        Z = Z + h(j).*normrnd(0, 1, size(Z));

                        density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Z, 'UniformOutput', false);
                        density_Y = mean(cat(1, density_Y{:}), 1);

                        [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                        t_death_b = t_birth_b - prmn;
                        PD_b = [t_death_b; t_birth_b]';

                        dlt_K(kk) = bottleneckdist(PD_b, PD_Y);
                    end
                    dlt_K = sort(dlt_K);
                    
                    dlt(k) = (idx_C + 1 - (KK + 1)*(1 - al))*dlt_K(idx_C) + ((KK + 1)*(1 - al) - idx_C)*dlt_K(idx_C + 1);
                end
                dlt_al(j) = quantile(dlt, 1 - al);

                idx_al = ~((PD{j}(:, 1) + dlt_al(j)) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al(j)));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %% Fasy et al. (2014) + data split
            %{
            nummodes = zeros(numel(h), 1);

            al = 0.05;
            K = 1000;
            dlt = zeros(K, 1);
            
            fw = waitbar(0, 'Wait...');
            for j=1:numel(h)
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end
                
                M_half = round(M/2);
                I = 1:M;

                parfor k=1:K
                    %%
                    idx_X = randperm(M, M_half);
                    idx_Y = setdiff(I, idx_X);

                    Z = X(idx_X);
                    density_Z = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Z, 'UniformOutput', false);
                    density_Z = mean(cat(1, density_Z{:}), 1);
                    
                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Z);
                    t_death_b = t_birth_b - prmn;
                    PD_Z = [t_death_b; t_birth_b]';

                    Y = X(idx_Y);
                    density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Y, 'UniformOutput', false);
                    density_Y = mean(cat(1, density_Y{:}), 1);

                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_Y = [t_death_b; t_birth_b]';

                    dlt(k) = bottleneckdist(PD_Y, PD_Z);
                end
                dlt_al = quantile(dlt, 1 - al);

                %dlt_al = svmsample(X, al, PD{j}, h(j), support_x);

                idx_al = ~((PD{j}(:, 1) + dlt_al) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %% Fasy et al. (2014) + Normal-bundle bootstrap
            %{
            nummodes = zeros(numel(h), 1);
            al = 0.20;
            K = 1000;
            dlt = zeros(K, 1);

            idx_M = (1:M)';
            
            fw = waitbar(0, 'Wait...');
            for j=1:3
                waitbar(j/numel(h), fw, 'Wait...');

                if size(PD{j}, 1) == 1
                    break;
                end

                r = meanshift(X(:), X(:)', 1e-6, h(j));
                eta = X - r;
                K_mat = knnsearch(r', r', 'K', max(3, round(M*0.05)));
                K_mat = K_mat(:, 2:end);
                idx_Kmat = randi(size(K_mat, 2), [M, K]);
    
                parfor k=1:K
                    %%
                    eta_k = eta(arrayfun(@(i, j) K_mat(i, j), idx_M, idx_Kmat(:, k)));
                    Y = r + eta_k;
                    
                    density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h(j)), Y, 'UniformOutput', false);
                    density_Y = mean(cat(1, density_Y{:}), 1);
    
                    [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                    t_death_b = t_birth_b - prmn;
                    PD_b = [t_death_b; t_birth_b]';
                    dlt(k) = bottleneckdist(PD_b, PD{j});
                end
                
                dlt_al = quantile(dlt, 1 - al);
                idx_al = ~((PD{j}(:, 1) + dlt_al) > PD{j}(:, 2) | PD{j}(:, 1) > (PD{j}(:, 2) - dlt_al));
                nummodes(j) = sum(idx_al);
                idx_L{j} = idx_al;
            end
            close(fw);
            %}

            %%
            %{
            figobj = figure;
            figobj.Position = [660, 660, 1200, 300];

            idx_h = find(nummodes == max(nummodes), 1, 'last');
            support_x = linspace(a + 1e-12, b - 1e-12, 1024);

            subplot(1, 4, 1);
            h_cv = kdebandwidth_lp(X);
            density = arrayfun(@(X_i) normpdf(support_x, X_i, h_cv), X, 'UniformOutput', false);
            density = mean(cat(1, density{:}), 1);
            plot(support_x, density);
            hold on
            stem(support_x(locs{idx_h}(idx_L{idx_h})), density(locs{idx_h}(idx_L{idx_h})), 'Marker', 'none');
            hold off
            title(dataname{idx(n)}, 'Interpreter', 'none');
            
            subplot(1, 4, 2);
            plot(nummodes);
            
            subplot(1, 4, 3);
            scatter(PD{idx_h}(:, 1), PD{idx_h}(:, 2), 'Marker', '.');
            lmax = max(max(xlim()), max(ylim()));
            hold on
            plot([0, lmax], [0, lmax], '-.m');
            plot([0, lmax - dlt_al(idx_h)], [dlt_al(idx_h), lmax]);
            hold off
            xlim([0, lmax]); ylim([0, lmax]);

            subplot(1, 4, 4);
            density = arrayfun(@(X_i) normpdf(support_x, X_i, h(idx_h)), X, 'UniformOutput', false);
            density = mean(cat(1, density{:}), 1);
            plot(support_x, density);
            hold on
            scatter(support_x(locs{idx_h}), density(locs{idx_h}));
            stem(support_x(locs{idx_h}(idx_L{idx_h})), density(locs{idx_h}(idx_L{idx_h})), 'Marker', 'none');
            %stem(support_x(idx_L{idx_h}), density(idx_L{idx_h}), 'Marker', 'none');
            hold off

            drawnow();
            
            %%
            idx_h = find(nummodes == max(nummodes), 1, 'last');
            centroid = support_x(locs{idx_h}(idx_L{idx_h}));
            %centroid = support_x(idx_L{idx_h});
            idx_K= kmeans(X(:), numel(centroid), 'Start', centroid(:));
            
            statistic{n} = X;
            for k=1:numel(centroid)
                idx_X = idx_K == k;
                statistic{n}(idx_X) = abs(X(idx_X) - centroid(k));
            end
            %}

            %%
            s = strsplit(dataname{idx(n)}, '_');
            datatype{n} = s{end};
        end

        %%
        [~, idx] = sort(datatype);
        
        addpath('./lib/two-sample/');
        d = zeros(4, 1);
        d(1) = pb_effectsize(statistic{idx(4)}, statistic{idx(1)});
        d(2) = pb_effectsize(statistic{idx(4)}, statistic{idx(3)});
        d(3) = pb_effectsize(statistic{idx(2)}, statistic{idx(1)});
        d(4) = pb_effectsize(statistic{idx(2)}, statistic{idx(3)});
        fprintf('%s-%s: %3.3f\n', datatype{idx(4)}, datatype{idx(1)}, d(1));
        fprintf('%s-%s: %3.3f\n', datatype{idx(4)}, datatype{idx(3)}, d(2));
        fprintf('%s-%s: %3.3f\n', datatype{idx(2)}, datatype{idx(1)}, d(3));
        fprintf('%s-%s: %3.3f\n', datatype{idx(2)}, datatype{idx(3)}, d(4));
    end
end

function idx = h_persistentEntropy(L)
    %%
    if numel(L) == 1
        idx = 1;
        return
    end

    L_orig = L;

    %%
    T = max(L);
    r = min(L);
    L = [sort(setdiff(L, [r; T]), 'desc'); r; T];
    
    h_pdent = @(L) -sum(L./sum(L).*log(L./sum(L)));
    h_QE = @(idx, n, T, r) arrayfun(@(i) h_pdent([repmat(T, [i, 1]); repmat(r, [n - i, 1])]), idx);
    
    %%
    n_dash = numel(L);
    L_dash = L;
    L_prev = [];

    while true
        %%
        S_Lj = sum(L_dash);
        m = 0;

        for i=1:(n_dash - 2)
            R_i = L_dash(i + 1:end);
            P_i = sum(R_i);
            l_dash = P_i/exp(h_pdent(R_i));
            S_Li = P_i + i*l_dash;
            C = S_Lj/S_Li;
            m = i;

            if C < 1
                break;
            end

            S_Lj = S_Li;
        end
        
        %%
        E_i = h_QE(0:n_dash, n_dash, T, r);
        [~, Q] = min(E_i);
        Q = Q - 1;

        %%
        if Q < m
            L_dash = [L_dash(1:m); L_dash(end - 1:end)];

            if numel(L_prev) == numel(L_dash) && all(L_prev == L_dash)
                L_dash = [L_dash(1:end - 2); L_dash(end)];
                break;
            end
            L_prev = L_dash;

            n_dash = m + 2;
        else
            L_dash = [L_dash(1:m); L_dash(end)];
            break;
        end
    end

    %%
    idx = arrayfun(@(l) find(L_orig == l, 1, 'first'), L_dash);
end

function dlt = svmsample(X, al, PD, h, support_x)
    %%
    n = numel(X);
    p = repmat(1/n, [n, 1]);
    N = 100;
    M = 1000;
    rho = 1 - al;
    eta = mean([rho, 1]);
    k = 0;
    T = zeros(N, 1);
    C = zeros(N, n);
    
    %%
    while k >= 0
        parfor j=1:N
            Z = datasample(X, n, 'Weights', p, 'Replace', true);
            C(j, :) = arrayfun(@(X_i) sum(Z == X_i), X)';
    
            density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h), Z, 'UniformOutput', false);
            density_Y = mean(cat(1, density_Y{:}), 1);
            [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
            t_death_b = t_birth_b - prmn;
            PD_b = [t_death_b; t_birth_b]';
            T(j) = bottleneckdist(PD_b, PD);
        end
        
        %%
        lognp = log(n.*p)';
        [~, idx] = sort(T, 'ascend');
        S = zeros(N, 1);
    
        for r=1:N
            for j=1:r
                S(r) = S(r) + exp(sum(-C(idx(j), :).*lognp));
            end
        end
        S = S./N;
    
        %%
        if S(floor(eta*N)) > rho
            Aeq = ones(1, numel(p));
            beq = 1;
            lb = zeros(numel(p), 1) + 1e-16;
            ub = zeros(numel(p), 1) + (1 - 1e-16);
    
            h_rminf = @(x) x(~isinf(x));
    
            gam = T(idx(floor(eta*N)));
            I = T <= gam;
    
            costfun = @(p) sum(h_rminf(...
                log(I.*1) + log(sum((n.*p').^(-C), 2)) + log(sum((n.*p'.^k).^(-C), 2))...
            )) - log(N);
    
            p_optm = fmincon(costfun, p, [], [], Aeq, beq, lb, ub);
    
            p = p_optm;
            k = k + 1;
        else
            T_M = zeros(M - (k + 1)*N, 1);
            parfor j=1:numel(T_M)
                Z = datasample(X, n, 'Weights', p, 'Replace', true);
        
                density_Y = arrayfun(@(X_i) normpdf(support_x, X_i, h), Z, 'UniformOutput', false);
                density_Y = mean(cat(1, density_Y{:}), 1);
                [t_birth_b, ~, ~, prmn] = findpeaks(density_Y);
                t_death_b = t_birth_b - prmn;
                PD_b = [t_death_b; t_birth_b]';
                T_M(j) = bottleneckdist(PD_b, PD);
            end

            T_all = [T; T_M];
            dlt = quantile(T_all, rho);

            k = -1;
        end
    end
end

function h_pulseclarity(audiofilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);
    
    datatype = cellfun(@(X) strcat(X{end}), s, 'UniformOutput', false);
    typelist = unique(datatype);

    %%
    folder = strcat(userpath, '/lib2/MIRToolbox1.8.1');
    addpath(genpath(folder));
    
    C = zeros(numel(dataidlist), 1);

    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        
        for n=1:N
            p = mirpulseclarity(audiofilepath{idx(n)});
            C(idx(n)) = mirgetdata(p);
        end
    end

    %%
    figobj = figure;
    colorcode = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'};

    for i=1:numel(typelist)
        idx_i = strcmp(datatype, typelist{i});

        for j=1:numel(dataidlist)
            idx_j = strcmp(dataid, dataidlist{j});
            idx = idx_i & idx_j;

            scatter(i, C(idx), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', colorcode{j});
            hold on
        end
    end
    legend(dataidlist, 'FontSize', 10);
    hold off
    xticks(1:numel(typelist));
    xticklabels(typelist);
    xlim([0.5, numel(typelist) + 0.5]);
    ylim([0, max(C)*1.3]);
    ylabel('Pulse clarity', 'FontSize', 12);
    ax = gca(figobj);
    ax.FontSize = 10;
end

function h_period(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);
    
    datatype = cellfun(@(X) strcat(X{end}), s, 'UniformOutput', false);
    typelist = unique(datatype);

    %%
    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        
        for n=1:N
            fprintf('%s\n', dataname{idx(n)});
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            
            t_obi = cell(numel(t_break) + 1, 1);
            t_lb = 0;
            for j=1:numel(t_break)
                t_rb = t_break(j);
                idx_j = t_onset > t_lb & t_onset < t_rb;
                t_obi{j} = t_onset(idx_j);
                t_obi{j} = t_obi{j} - t_obi{j}(1);

                t_lb = t_rb;
            end

            if t_lb < max(t_onset)
                j = j + 1;

                t_rb = max(t_onset) + 0.1;
                idx_j = t_onset > t_lb & t_onset < t_rb;
                t_obi{j} = t_onset(idx_j);
                t_obi{j} = t_obi{j} - t_obi{j}(1);
            else
                t_obi(end) = [];
            end

            figure;
            for j=1:numel(t_obi)
                scatter(t_obi{j}, zeros(numel(t_obi{j}), 1) + j, 'Marker', '.');
                hold on
            end
            hold off
            title(dataname{idx(n)}, 'Interpreter', 'none');
            ylim([0, numel(t_obi) + 1]);
        end
    end
end

function h_recurrence(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);
    
    datatype = cellfun(@(X) strcat(X{end}), s, 'UniformOutput', false);
    typelist = unique(datatype);

    %%
    H = zeros(numel(dataidlist), 1);

    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        
        for n=1:N
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            [ioi, ~] = helper.h_ioi(unique(t_onset), unique(t_break));
            
            H_max = -Inf;
            H_m = 0;
            M = 1;
            while H_max < H_m
                H_max = H_m;
                M = M + 1;
                [H_m, ~] = recmaxent(ioi, M, 40000);
            end
            
            H(idx(n)) = H_max;
            fprintf('M = %d, %s %s\n', M - 1, datetime, dataname{idx(n)});
        end
    end

    %%
    figobj = figure;
    colorcode = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'};

    for i=1:numel(typelist)
        idx_i = strcmp(datatype, typelist{i});

        for j=1:numel(dataidlist)
            idx_j = strcmp(dataid, dataidlist{j});
            idx = idx_i & idx_j;

            scatter(i, H(idx), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', colorcode{j});
            hold on
        end
    end
    legend(dataidlist, 'FontSize', 10);
    hold off
    xticks(1:numel(typelist));
    xticklabels(typelist);
    xlim([0.5, numel(typelist) + 0.5]);
    ylabel('Recurrence Entropy (nat)', 'FontSize', 12);
    ax = gca(figobj);
    ax.FontSize = 10;
end

function [H_max, B] = recmaxent(X, N, M)
    %%
    L = numel(X) - N + 1;
    I = arrayfun(@(x) [1:(x - 1); repmat(x, [1, x - 1])], 2:L, 'UniformOutput', false);
    I = cat(2, I{:})';
    idx = randperm(size(I, 1))';
    R = zeros(N^2, min(size(idx, 1), M));

    %%
    parfor m=1:size(R, 2)
        idx_st = I(idx(m), 1);
        idx_ed = idx_st + N - 1;
        X_m = X(idx_st:idx_ed);

        idx_st = I(idx(m), 2);
        idx_ed = idx_st + N - 1;
        Y_m = X(idx_st:idx_ed);

        R_m = X_m - Y_m';

        R(:, m) = R_m(:);
    end

    %%
    R = abs(R);
    H = zeros(512, 2);
    eps_max = max(R(:));
    eps = rand(size(H, 1), 1).*eps_max;

    parfor i=1:size(H, 1)
        H(i, :) = [h_REnt(R, eps(i)), eps(i)];
    end

    [~, idx_max] = max(H(:, 1));
    H_max = H(idx_max, 1);
    eps_opt = H(idx_max, 2);
    B = R';
    B(R <= eps_opt) = 1;
    B(R > eps_opt) = 0;
end

function H = h_REnt(R, eps)
    %%
    B = R';
    B(R <= eps) = 1;
    B(R > eps) = 0;

    %%
    [~, ~, ic] = unique(B, 'rows');

    %%
    C = histcounts(ic, unique(ic));
    N = numel(ic);
    P = C./N;
    H = -sum(P.*log(P));
end

function h_comparison(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}, X{2}, X{end - 2}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);

    %%
    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        density = cell(N, 1);
        support = cell(N, 1);
        datatype = cell(N, 1);
        birth = cell(N, 1);
        death = cell(N, 1);
        pos = cell(N, 1);
        dist = cell(N, 1);
        ioipair = cell(N, 1);
        ioi = cell(N, 1);
        
        for n=1:N
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            [ioi{n}, ioiratio, ~, ~, ioipair{n}] = helper.h_ioi(unique(t_onset), unique(t_break));
            [density{n}, support{n}] = h_kde(ioiratio, 0, 1);

            s = strsplit(dataname{idx(n)}, '_');
            datatype{n} = s{end};

            [birth{n}, locs, ~, p] = findpeaks(density{n}, 'MinPeakHeight', 1e-10);
	        death{n} = birth{n} - p;
            pos{n} = support{n}(locs);
            dist{n} = 0.5.*(birth{n} - death{n});
        end
        
        %%
        [~, idx] = sort(datatype);
        
        %%{
        figobj = figure();
        figobj.Position = [100, 800, 940, 180];
        for n=1:N
            subplot(1, N, n);
            scatter(ioipair{idx(n)}(:, 1), ioipair{idx(n)}(:, 2), 'Marker', '.');
            title(datatype{idx(n)}, 'FontSize', 12);
        end

        figobj = figure;
        figobj.Position = [55, 653, 1000, 250];
        for n=1:N
            subplot(1, N, n);
            plot(support{idx(n)}, density{idx(n)});
            title(datatype{idx(n)}, 'FontSize', 12);
        end
        %}
        %{
        figure(4);
        clf; cla;
        for n=1:N
            scatter(death{n}, birth{n});
            hold on
        end
        m = max(max(xlim()), max(ylim()));
        xlim([0, m]);
        ylim([0, m]);
        plot([0, m], [0, m], '-.k');
        hold off;
        legend(datatype, 'location', 'southeast');

        figure(5);
        clf; cla;
        for n=1:N
            stem(pos{n}, dist{n});
            hold on
        end
        hold off;
        legend(datatype, 'location', 'northeast');
        %}
    end
end

function h_sim(onsetfilepath, breakfilepath, L, dataname, outputdir)
    %%
    N = numel(onsetfilepath);
    
    %%
    for n=1:N
        [t_onset, t_break] = h_onsetbreak(onsetfilepath{n}, breakfilepath{n});
        T_max = max(max(t_onset), max(t_break));
        I = find(T_max < L, 1, 'first');

        figobj1 = figure(1);
        clf; cla;
        figobj1.Position = [100, 340, 650, 630];

        figobj2 = figure(2);
        clf; cla;
        figobj2.Position = [750, 340, 650, 630];

        for i=1:I
            idx_onset = t_onset < L(i);
            idx_break = t_break < L(i);
            
            [ioi, ioiratio] = helper.h_ioi(t_onset(idx_onset), t_break(idx_break));
            
            ioiratio_rnd = h_randomioiratio(ioi);

            [density, support] = h_kde(ioiratio, 0, 1);
            [density_rnd, ~] = h_kde(ioiratio_rnd, 0, 1);
            
            figure(1);
            subplot(3, 3, i);
            h_plot1(ioiratio, support, density, density_rnd, L(i), dataname{n});

            figure(2);
            subplot(3, 3, i);
            h_plot2(ioiratio, L(i), dataname{n});
        end
        drawnow
       
        saveas(figobj1, strcat(outputdir, dataname{n}, '_ioiratio1.png'));
        saveas(figobj2, strcat(outputdir, dataname{n}, '_ioiratio2.png'));
    end
end

function [t_onset, t_break] = h_onsetbreak(onsetfilepath, breakfilepath)
    %%
    T = readtable(onsetfilepath);
    t_onset = table2array(T(:, 1));
    
    %%
    T = readtable(breakfilepath, 'ReadVariableNames', false);
    
    if isempty(T)
        t_break = [];
    else
        t_break = table2array(T(:, 1));

        if iscell(t_break)
            t_break = str2double(cell2mat(t_break));
        end
    end
end

function ioiratio_rnd = h_randomioiratio(ioi)
    %%
    M = 10000;
    ioi_min = min(ioi);
    ioi_max = max(ioi);
    ioi_rnd = rand(M, 1).*(ioi_max - ioi_min) + ioi_min;
    
    %%
    ioiratio_rnd = [0; ioi_rnd(2:end); 0]./conv(ioi_rnd, [1; 1]);
    ioiratio_rnd = ioiratio_rnd(2:end - 1);
end

function [density, support, C] = h_kde(X, a, b)
    %%
    support_x = linspace(a + 1e-12, b - 1e-12, 1024);

    %%
    h = kdebandwidth_lp(X);
    density = arrayfun(@(X_i) normpdf(support_x, X_i, h), X, 'UniformOutput', false);
    density = mean(cat(1, density{:}), 1);
    support = support_x;
    
    %%
    C = trapz(support, density);
    fprintf('Check: N = %d, h = %3.5f, C = %e\n', numel(X), h, C);
end

function h_plot1(X, support, density, density_rnd, L, dataname)
    %%
    intratio = [1/4, 1/3, 1/2, 2/3, 3/4];

    %%
    s = strsplit(dataname, '_');
    titlestr = {['IOI ratio distribution (t < ', num2str(L, '%d'), ')'], ['N = ', num2str(numel(X), '%d'), ', ', s{1}, '-', s{end}]};

    %%
    figure(1);
    plot(support, density);
    yl = ylim();
    hold on;
    plot(support, density_rnd, '-.m');
    scatter(X, zeros(numel(X), 1), 'Marker', '|')
    for i=1:numel(intratio)
        plot(intratio(i).*[1, 1], yl, ':k');
    end
    hold off;
    title(titlestr, 'Interpreter', 'none', 'FontSize', 11);

    xlim([0, 1]);
end

function h_plot2(X, L, dataname)
    %%
    intratio = [1/4, 1/3, 1/2, 2/3, 3/4];

    %%
    s = strsplit(dataname, '_');
    titlestr = {['sorted IOI ratio data (t < ', num2str(L, '%d'), ')'], [s{1}, '-', s{end}]};
    
    N = numel(X);

    %%
    scatter(1:N, sort(X), 'Marker', '.');
    title(titlestr, 'Interpreter', 'none', 'FontSize', 11);
    xlim([1, N]);
    ylim([0, 1]);
    xl = xlim();
    hold on;
    for i=1:numel(intratio)
        plot(xl, intratio(i).*[1, 1], ':k');
    end
    hold off;
end