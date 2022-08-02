%Written by JooSeuk Kim(2011/07/12)
function [out] = h_psi(in, type, a, b, c)
%out: psi function evaluated at in
%in: input
%type: type of loss function, 1-> Huber, 2-> Hampel
%a, b, c: parameters

[n m] = size(in);
out = zeros(n, m);
switch type   %                                                              
    case 1 % Huber function        
        out = min(in, a);
    case 2 % Hampel function
        i1 = (in < a);
        i2 = (in >= a & in < b);
        i3 = (in >= b & in < c);
        i4 = (in >=c);
        
        out(i1) = in(i1);
        out(i2) = a;
        out(i3) = a*(c-in(i3))/(c-b);
        out(i4) = 0;   
end