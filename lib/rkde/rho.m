%Written by JooSeuk Kim(2011/07/12)

function J = rho(x, type, a, b, c)
%J: \frac{1}{n} sum_{i=1}^n \rho(x_i)
%x: input
%type: type of loss function, 1-> Huber, 2-> Hampel
%a, b, c: parameters

n = length(x);

switch type
    case 1
        %Huber
        in1 = (x <= a);
        in2 = (x > a);
        J = sum(1/2*x(in1).^2 ) + sum(a*(x(in2)-a)+1/2*a^2);
    case 2
        %Hampel
        in1 = (x <= a);
        in2 = (a < x & x <= b);
        in3 = (b < x & x <= c);
        in4 = (c < x);
        
        p = -a/(c-b);
        q = a*c/(c-b);
        r = a*b - 1/2*a^2 - 1/2*p*b^2-q*b;
        temp(in1) = 1/2*x(in1).^2;
        temp(in2) = a*(x(in2)-a)+ 1/2*a^2;
        temp(in3) = 1/2*p*x(in3).^2 + q*x(in3) + r;
        temp(in4) = 1/2*p*c^2+q*c+r;
        J = sum(temp);        
end
J = J/n;