function Pa = PascalConvert(pressure, unt)
%PascalConvert(pressure, unit) converts a given pressure value into Pascals
%The first input is the pressure and the second is the units 
%Valid unit inputs are: 'atm', 'psi', 'bar', or 'MPa
if strcmp(unt,'atm')
    Pa = pressure.*101325;
elseif strcmp(unt,'psi')
    Pa = pressure.*6894.8;
elseif strcmp(unt,'bar')
    Pa = pressure.*100000;
elseif strcmp(unt,'MPa')
    Pa = pressure.*1000000;
else 
    disp('Error! Invalid input')
end    
end