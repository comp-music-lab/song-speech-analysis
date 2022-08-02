function praat2onsetbreak
    %%
    listing = dir('./');
    filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);
    datalist = filelist(contains(filelist, '.TextGrid'));

    %%
    for i=1:numel(datalist)
        s = strsplit(datalist{i}, '.');
        dataname = s{end - 2};
        dataname(1) = '(';
        dataname(9) = ')';
        dataname(10) = ' ';

        t_onset = [];
        fileID = fopen(datalist{i}, 'r');
        tline = fgetl(fileID);
        while ischar(tline)
            if contains(tline, 'number = ')
                s = strsplit(tline, ' ');
                t_onset(end + 1) = str2double(s{end - 1});
            end
            tline = fgetl(fileID);
        end
        fclose(fileID);
        
        writematrix(t_onset(:), strcat('./onset_', dataname, '.csv'));
        writematrix([], strcat('./break_', dataname, '.csv'));
    end
end