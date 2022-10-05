function analysis_annotatoreffect
    %%
    outputdir = './output/20220918/';

    comparison = {{'song', 'desc'}, {'song', 'recit'}, {'inst', 'desc'}};

    fileidlist = {...
        strcat('Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_', {'20220320_inst', '20220320_recit', '20220320_song', '20220430_desc'}),...
        strcat('Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_', {'20220430_recit', '20220430_song', '20220502_desc', '20220507_inst'}),...
        strcat('Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_', {'20220504_desc', '20220504_inst', '20220504_recit', '20220504_song'}),...
        strcat('John_McBride_English_Irish_Anthem_FieldsOfAthenry_', {'20220219_desc', '20220219_inst', '20220219_recit', '20220219_song'}),...
        strcat('Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_', {'20220209_desc', '20220209_recit', '20220209_song', '20220224_inst'})...
    };
    
    annotatorlist = {'Dhwani', 'Shafagh', 'Florence', 'Patrick', 'Yuto', 'Jong_Wempe_2008', 'Prosogram'};

    langlist = {'Marathi', 'Farsi', 'Yoruba', 'English', 'Japanese', 'n/a', 'n/a'};

    sex = {'m', 'f', 'f', 'm', 'm'};

    h_getlast = @(X) X{end};
    typelist = cellfun(@(f) cellfun(@(g) h_getlast(strsplit(g, '_')), f, 'UniformOutput', false), fileidlist, 'UniformOutput', false);
    
    %%
    f0filepath = cellfun(@(d, f) strcat(d, f, '_f0.csv'), strcat('./data/Stage 1 RR Full/', annotatorlist(1:5), '/'), fileidlist, 'UniformOutput', false);
    f0 = f0filepath;
    t_f0 = f0filepath;
    for i=1:numel(f0filepath)
        for j=1:numel(f0filepath{i})
            T = readtable(f0filepath{i}{j});
            f0{i}{j} = T.voice_1;
            t_f0{i}{j} = T.time;
        end
    end

    %%
    addpath('./lib/two-sample/');

    varNames = {'feature', 'experiment', 'datalang', 'sex', 'type_m', 'type_l', 'annotator', 'annotatorlang', 'p', 'tau'};
    varTypes = {'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'double', 'double'};
    onsetqualitytable = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);

    %dirlist = strcat('./data/', {'Stage 1 RR Round 1/', 'Stage 1 RR Round 2/', 'Stage 1 RR IRR/', 'Stage 1 RR Full/', 'Stage 1 RR Praat/'});
    %experiment = {'Without texts', 'With texts', 'Reannotation', 'Full-length', 'Automated'};
    %excerptid = {'(excerpt) ', '(excerpt) ', '(excerpt) ', '', '(excerpt) '};
    dirlist = strcat('./data/', {'Stage 1 RR Round 2/', 'Stage 1 RR IRR/', 'Stage 1 RR Praat/'});
    experiment = {'With texts', 'Reannotation', 'Automated'};
    excerptid = {'(excerpt) ', '(excerpt) ', '(excerpt) '};

    for l=1:numel(dirlist)
        fprintf('l: %d/%d %s\n', l, numel(dirlist), datetime);
        dir = strcat(dirlist{l}, annotatorlist, '/');

        for j=1:numel(comparison)
            fprintf('j: %d/%d %s\n', j, numel(comparison), datetime);

            for i=1:numel(typelist)
                fprintf('i: %d/%d %s\n', i, numel(typelist), datetime);

                idx_m = contains(typelist{i}, comparison{j}{1});
                idx_l = contains(typelist{i}, comparison{j}{2});

                fileid_m = fileidlist{i}{idx_m};
                fileid_l = fileidlist{i}{idx_l};
                f0_m = f0{i}{idx_m};
                f0_l = f0{i}{idx_l};
                t_f0_m = t_f0{i}{idx_m};
                t_f0_l = t_f0{i}{idx_l};
    
                for k=1:numel(dir)
                    onsetfilepath_m = [dir{k}, 'onset_', excerptid{l}, fileid_m, '.csv'];
                    onsetfilepath_l = [dir{k}, 'onset_', excerptid{l}, fileid_l, '.csv'];
                    breakfilepath_m = [dir{k}, 'break_', excerptid{l}, fileid_m, '.csv'];
                    breakfilepath_l = [dir{k}, 'break_', excerptid{l}, fileid_l, '.csv'];
                    
                    if isfile(onsetfilepath_m)
                        [X, t_st_X, t_ed_X, t_onset_X, t_break_X] = h_ioirate(onsetfilepath_m, breakfilepath_m);
                        [Y, t_st_Y, t_ed_Y, t_onset_Y, t_break_Y] = h_ioirate(onsetfilepath_l, breakfilepath_l);
                        [p, tau] = pb_effectsize(X, Y);
                        onsetqualitytable(end + 1, :) = table({'IOI'}, experiment(l), langlist(i), sex(i), comparison{j}(1), comparison{j}(2), annotatorlist(k), langlist(k), p, tau);
                        
                        idx_cutoff = find(t_f0_m > t_ed_X(end), 1, 'first');
                        f0_mk = f0_m(1:idx_cutoff);
                        t_f0_mk = t_f0_m(1:idx_cutoff);

                        idx_cutoff = find(t_f0_l > t_ed_Y(end), 1, 'first');
                        f0_lk = f0_l(1:idx_cutoff);
                        t_f0_lk = t_f0_l(1:idx_cutoff);

                        X = helper.h_interval(1200.*log2(f0_mk./440), t_f0_mk, t_st_X, t_ed_X);
                        X = abs(cat(1, X{:}));
                        Y = helper.h_interval(1200.*log2(f0_lk./440), t_f0_lk, t_st_Y, t_ed_Y);
                        Y = abs(cat(1, Y{:}));
                        [p, tau] = pb_effectsize(X, Y);
                        onsetqualitytable(end + 1, :) = table({'f0 ratio'}, experiment(l), langlist(i), sex(i), comparison{j}(1), comparison{j}(2), annotatorlist(k), langlist(k), p, tau);

                        X = ft_f0declination(t_onset_X, t_break_X, f0_mk, t_f0_mk);
                        Y = ft_f0declination(t_onset_Y, t_break_Y, f0_lk, t_f0_lk);
                        [p, tau] = pb_effectsize(X, Y);
                        onsetqualitytable(end + 1, :) = table({'Sign of f0 slope'}, experiment(l), langlist(i), sex(i), comparison{j}(1), comparison{j}(2), annotatorlist(k), langlist(k), p, tau);
                    end
                end
            end
        end
    end

    %%
    writetable(onsetqualitytable, strcat(outputdir, 'onsetqualitytable.csv'))
end

function [X, t_st, t_ed, t_onset, t_break] = h_ioirate(onsetfilepath, breakfilepath)
    %%
    T = readtable(onsetfilepath, 'ReadVariableNames', false);
    t_onset = unique(T.Var1);

    T = readtable(breakfilepath, 'ReadVariableNames', false);

    if isempty(T)
        t_break = [];
    else
        t_break = unique(T.Var1);
        if iscell(t_break)
            t_break = str2double(cell2mat(t_break));
        end
    end

    %%
    t_break(t_break < t_onset(1)) = [];

    %%
    [X, ~, t_st, t_ed] = helper.h_ioi(t_onset, t_break);
    %X = 1./X;
end