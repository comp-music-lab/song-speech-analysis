function util_convertTextGrid
    inputdir = 'C:\Users\yuto\Desktop\tmp\';
    dirinfo = dir(inputdir);
    outputdir = 'C:\Users\yuto\Documents\MATLAB\projects\song-speech-analysis\data\Stage 2 Annotation (pYIN-Praat)\';
    
    for i=1:numel(dirinfo)
	    if contains(dirinfo(i).name, '.syllables.TextGrid')
		    fprintf([dirinfo(i).name, '\n']);
		    s = readlines([dirinfo(i).folder, filesep, dirinfo(i).name]);
		    idx = contains(s, " number = ");
		    s = s(idx);
    
		    t_onset = zeros(numel(s), 1);
		    for j=1:numel(s)
			    ss = strsplit(s{j}, " = ");
			    t_onset(j) = str2num(ss{2});
		    end
    
		    T = table(t_onset, repmat('New Point', [numel(t_onset), 1]));
    
		    ss = strsplit(dirinfo(i).name, '.');
		    writetable(T, strcat(outputdir, 'onset_', ss{1}, '.csv'), 'WriteVariableNames', false);
    
		    writetable(table(), strcat(outputdir, 'break_', ss{1}, '.csv'), 'WriteVariableNames', false);
	    end
    end
end