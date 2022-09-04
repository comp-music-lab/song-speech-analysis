function n = simequivpow(mu, sgm, al, be, Dlt)
    %%
    if abs(mu) <= Dlt
        n = 1;
        pwr = 0;
        M = 2048;
        hit = zeros(M, 1);
        
        while pwr < be
            n = n + 1;
        
            parfor m=1:M
                X = normrnd(mu, sgm, [n, 1]);
                mu_X = mean(X);
                sgm_X = std(X, 0);
                
                dlt = sqrt(n)*Dlt;
                fun = @(C) normcdf((C - dlt)/sgm_X) - normcdf((-C - dlt)/sgm_X) - al;
                C = fzero(fun, 0);
            
                if sqrt(n)*abs(mu_X) < C
                    hit(m) = 1;
                else
                    hit(m) = 0;
                end
            end
        
            pwr = mean(hit);
            %fprintf('n = %d, power = %3.4f\n', n, pwr);
        end
    else
        n = NaN;
    end
end

%{
mu = normrnd(0, 0.8);
sgm = gamrnd(7, 0.2);
al = 0.05;

Dlt = 1.0;
fun = @(C) normcdf((C - Dlt)/sgm) - normcdf((-C - Dlt)/sgm) - al;
C = fzero(fun, 0);

fp = normcdf(C, mu, sgm) - normcdf(-C, mu, sgm);
if fp < al
    decision = 'No';
else
    decision = 'Yes';
end

figure(1);
support = linspace(mu - sgm*5, mu + sgm*5, 512);
f = normpdf(support, mu, sgm);
plot(support, f);
hold on
if mu > 0
    f_Dlt = normpdf(support, Dlt, sgm);
else
    f_Dlt = normpdf(support, -Dlt, sgm);
end
plot(support, f_Dlt, 'Color', '#D95319');

[~, idx_l] = min(abs(support - -C));
[~, idx_r] = min(abs(support - C));
area(support(idx_l:idx_r), f_Dlt(idx_l:idx_r));

yl = ylim();
plot([mu, mu], yl, 'Color', 'm');
plot(-[Dlt, Dlt], yl, 'Color', 'g');
plot([Dlt, Dlt], yl, 'Color', 'g');
hold off

axis tight
title(['Equivalent? = ', decision]);
%}

%{
Dlt = 1.0;
mu = rand*Dlt*(randi(2) - 1.5)*2;
sgm = gamrnd(7, 0.2);
al = 0.05;
beta = 0.95;

n = 1;
pwr = 0;
M = 2048;
hit = zeros(M, 1);

while pwr < beta
    n = n + 1;

    parfor m=1:M
        X = normrnd(mu, sgm, [n, 1]);
        mu_X = mean(X);
        sgm_X = std(X, 0);
        
        dlt = sqrt(n)*Dlt;
        fun = @(C) normcdf((C - dlt)/sgm_X) - normcdf((-C - dlt)/sgm_X) - al;
        C = fzero(fun, 0);
    
        if sqrt(n)*abs(mu_X) < C
            hit(m) = 1;
        else
            hit(m) = 0;
        end
    end

    pwr = mean(hit);
    fprintf('n = %d, power = %3.4f\n', n, pwr);
end

figure(2);
support = linspace(mu - sgm*5, mu + sgm*5, 512);
f = normpdf(support, mu, sgm);
plot(support, f);
hold on
yl = ylim();
plot([mu, mu], yl, 'Color', 'm');
plot(-[Dlt, Dlt], yl, 'Color', 'g');
plot([Dlt, Dlt], yl, 'Color', 'g');
hold off
axis tight
%}