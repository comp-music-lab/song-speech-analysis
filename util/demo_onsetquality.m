addpath('../')
L = 20;
type = {'song', 'desc'};
I = cell(2, 2);
d = [0, 0];
addpath('../lib/two-sample/');
inputdir = {'../data/Stage 2 Annotation/', '../data/Stage 2 Annotation (pYIN-Praat)/'};
dataid = 'Ulvhild_Faeroevik_Norwegian_Traditional_Nordmannen_20230119';
f0 = cell(2, 2);
t_f0 = cell(2, 2);
t_onset = cell(2, 2);
t_break = cell(2, 2);

for j=1:numel(inputdir)
    for i=1:length(type)
        T = readtable(strcat(inputdir{j}, dataid, '_', type{i}, '_f0.csv'));
        t_f0{i, j} = T.time;
        f0{i, j} = T.voice_1;
        idx = find(t_f0{i, j} <= L, 1, 'last');
        t_f0{i, j} = t_f0{i, j}(1:idx);
        f0{i, j} = f0{i, j}(1:idx);
        
        T = readtable(strcat(inputdir{j}, 'onset_', dataid, '_', type{i}, '.csv'));
        t_onset{i, j} = T.Var1;
        t_onset{i, j} = t_onset{i, j}(t_onset{i, j} <= L);
        T = readtable(strcat(inputdir{j}, 'break_', dataid, '_', type{i}, '.csv'), 'ReadVariableNames', false, 'Format', '%f%s');
        t_break{i, j} = T.Var1;
        if ~isempty(t_break{i, j})
            t_break{i, j} = t_break{i, j}(t_break{i, j} <= L);
        end
        
        [~, ~, t_st, t_ed, ~] = helper.h_ioi(t_onset{i, j}, t_break{i, j});
        I_tmp = helper.h_interval(1200.*log2(f0{i, j}./440), t_f0{i, j}, t_st, t_ed);
    
        I{i, j} = cat(1, I_tmp{:});
    end
    
    d(j) = pb_effectsize(I{1, j}, I{2, j});
end

analysis = {'SA', 'Automated'};
for j=1:2
    for i=1:2
        fobj = figure;
        fobj.Position = [176, 733, 1400, 200];
        plot(t_f0{i, j}, 1200.*log2(f0{i, j}./440));
        hold on
        yl = ylim();
        for k=1:numel(t_onset{i, j})
            plot(t_onset{i, j}(k).*[1, 1], yl, '-.m');
        end
        for k=1:numel(t_break{i, j})
            plot(t_break{i, j}(k).*[1, 1], yl, '-b');
        end
        hold off
        title(strcat(analysis{j}, ': ', dataid, '_', type{i}), 'FontSize', 14, 'Interpreter', 'none');
        xlim([0, L]);
    end
end

for j=1:2
    figure;
    histogram(abs(I{1, j}), 'Normalization', 'pdf');
    hold on
    histogram(abs(I{2, j}), 'Normalization', 'pdf');
    hold off
    title(strcat(analysis{j}, ': Pitch interval size, (q, d) = (', num2str(d(j), '%3.2f'), ', ', num2str(sqrt(2)*norminv(d(j), 0, 1), '%3.2f'), ')'),...
        'FontSize', 14);
    legend(type, 'FontSize', 12);
    xlim([0, 1500]);
end