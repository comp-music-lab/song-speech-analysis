function analysis_onsetquality
    %% Limitations
    % Correlation/two-sample tests as point processes or functional data
    % Synthesis of Bayes factos
    % CHRONSET, SPPAS

    %%
    pprm = plotprm();
    outputdir = './output/20220729/';
    thresh = [0.025, 0.050, 0.075, 0.100]';
    
    %% Comparison among IOI and IOI ratio distributions
    % Praat scripts
    combination = {...
        {'Yuto', {'Jong_Wempe_2008'}},...
        {'Patrick', {'Jong_Wempe_2008'}},...
        {'Dhwani', {'Jong_Wempe_2008'}},...
        {'Florence', {'Jong_Wempe_2008'}},...
        {'Shafagh', {'Jong_Wempe_2008'}},...
    };
    datadir = {'./data/Stage 1 RR Round 2/', './data/Stage 1 RR Praat/'};
    result_A2 = h_BF_h(datadir, combination, thresh);
    result_A2.trial = repmat({'vs. Jong & Wempe (2008)'}, [size(result_A2, 1), 1]);
    
    combination = {...
        {'Yuto', {'Prosogram'}},...
        {'Patrick', {'Prosogram'}},...
        {'Dhwani', {'Prosogram'}},...
        {'Florence', {'Prosogram'}},...
        {'Shafagh', {'Prosogram'}},...
    };
    datadir = {'./data/Stage 1 RR Round 2/', './data/Stage 1 RR Praat/'};
    result_A1 = h_BF_h(datadir, combination, thresh);
    result_A1.trial = repmat({'vs. Prosogram'}, [size(result_A1, 1), 1]);
    
    % 1st and 2nd round
    combination = {...
        {'Yuto', {'Patrick', 'Shafagh', 'Dhwani'}},...
        {'Patrick', {'Yuto', 'Shafagh', 'Dhwani'}},...
        {'Shafagh', {'Patrick', 'Yuto', 'Dhwani'}},...
        {'Dhwani', {'Patrick', 'Shafagh', 'Yuto'}},...
        {'Florence', {'Patrick', 'Shafagh', 'Dhwani', 'Yuto'}},...
    };
    datadir = {'./data/Stage 1 RR Round 1/', './data/Stage 1 RR Round 1/'};
    result_R1 = h_BF_h(datadir, combination, thresh);
    result_R1.trial = repmat({'between-subjects (w/o texts)'}, [size(result_R1, 1), 1]);

    datadir = {'./data/Stage 1 RR Round 2/', './data/Stage 1 RR Round 2/'};
    result_R2 = h_BF_h(datadir, combination, thresh);
    result_R2.trial = repmat({'between-subjects (w/ texts)'}, [size(result_R2, 1), 1]);
    
    % Re-annotation
    combination = {...
        {'Yuto', {'Yuto'}},...
        {'Patrick', {'Patrick'}},...
        {'Shafagh', {'Shafagh'}},...
        {'Dhwani', {'Dhwani'}}...
    };
    datadir = {'./data/Stage 1 RR IRR/', './data/Stage 1 RR Round 2/'};
    result_IRR = h_BF_h(datadir, combination, thresh);
    result_IRR.trial = repmat({'within-subjects'}, [size(result_IRR, 1), 1]);

    % Full-length vs. excerpt
    combination = {...
        {'Yuto', {'Yuto'}},...
        {'Patrick', {'Patrick'}},...
        {'Shafagh', {'Shafagh'}},...
        {'Dhwani', {'Dhwani'}},...
        {'Florence', {'Florence'}}...
    };
    datadir = {'./data/Stage 1 RR Full/', './data/Stage 1 RR Round 2/'};
    result_Full = h_BF_h(datadir, combination, thresh);
    result_Full.trial = repmat({'Full vs. excerpts'}, [size(result_Full, 1), 1]);

    result = [result_R1; result_R2; result_IRR; result_Full; result_A1; result_A2];
    
    %%
    h_plot(result, pprm, thresh, outputdir);
end

