function D = h_ETL_intvl(dataname, f0dir, ioidir)
    %%
    D = cell(numel(dataname), 1);
    reffreq = 440;

    %%
    for i=1:numel(dataname)
        %%
        f0info = readtable(strcat(f0dir{i}, dataname{i}, '_f0.csv'));
        onsetinfo = readtable(strcat(ioidir{i}, 'onset_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        breakinfo = readtable(strcat(ioidir{i}, 'break_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        
        %%
        f0 = f0info.voice_1;
        f0_cent = 1200.*log2(f0./reffreq);
        t_f0 = f0info.time;

        t_onset = table2array(onsetinfo(:, 1));
        if ~isempty(breakinfo)
            t_break = table2array(breakinfo(:, 1));
            if iscell(t_break)
                t_break = str2double(cell2mat(t_break));
            end
        else
            t_break = [];
        end
        [~, ~, t_st, t_ed] = helper.h_ioi(t_onset, t_break);
        
        I = helper.h_interval(f0_cent, t_f0, t_st, t_ed);
        D{i} = cat(1, I{:});
    end
end