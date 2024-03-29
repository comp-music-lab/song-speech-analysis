function analysis_rawdatastat(datainfofile, outputdir, duration, exploratory)
    %% extract data information
    datainfo = readtable(datainfofile);

    audiodir = datainfo.audiodir;
    audiofileext = datainfo.audioext;
    dirlist = datainfo.annotationdir;
    fileidlist = datainfo.dataname;
    langlist = datainfo.language;
    sex = datainfo.sex;
    typelist = datainfo.type;
    groupid = datainfo.groupid;

    %% filepath of data
    f0filepath = cellfun(@(d, f) strcat(d, f, '_f0.csv'), dirlist, fileidlist, 'UniformOutput', false);
    onsetfilepath = cellfun(@(d, f) strcat(d, 'onset_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    breakfilepath = cellfun(@(d, f) strcat(d, 'break_', f, '.csv'), dirlist, fileidlist, 'UniformOutput', false);
    audiofilepath = cellfun(@(d, f, e) strcat(d, f, '.', e), audiodir, fileidlist, audiofileext, 'UniformOutput', false);

    %% extraction
    f0 = cell(numel(f0filepath), 1);
    t_f0 = cell(numel(f0filepath), 1);
    t_onset = cell(numel(onsetfilepath), 1);
    t_break = cell(numel(breakfilepath), 1);

    for i=1:numel(f0)
        if isfile(f0filepath{i})
            T = readtable(f0filepath{i});
            idx = T.time <= duration;
            f0{i} = T.voice_1(idx);
            t_f0{i} = T.time(idx);
        end
    end
       
    for i=1:numel(t_onset)
        if isfile(onsetfilepath{i}) && isfile(breakfilepath{i})
            T = readtable(onsetfilepath{i}, 'ReadVariableNames', false, 'Format', '%f%s');
            t_onset{i} = unique(T.Var1);
            
            T = readtable(breakfilepath{i}, 'ReadVariableNames', false, 'Format', '%f%s');
            t_break{i} = unique(T.Var1);

            t_onset{i} = t_onset{i}(t_onset{i} < duration);
            t_break{i} = t_break{i}(t_break{i} < duration);
        end
    end

    %%
    addpath('./lib/CWT/');
    reffreq = 440;

    featurelist = {'f0', 'IOI rate', '-|Δf0|', 'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    if exploratory
        featurelist =  [featurelist, {'Pulse clarity', 'Onset-break interval', 'IOI ratio deviation', 'Spectral flatness', 'f0 ratio deviation',...
        '90% f0 quantile length', 'Short-term energy'}];
        addpath('./lib/KDE/');
    end
    featurename = {'Pitch height', 'Temporal rate', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pitch declination'};
    if exploratory
        featurename = [featurename, {'Pulse clarity', 'Phrase length', 'Rhythmic regularity', 'Timbral noiseness', 'Interval regularity',...
        'Pitch range', 'Lousness'}];
    end
    varNames = {'feature', 'name', 'lang', 'sex', 'type', 'mean', 'std', 'groupid'};
    varTypes = {'string', 'string', 'string', 'string', 'string', 'double', 'double', 'double'};
    featurestat = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    for i=1:numel(f0)
        fprintf('%s - %s (%d/%d)\n', datetime, audiofilepath{i}, i, numel(f0));

        for k=1:numel(featurelist)
            if strcmp(featurelist{k}, 'f0')
                if ~isempty(f0{i})
                    X = f0{i};
                    X = 1200.*log2(X(X ~= 0)./440);
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'IOI rate')
                if ~isempty(t_onset{i}) && ~isempty(t_break{i})
                    X = 1./ft_ioi(t_onset{i}, t_break{i});
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, '-|Δf0|')
                if ~isempty(f0{i})
                    tmp = -abs(ft_deltaf0(f0{i}, 0.005, reffreq));
                    X = tmp(~isnan(tmp));
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'f0 ratio')
                if ~isempty(f0{i}) && ~isempty(t_onset{i}) && ~isempty(t_break{i})
                    [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
                    X = helper.h_interval(1200.*log2(f0{i}./440), t_f0{i}, t_st, t_ed);
                    X = abs(cat(1, X{:}));
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'Spectral centroid')
                if ~isempty(f0{i})
                    X = ft_spectralcentroid(audiofilepath{i}, f0{i}, t_f0{i}, duration, false);
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'Sign of f0 slope')
                if ~isempty(f0{i}) && ~isempty(t_onset{i}) && ~isempty(t_break{i})
                    X = ft_f0declination(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'Pulse clarity')
                tmp =  mirpulseclarity(miraudio(audiofilepath{i}, 'Extract', 0, duration), 'Frame');
                X = mirgetdata(tmp);
            elseif strcmp(featurelist{k}, 'Onset-break interval')
                X = ft_obi(t_onset{i}, t_break{i});
            elseif strcmp(featurelist{k}, 'IOI ratio deviation')
                X = ft_ioiratiodev(t_onset{i}, t_break{i});
            elseif strcmp(featurelist{k}, 'Spectral flatness')
                X = ft_spectralflatness(audiofilepath{i}, t_onset{i}, t_break{i}, duration);
            elseif strcmp(featurelist{k}, 'Short-term energy')
                X = ft_energy(audiofilepath{i}, t_onset{i}, t_break{i}, duration);
            elseif strcmp(featurelist{k}, '90% f0 quantile length')
                if ~isempty(f0{i})
                    X = ft_pitchrange(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'f0 ratio deviation')
                if ~isempty(f0{i})
                    [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
                    I = helper.h_interval(1200.*log2(f0{i}./440), t_f0{i}, t_st, t_ed);
                    I = cat(1, I{:});
                    tmp = cell(1, 1);
                    tmp{1} = I;
                    X = helper.h_subsampling(tmp, 128);
                    X = ft_intervaldev(X{1});
                    close()
                else
                    X = [];
                end
            else
                X = [];
            end
            
            if ~isempty(X)
                mu = mean(X);
                %mu = median(X);
                sgm = std(X);
    
                featurestat(end + 1, :) = table(featurelist(k), featurename(k), langlist(i), sex(i), typelist(i), mu, sgm, groupid(i));
            end
        end
    end

    %%
    writetable(featurestat, strcat(outputdir, 'featurestat_', num2str(duration), 'sec.csv'));
end