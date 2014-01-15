function intV = ThermoInterpolation(pval, highP, lowP, highV, lowV)
%ThermoInterpolation(pval, highP, lowP, highV, lowV) linearly interpolates
%a property of a specified pressure
%The first input is the pressure value that the function will interpolate
%values for 
%The second and third inputs are the high and low pressure values, 
%respectively, that the first input falls between  
%The fourth and fifth inputs are the high and low property values,
%respectively,that the desired property value falls between 

m = (highV - lowV)./(highP - lowP);

intV = m.*(pval - lowP) + lowV;
end

