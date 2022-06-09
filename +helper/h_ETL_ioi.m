function D = h_ETL_ioi(dataname, ioidir)
    %%
    D = {cell(numel(dataname), 1), cell(numel(dataname), 1), cell(numel(dataname), 1)};

    %%
    for i=1:numel(dataname)
        %%
        onsetinfo = readtable(strcat(ioidir{i}, 'onset_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        breakinfo = readtable(strcat(ioidir{i}, 'break_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        
        %%
        t_onset = table2array(onsetinfo(:, 1));
        if iscell(t_onset)
            t_onset = cell2mat(t_onset);
        end

        if ~isempty(breakinfo)
            t_break = table2array(breakinfo(:, 1));
            if iscell(t_break)
                t_break = str2double(cell2mat(t_break));
            end
        else
            t_break = [];
        end
        
        [ioi, ioiratio, ~, ~, t_ioiratio] = helper.h_ioi(t_onset, t_break);

        D{1}{i} = ioi(:);
        D{2}{i} = ioiratio(:);
        D{3}{i} = t_ioiratio(:);
    end
end