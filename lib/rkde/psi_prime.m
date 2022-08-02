%Written by JooSeuk Kim(2011/07/12)

function [out] = psi_prime(in, type, a, b, c)
%out: psi' function evaluated at in
%in: input
%type: type of loss function, 1-> Huber, 2-> Hampel
%a, b, c: parameters

[n m] = size(in);
out = zeros(n, m);

switch type   %                                                             
    case 1 % Huber function
        i1 = (in <= a);
        i2 = (in > a);
        out(i1) = 1;
        out(i2) = 0;
    case 2 % Hampel function
        i1 = (in < a);
        i2 = (in >= a & in < b);
        i3 = (in >= b & in < c);
        i4 = (in >=c);
        
        out(i1) = 1;
        out(i2) = 0;
        out(i3) = -a/(c-b);
        out(i4) = 0;    
end