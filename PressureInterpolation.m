function intP = PressureInterpolation(V, highV, lowV, highP, lowP)
%PressureInterpolation(V, highV, lowV, highP, lowP) linearly interpolates
%a pressure from a specified property value
%The first input is the property value that the function will interpolate
%values for 
%The second and third inputs are the high and low property values, 
%respectively, that the first input falls between  
%The fourth and fifth inputs are the high and low pressure values,
%respectively,that the desired pressure value falls between 

m = (highP - lowP)./(highV - lowV);

intP = m.*(V - lowV) + lowP;

end