function h_plot(result, pprm, thresh, outputdir)
    %%
    list_type = unique(result.type);
    list_lang = unique(result.lang);

    %%
    for l=1:(2 + numel(thresh))
        if l == 1
            Y_l = result.log10bf_H0_ioi;
            titlestr = 'IOI';
            ylabelstr = 'Bayes Factor (log_{10})';
            list_trial = unique(result.trial);
            fileid = 'ioi-BF.png';
        elseif l == 2
            Y_l = result.log10bf_H0_ioiratio;
            titlestr = 'IOI ratio';
            ylabelstr = 'Bayes Factor (log_{10})';
            list_trial = unique(result.trial);
            fileid = 'ioiratio-BF.png';
        else
            Y_l = cellfun(@(y) y(l - 2),result.F1);
            titlestr = ['Accuracy (threshold = ±', num2str(thresh(l - 2), '%3.3f'), 'sec.)'];
            ylabelstr = 'F1';
            list_trial = setdiff(unique(result.trial), 'Full vs. excerpts');
            fileid = strcat('F1-', erase(num2str(thresh(l - 2), '%3.3f'), '.'), '.png');
        end

        yl = [min(Y_l) - 0.2, max(Y_l) + 0.2];

        %%
        fobj = figure();
        fobj.Position = [40, 690, 640, 280];
    
        for j=1:numel(list_trial)
            idx_j = strcmp(result.trial, list_trial{j});

            for k=1:numel(list_lang)
                idx_k = strcmp(result.lang, list_lang{k});

                for i=1:numel(list_type)
                    idx_i = strcmp(result.type, list_type{i});
    
                    idx = idx_i & idx_j & idx_k;
                    Y = Y_l(idx);
                    X = j.*ones(numel(Y), 1) + 0.15.*i - 0.35;
    
                    scatter(X, Y,...
                        'MarkerEdgeColor', 'None', 'MarkerFaceColor', pprm.langcolormap(list_lang{k}),...
                        'MarkerFaceAlpha', 0.5, 'Marker', pprm.typemarkermap(list_type{i})...
                    );
                    hold on
                end
            end
        end
        
        %%
        if l == 1 || l == 2
            plot([0, numel(list_trial) + 1], 0.5.*[1, 1], ':', 'Color', 'k');
            plot([0, numel(list_trial) + 1], 1.0.*[1, 1], '-.', 'Color', 'k');
        end

        %%
        h_lang = zeros(numel(list_lang), 1);
        for k=1:numel(h_lang)
            h_lang(k) = scatter(NaN, NaN,...
                    'MarkerEdgeColor', 'None', 'MarkerFaceColor', pprm.langcolormap(list_lang{k}), 'MarkerFaceAlpha', 0.5, 'Marker', 'o');
        end
        h_type = zeros(numel(list_type), 1);
        for i=1:numel(h_type)
            h_type(i) = scatter(NaN, NaN,...
                    'MarkerEdgeColor', 'None', 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.5, 'Marker', pprm.typemarkermap(list_type{i}));
        end
        legend([h_lang; h_type], [list_lang; list_type], 'Position', [0.84, 0.39, 0.15, 0.41]);
        
        hold off
        
        xticks(1:numel(list_trial));
        xticklabels(list_trial);
        xlim([0.5, numel(list_trial) + 1]);

        ylabel(ylabelstr);
        ylim(yl);

        title(titlestr);

        saveas(fobj, strcat(outputdir, fileid));
    end
end

