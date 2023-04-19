inputdir = '../data/Stage 2 Annotation (Hilton)/';
dirinfo = dir(inputdir);

i = randi(length(dirinfo));
filename = dirinfo(i).name;
while ~contains(filename, 'D_f0.csv')
    i = randi(length(dirinfo));
    filename = dirinfo(i).name;
end

T = readtable(strcat(inputdir, filename));
t_f0 = T.time;
f0 = T.voice_1;

figure(1);
clf; cla;
plot(t_f0, 1200.*log2(f0./440));
title(filename, 'Interpreter', 'none');