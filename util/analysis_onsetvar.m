function analysis_onsetvar
    %%
    PERSON = {'Dhwani', 'Florence', 'Patrick', 'Shafagh', 'Yuto'};
    INPUTDIR = '../data/Stage 1 RR Round 1/';
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
    for i=1:numel(PERSON)
        original = PERSON{i};
        variant = setdiff(PERSON, original);
        dataname = DATANAME_MAP(original);

        %%
        for j=1:numel(dataname)
            onsetfilepath_o = strcat(INPUTDIR, original, '/', 'onset_', dataname{j}, '.csv');
            T = readtable(onsetfilepath_o);
            t_onset_o = table2array(T(:, 1));
            pair = zeros(numel(t_onset_o), 3);

            for k=1:numel(variant)
                onsetfilepath_v = strcat(INPUTDIR, variant{k}, '/', 'onset_', dataname{j}, '.csv');

                if isfile(onsetfilepath_v)
                    T = readtable(onsetfilepath_v);
                    t_onset_v = table2array(T(:, 1));

                    tmp_o = t_onset_o;
                    tmp_v = t_onset_v;

                    while ~isempty(tmp_o)
                        A = cell2mat(arrayfun(@(t) h_minidx(t - tmp_v), tmp_o));

                        [~, idx_o] = min(A(:, 1));
                        idx_original_o = find((t_onset_o - tmp_o(idx_o)) == 0);
                        
                        [~, idx_v] = min(abs(tmp_v - tmp_o(idx_o)));
                        idx_original_v = find((t_onset_v - tmp_v(idx_v)) == 0);

                        pair(idx_original_o, :) = [idx_original_o, idx_original_v, 1];
                        tmp_o(idx_o) = [];
                        tmp_v(idx_v) = [];
                    end
                    
                    for l=2:(size(pair, 1) - 1)
                        if pair(l, 2) > pair(l + 1, 2) || pair(l, 2) < pair(l - 1, 2)
                            pair(l, 3) = 0;
                        end
                    end

                    %%{
                    figure;
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
                    title({dataname{j}, [original, ' - ', variant{k}]}, 'Interpreter', 'none');
                    %}
                end
            end
        end
    end
end

function C = h_minidx(x)
    [d, idx] = min(abs(x));
    C = {[d, idx]};
end