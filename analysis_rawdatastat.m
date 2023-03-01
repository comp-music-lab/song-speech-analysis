function analysis_rawdatastat(datainfofile, outputdir, duration)
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
            T = readtable(onsetfilepath{i}, 'ReadVariableNames', false);
            t_onset{i} = unique(T.Var1);
            
            T = readtable(breakfilepath{i}, 'ReadVariableNames', false);
            t_break{i} = unique(T.Var1);
            if iscell(t_break{i})
                t_break{i} = str2double(cell2mat(t_break{i}));
            end

            t_onset{i} = t_onset{i}(t_onset{i} < duration);
            t_break{i} = t_break{i}(t_break{i} < duration);
        end
    end

    %%
    addpath('./lib/CWT/');
    reffreq = 440;

    featurelist = {'f0', 'IOI rate', '-|Δf0|', 'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    featurename = {'Pitch height', 'Temporal rate', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pitch declination'};
    varNames = {'feature', 'name', 'lang', 'sex', 'type', 'mean', 'std', 'groupid'};
    varTypes = {'string', 'string', 'string', 'string', 'string', 'double', 'double', 'double'};
    featurestat = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    for k=1:numel(featurelist)
        for i=1:numel(f0)
            if strcmp(featurelist{k}, 'f0')
                if ~isempty(f0{i})
                    X = f0{i};
                    X = 1200.*log2(X(X ~= 0)./440);
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'IOI rate')
                X = 1./ft_ioi(t_onset{i}, t_break{i});
            elseif strcmp(featurelist{k}, '-|Δf0|')
                if ~isempty(f0{i})
                    tmp = -abs(ft_deltaf0(f0{i}, 0.005, reffreq));
                    X = tmp(~isnan(tmp));
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'f0 ratio')
                if ~isempty(f0{i})
                    [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
                    X = helper.h_interval(1200.*log2(f0{i}./440), t_f0{i}, t_st, t_ed);
                    X = abs(cat(1, X{:}));
                else
                    X = [];
                end
            elseif strcmp(featurelist{k}, 'Spectral centroid')
                X = ft_spectralcentroid(audiofilepath{i}, f0{i}, t_f0{i}, duration, false);
            elseif strcmp(featurelist{k}, 'Sign of f0 slope')
                if ~isempty(f0{i})
                    X = ft_f0declination(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
                else
                    X = [];
                end
            else
                X = [];
            end
            
            if ~isempty(X)
                mu = mean(X);
                sgm = std(X);
    
                featurestat(end + 1, :) = table(featurelist(k), featurename(k), langlist(i), sex(i), typelist(i), mu, sgm, groupid(i));
            end
        end
    end

    %%
    writetable(featurestat, strcat(outputdir, 'featurestat_', num2str(duration), 'sec.csv'));
end