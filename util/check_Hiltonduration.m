function check_Hiltonduration
    %%
    datainfo = readtable('../datainfo_Hilton-pyin.csv');
    N = 73;

    %%
    gid = unique(datainfo.groupid);
    durationinfo = zeros(numel(gid), 3);
    for i=1:numel(gid)
        idx = datainfo.groupid == gid(i);
        
        idx_song = idx & strcmp(datainfo.type, 'song');
        audiofilepath = strcat(datainfo.audiodir{idx_song}, datainfo.dataname{idx_song}, '.', datainfo.audioext{idx_song});
        [s, fs] = audioread(audiofilepath);
        songlength = numel(s)/fs;

        idx_desc = idx & strcmp(datainfo.type, 'desc');
        audiofilepath = strcat(datainfo.audiodir{idx_desc}, datainfo.dataname{idx_desc}, '.', datainfo.audioext{idx_desc});
        [s, fs] = audioread(audiofilepath);
        desclength = numel(s)/fs;

        durationinfo(i, :) = [gid(i), songlength, desclength];
    end

    gid_20sec = durationinfo(durationinfo(:, 2) >= 20 & durationinfo(:, 3) >= 20, 1);
    rng(2);
    gid_20sec_samp = sort(gid_20sec(randperm(numel(gid_20sec), N)));

    writetable(table(gid_20sec_samp, 'VariableNames', {'gid'}), '../output/analysis/Stage2/Hilton (20sec)/gid.csv');
end