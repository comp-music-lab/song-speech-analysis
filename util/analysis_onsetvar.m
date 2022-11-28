function analysis_onsetvar
    %%
    PERSON = {'Dhwani', 'Florence', 'Patrick', 'Shafagh', 'Yuto'};
    VOCALIZER = {'Parimal', 'Florence', 'John', 'Shafagh', 'Yuto'};
    INPUTDIR = {'../data/Stage 1 RR Round 1/', '../data/Stage 1 RR Round 2/'};
    CONDITION = {'without texts', 'with texts'};
    OUTPUTDIR = '../output/onset-variance/';
    DATANAME_MAP = containers.Map(...
        PERSON,...
        {...
            {'(excerpt) Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_inst',...
            '(excerpt) Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_recit',...
            '(excerpt) Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_song',...
            '(excerpt) Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc'},...
            {'(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc',...
            '(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_inst',...
            '(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit',...
            '(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song'},...
            {'(excerpt) John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc',...
            '(excerpt) John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_inst',...
            '(excerpt) John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_recit',...
            '(excerpt) John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song'},...
            {'(excerpt) Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_recit',...
            '(excerpt) Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song',...
            '(excerpt) Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc',...
            '(excerpt) Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220507_inst'},...
            {'(excerpt) Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_desc',...
            '(excerpt) Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_recit',...
            '(excerpt) Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song',...
            '(excerpt) Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220224_inst'}...
        } ...
    );

    %%
    varNames = {'Condition', 'Vocalizer', 'Type', 'Annotator1', 'Annotator2', 'NumMatched', 'NumUnmatched1', 'NumUnmatched2', 'NumOnset1', 'NumOnset2'...
        'mean_diff', 'sd_diff', 'median_diff', 'MAD_diff', 'mean_absdiff', 'median_absdiff'};
    varTypes = {'string', 'string', 'string', 'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
    result = table('Size', [0, numel(varNames)], 'VariableNames', varNames, 'VariableTypes', varTypes);

    %%
    for m=1:numel(INPUTDIR)
        for i=1:numel(PERSON)
            original = PERSON{i};
            variant = setdiff(PERSON, original);
            dataname = DATANAME_MAP(original);
    
            %%
            for j=1:numel(dataname)
                onsetfilepath_o = strcat(INPUTDIR{m}, original, '/', 'onset_', dataname{j}, '.csv');
                T = readtable(onsetfilepath_o);
                t_onset_o = table2array(T(:, 1));
                pair = zeros(numel(t_onset_o), 3);
                pair(:, 1) = 1:numel(t_onset_o);
                
                s = strsplit(dataname{j}, '_');
                datatype = s(end);
    
                for k=1:numel(variant)
                    onsetfilepath_v = strcat(INPUTDIR{m}, variant{k}, '/', 'onset_', dataname{j}, '.csv');
    
                    if isfile(onsetfilepath_v)
                        T = readtable(onsetfilepath_v);
                        t_onset_v = table2array(T(:, 1));
    
                        pair(:, 3) = 1;
                        [~, ix, iy] = dtw(t_onset_o, t_onset_v);
    
                        for l=1:numel(t_onset_o)
                            idx = find(ix == l);
                            [~, idx_min] = min(abs(t_onset_o(ix(idx)) - t_onset_v(iy(idx))));
                            pair(l, 2) = iy(idx(idx_min));
                        end
                        
                        for l=1:numel(t_onset_v)
                            idx = find(l == pair(:, 2));
    
                            if numel(idx) > 1
                                [~, idx_min] = min(abs(t_onset_o(pair(idx, 1)) - t_onset_v(l)));
                                pair(setdiff(idx, idx(idx_min)), 3) = 0;
                            end
                        end
                        
                        %%
                        idx = pair(:, 3) == 1;
                        diff_t_onset = t_onset_o(pair(idx, 1)) - t_onset_v(pair(idx, 2));
    
                        result(end + 1, :) = table(CONDITION(m), VOCALIZER(i), datatype, PERSON(i), variant(k),...
                            sum(idx), sum(idx == 0), numel(t_onset_v) - sum(idx), numel(t_onset_o), numel(t_onset_v),...
                            mean(diff_t_onset), std(diff_t_onset, 1), median(diff_t_onset), mad(diff_t_onset, 1), mean(abs(diff_t_onset)), median(abs(diff_t_onset)));
    
                        %%{
                        fobj = figure(1);
                        fobj.Position = [10, 580, 1150, 410];
                        clf; cla;
                        scatter(t_onset_o, 2.*ones(numel(t_onset_o), 1), 'Marker', '.');
                        hold on;
                        scatter(t_onset_v, 1.*ones(numel(t_onset_v), 1), 'Marker', '.');
                        for l=1:size(pair, 1)
                            if pair(l, 3) == 1
                                plot([t_onset_o(l), t_onset_v(pair(l, 2))], [2, 1], '-.m');
                            end
                        end
                        hold off;
                        ylim([0.5, 2.5]);
                        xlabel('Time [second]');
                        yticks([1, 2]);
                        yticklabels({variant{k}, PERSON{i}});
                        title({dataname{j}, ['Onset annotation (', CONDITION{m}, ': ', original, ' - ', variant{k}, ')']}, 'Interpreter', 'none');
                        drawnow();
    
                        saveas(fobj, strcat(OUTPUTDIR, CONDITION{m}, '-', VOCALIZER{i}, '-' ,PERSON{i}, '-', variant{k}, '_', datatype{1}, '.png')), 
                        %}
                    end
                end
            end
        end
    
        %%
        writetable(result, strcat(OUTPUTDIR, 'onset-variance.csv'));
    end
end