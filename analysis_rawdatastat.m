function analysis_rawdatastat
    %%
    outputdir = './output/20220918/';
    
    audiodir = './data/Stage 1 RR Audio/full-length/';

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
    
    langlist = {'Marathi', 'Farsi', 'Yoruba', 'English', 'Japanese'};
    sex = {'m', 'f', 'f', 'm', 'm'};

    %% flatten
    f0filepath = cellfun(@(d, f) strcat(d, f, '_f0.csv'), dirlist, fileidlist, 'UniformOutput', false);
    f0filepath = cat(2, f0filepath{:});

    onsetfilepath = cellfun(@(d, f) strcat(d, 'onset_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    onsetfilepath = cat(2, onsetfilepath{:});

    breakfilepath = cellfun(@(d, f) strcat(d, 'break_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    breakfilepath = cat(2, breakfilepath{:});
    
    audiofilepath = cellfun(@(f) strcat(audiodir, f, '.wav'), fileidlist, 'UniformOutput', false);
    audiofilepath = cat(2, audiofilepath{:});

    h_getlast = @(X) X{end};
    typelist = cellfun(@(f) cellfun(@(g) h_getlast(strsplit(g, '_')), f, 'UniformOutput', false), fileidlist, 'UniformOutput', false);
    typelist = cat(2, typelist{:});

    langlist = cellfun(@(f, l) repmat({l}, [1, numel(f)]), fileidlist, langlist, 'UniformOutput', false);
    langlist = cat(2, langlist{:});

    sex = cellfun(@(f, s) repmat({s}, [1, numel(f)]), fileidlist, sex, 'UniformOutput', false);
    sex = cat(2, sex{:});
    
    %% extraction
    f0 = cell(numel(f0filepath), 1);
    t_f0 = cell(numel(f0filepath), 1);
    t_onset = cell(numel(onsetfilepath), 1);
    t_break = cell(numel(breakfilepath), 1);

    for i=1:numel(f0)
        T = readtable(f0filepath{i});
        f0{i} = T.voice_1;
        t_f0{i} = T.time;
        
        T = readtable(onsetfilepath{i}, 'ReadVariableNames', false);
        t_onset{i} = unique(T.Var1);

        T = readtable(breakfilepath{i}, 'ReadVariableNames', false);
        t_break{i} = unique(T.Var1);
        if iscell(t_break{i})
            t_break{i} = str2double(cell2mat(t_break{i}));
        end
    end

    %%
    addpath('./lib/CWT/');
    reffreq = 440;

    featurelist = {'f0', 'IOI rate', 'Rate of change of f0', 'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    featurename = {'Pitch height', 'Temporal rate', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pitch declination'};
    varNames = {'feature', 'name', 'lang', 'sex', 'type', 'mean', 'std'};
    featurestat = table('Size', [0, numel(varNames)], 'VariableTypes', {'string', 'string', 'string', 'string', 'string', 'double', 'double'}, 'VariableNames', varNames);
    
    for k=1:numel(featurelist)
        for i=1:numel(f0)
            if strcmp(featurelist{k}, 'f0')
                X = f0{i};
                X = 1200.*log2(X(X ~= 0)./440);
            elseif strcmp(featurelist{k}, 'IOI rate')
                X = 1./ft_ioi(t_onset{i}, t_break{i});
            elseif strcmp(featurelist{k}, 'Rate of change of f0')
                tmp = -abs(ft_deltaf0(f0{i}, 0.005, reffreq));
                X = tmp(~isnan(tmp));
            elseif strcmp(featurelist{k}, 'f0 ratio')
                [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
                X = helper.h_interval(1200.*log2(f0{i}./440), t_f0{i}, t_st, t_ed);
                X = abs(cat(1, X{:}));
            elseif strcmp(featurelist{k}, 'Spectral centroid')
                X = ft_spectralcentroid(audiofilepath{i}, f0{i}, t_f0{i}, Inf, false);
            elseif strcmp(featurelist{k}, 'Sign of f0 slope')
                X = ft_f0declination(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
            else
                X = NaN;
            end

            mu = mean(X);
            sgm = std(X);

            featurestat(end + 1, :) = table(featurelist(k), featurename(k), langlist(i), sex(i), typelist(i), mu, sgm);
        end
    end

    %%
    writetable(featurestat, strcat(outputdir, 'featurestat.csv'));
end