function result = h_BF_h(datadir, combination, thresh)
    %%
    addpath('./lib/two-sample/');
    nbpobj = nbpfittest(1, 500, 'robust');
    priorodds = 1;
    
    R = zeros(numel(thresh), 1);
    F1 = zeros(numel(thresh), 1);
    PRC = zeros(numel(thresh), 1);
    RCL = zeros(numel(thresh), 1);
    OS = zeros(numel(thresh), 1);

    %%
    am_map = containers.Map(...
        {'Yuto', 'Patrick', 'Shafagh', 'Dhwani', 'Florence'},...
        {'Yuto_Ozaki', 'John_McBride', 'Shafagh_Hadavi', 'Parimal_Sadaphal', 'Florence_Nweke'}...
    );

    ml_map = containers.Map(...
        {'Yuto_Ozaki', 'John_McBride', 'Shafagh_Hadavi', 'Parimal_Sadaphal', 'Florence_Nweke'},...
        {'Japanese', 'English', 'Farsi', 'Marathi', 'Yoruba'}...
    );

    material = {...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_inst',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_inst',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_recit',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_inst',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_recit',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_song',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_recit',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220507_inst',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_desc',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_recit',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220224_inst',...
    };

    %%
    result = [];
    col_result = {'posterior_H0_ioi', 'log10bf_H0_ioi', 'posterior_H0_ioiratio', 'log10bf_H0_ioiratio',...
        'R', 'F1', 'PRC', 'RCL', 'OS', 'lang', 'type', 'material'};

    for i=1:numel(combination)
        %%
        mid_i = am_map(combination{i}{1});
        lang_i = ml_map(mid_i);
        material_i = material(contains(material, mid_i));
        
        for j=1:numel(material_i)
            %%
            dirpath = strcat(datadir{1}, combination{i}{1});
            listing = dir(dirpath);
            filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);

            onsetfile = filelist(contains(lower(filelist), 'onset') & contains(filelist, material_i{j}));
            onsetfilepath_ref = strcat(dirpath, '/', onsetfile{1});
            
            breakfile = filelist(contains(lower(filelist), 'break') & contains(filelist, material_i{j}));
            breakfilepath_ref = strcat(dirpath, '/', breakfile{1});

            [ioi_ref, ioiratio_ref, t_onset_ref] = h_ETL(onsetfilepath_ref, breakfilepath_ref);

            s = strsplit(material_i{j}, '_');
            type_ij = s{end};

            for k=1:numel(combination{i}{2})
                %%
                dirpath = strcat(datadir{2}, combination{i}{2}{k});
                listing = dir(dirpath);
                filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);

                onsetfile = filelist(contains(lower(filelist), 'onset') & contains(filelist, material_i{j}));
                onsetfilepath_var = strcat(dirpath, '/', onsetfile{1});

                breakfile = filelist(contains(lower(filelist), 'break') & contains(filelist, material_i{j}));
                breakfilepath_var = strcat(dirpath, '/', breakfile{1});

                [ioi_var, ioiratio_var, t_onset_var] = h_ETL(onsetfilepath_var, breakfilepath_var);

                %%
                lnbf_H0_ioi = nbpobj.test(ioi_ref(:), ioi_var(:));
                [posterior_H0_ioi, ~] = nbpobj.posterior(priorodds, lnbf_H0_ioi);
                log10bf_H0_ioi = lnbf_H0_ioi/log(10);
                
                lnbf_H0_ioiratio = nbpobj.test(ioiratio_ref(:), ioiratio_var(:));
                [posterior_H0_ioiratio, ~] = nbpobj.posterior(priorodds, lnbf_H0_ioiratio);
                log10bf_H0_ioiratio = lnbf_H0_ioiratio/log(10);
                
                for l=1:numel(thresh)
                    [R(l), F1(l), PRC(l), RCL(l), OS(l)] = ft_rvalue(t_onset_ref, t_onset_var, thresh(l));
                end

                result_ijk = table(...
                    posterior_H0_ioi, log10bf_H0_ioi, posterior_H0_ioiratio, log10bf_H0_ioiratio,...
                    {R}, {F1}, {PRC}, {RCL}, {OS}, {lang_i}, {type_ij}, material_i(j),...
                    'VariableNames', col_result...
                );

                result = [result; result_ijk];
            end
        end
    end
end

function [ioi, ioiratio, t_onset, t_break] = h_ETL(onsetfilepath, breakfilepath)
    %%
    T = readtable(onsetfilepath);
    t_onset = table2array(T(:, 1));

    %%
    T = readtable(breakfilepath, 'ReadVariableNames', false);
    if ~isempty(T)
        t_break = table2array(T(:, 1));

        if iscell(t_break)
            t_break = str2double(cell2mat(t_break));
        end
    else
        t_break = [];
    end

    %%
    [ioi, ioiratio] = helper.h_ioi(t_onset, t_break);
end