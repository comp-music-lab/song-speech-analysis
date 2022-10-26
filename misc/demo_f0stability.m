function demo_f0stability
    %%
    dirlist = {...
        './data/Stage 1 RR Full/Dhwani/',...
        './data/Stage 1 RR Full/Shafagh/',...
        './data/Stage 1 RR Full/Florence/',...
        './data/Stage 1 RR Full/Patrick/',...
        './data/Stage 1 RR Full/Yuto/'...
    };

    fileidlist = {...
        strcat('Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_', {'20220320_inst', '20220320_recit', '20220320_song', '20220430_desc'}),...
        strcat('Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_', {'20220430_recit', '20220430_song', '20220502_desc', '20220507_inst'}),...
        strcat('Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_', {'20220504_desc', '20220504_inst', '20220504_recit', '20220504_song'}),...
        strcat('John_McBride_English_Irish_Anthem_FieldsOfAthenry_', {'20220219_desc', '20220219_inst', '20220219_recit', '20220219_song'}),...
        strcat('Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_', {'20220209_desc', '20220209_recit', '20220209_song', '20220224_inst'})...
    };
    
    outputdir = './output/20221025/';

    %% extraction
    addpath('./lib/CWT/');
    addpath('./util/');
    reffreq = 440;

    h_getlast = @(X) X{end};
    typelist = cellfun(@(f) cellfun(@(g) h_getlast(strsplit(g, '_')), f, 'UniformOutput', false), fileidlist, 'UniformOutput', false);
    typelist = cat(2, typelist{:});

    f0filepath = cellfun(@(d, f) strcat(d, f, '_f0.csv'), dirlist, fileidlist, 'UniformOutput', false);
    f0filepath = cat(2, f0filepath{:});

    onsetfilepath = cellfun(@(d, f) strcat(d, 'onset_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    onsetfilepath = cat(2, onsetfilepath{:});

    breakfilepath = cellfun(@(d, f) strcat(d, 'break_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    breakfilepath = cat(2, breakfilepath{:});
    
    f0 = cell(numel(f0filepath), 1);
    t_onset = cell(numel(onsetfilepath), 1);
    t_break = cell(numel(breakfilepath), 1);
    modulationmagnitude = cell(numel(f0filepath), 1);
    f0mad = cell(numel(f0filepath), 1);
    f0var = cell(numel(f0filepath), 1);

    med_mm = zeros(numel(f0filepath), 1);
    med_mad = zeros(numel(f0filepath), 1);
    med_var = zeros(numel(f0filepath), 1);

    targetsamplingfrequency = 22050;

    for i=1:numel(f0)
        %% Read f0, onset and break files
        T = readtable(f0filepath{i});
        f0{i} = T.voice_1;
        t_f0 = T.time;

        T = readtable(onsetfilepath{i}, 'ReadVariableNames', false);
        t_onset{i} = unique(T.Var1);

        T = readtable(breakfilepath{i}, 'ReadVariableNames', false);
        t_break{i} = unique(T.Var1);
        if iscell(t_break{i})
            t_break{i} = str2double(cell2mat(t_break{i}));
        end

        %% Christina's method
        [~, ~, t_st, t_ed, ~] = helper.h_ioi(t_onset{i}, t_break{i});
        f0_cent = 1200.*log2(f0{i}./440);
        for j=1:numel(t_st)
            [~, idx_st] = min(abs(t_f0 - t_st(j)));
            [~, idx_ed] = min(abs(t_f0 - t_ed(j)));
            f0_cent_ij = f0_cent(idx_st:idx_ed);
            f0_cent_ij = f0_cent_ij(~isinf(f0_cent_ij));

            if ~isempty(f0_cent_ij)
                f0mad{i}(end + 1) = mad(f0_cent_ij);
                f0var{i}(end + 1) = var(f0_cent_ij);
            end
        end

        med_mad(i) = median(f0mad{i});
        med_var(i) = median(f0var{i});

        %% Delta f0 method
        tmp = ft_deltaf0(f0{i}, 0.005, reffreq);
        tmp = abs(tmp);
        modulationmagnitude{i} = tmp(~isnan(tmp));
        med_mm(i) = median(modulationmagnitude{i});

        samplinginterval = t_f0(2) - t_f0(1);
        decimatedframes = round(samplinginterval * targetsamplingfrequency);
        fmsignal = f0synth(f0{i}, targetsamplingfrequency, decimatedframes);

        s = strsplit(f0filepath{i}, '/');
        s = strsplit(s{end}, '.');
        audiowrite(strcat(outputdir, s{end - 1}, 'synth.wav'), fmsignal, targetsamplingfrequency);
    end
    
    %%
    h_getfirst = @(X) X{1};
    artistname = cellfun(@(f) h_getlast(strsplit(h_getfirst(strsplit(f, '_')), '/')), f0filepath, 'UniformOutput', false);
    dataname = strcat(typelist, ' (', artistname, ')');
    
    [~, idx_mm] = sort(med_mm, 'asc');
    [~, idx_mad] = sort(med_mad, 'asc');
    [~, idx_var] = sort(med_var, 'asc');

    h_vec = @(X) X(:);
    T = table(h_vec(num2cell(1:20)), h_vec(dataname(idx_mm)), med_mm(idx_mm), h_vec(dataname(idx_mad)), med_mad(idx_mad), h_vec(dataname(idx_var)), med_var(idx_var),...
        'VariableNames', {'Rank', 'df0_data', 'df0_median', 'mad_data', 'mad_median', 'var_data', 'var_median'});
    
    writetable(T, strcat(outputdir, 'rankdata.csv'))

    %%
    figure(1);

    
    subplot(1, 3, 1);
    scatter(1:20, med_mm(idx));
    xticks(1:20);
    xticklabels(strcat(artistname(idx), '(', typelist(idx), ')'));

    
    subplot(1, 3, 2);
    scatter(1:20, med_mad(idx));
    xticks(1:20);
    xticklabels(strcat(artistname(idx), ' (', typelist(idx), ')'));

    [~, idx] = sort(med_var, 'asc');
    subplot(1, 3, 3);
    scatter(1:20, med_var(idx));
    xticks(1:20);
    xticklabels(strcat(artistname(idx), ' (', typelist(idx), ')'));
end