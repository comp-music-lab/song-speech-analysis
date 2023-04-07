function onsetbreakmix
    %%
    audiodir = 'G:\Datasets\Song-Speech\Audio recordings\';
    annotdir = 'G:\Datasets\Song-Speech\SV\';
    
    [clicksound, fs_ck] = audioread('clicksound.wav');
    clicksound = mean(clicksound, 2);
    
    [breaksound, fs_bk] = audioread('breaksound.wav');
    breaksound = mean(breaksound, 2);

    mono = true;
    L = 20;

    %%
    dirinfo = dir(audiodir);

    for i=1:numel(dirinfo)
        st = strsplit(dirinfo(i).name, '.');
        onsetfileinfo = dir(fullfile(annotdir, '**', strcat('onset_', st{1}, '.csv')));
        breakfileinfo = dir(fullfile(annotdir, '**', strcat('break_', st{1}, '.csv')));
        
        if ~isempty(onsetfileinfo) && ~isempty(breakfileinfo)
            audiofilepath = strcat(dirinfo(i).folder, filesep, dirinfo(i).name);
            onsetfilepath = strcat(onsetfileinfo.folder, filesep, onsetfileinfo.name);
            breakfilepath = strcat(breakfileinfo.folder, filesep, breakfileinfo.name);

            [s, fs] = audioread(audiofilepath);
            T = readtable(onsetfilepath, 'ReadRowNames', false, 'ReadVariableNames', false,'Format','%f%s');
            t_onset = T.Var1;
            T = readtable(breakfilepath, 'ReadRowNames', false, 'ReadVariableNames', false,'Format','%f%s');
            t_break = T.Var1;
            
            if size(s, 2) == 2
                s = mean(s, 2);
            end
            t = (0:(numel(s) - 1))./fs;
            s_onset = h_clicksynth(s, t, clicksound, t_onset, mono);
            s_onsetbreak = h_clicksynth(s_onset, t, breaksound, t_break, mono);
            
            [~, idx] = min(abs(t - L));
            s_onsetbreak = s_onsetbreak(1:idx);

            audiowrite(strcat(onsetfileinfo.folder, filesep, 'annotated-', st{1}, '.wav'), s_onsetbreak, fs);
        else
            fprintf('Unmatched: %s\n', st{1});
        end
    end
end