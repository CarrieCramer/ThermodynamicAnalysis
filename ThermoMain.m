load H2O.dat

%remove zero columns
H2O = H2O(:,any(H2O));   
    
[rH2O cH2O] = size(H2O);
 
%convert pressures to pascal
for i = 1:rH2O  
    H2O(i,1) = PascalConvert(H2O(i,1), 'MPa');
end

clf

%Plot Pressure vs. Specific Volume

%Define x and y coordinates for the subplots
x1 = H2O(:,3)'; 
x2 = H2O(:,4)'; 
x3 = H2O(:,2)';
y1 = H2O(:,1)';


subplot(2,1,1)  %Refer to subplot 1
plot(x1,y1,'b')  %Plot pressure vs. specific volume for liquid with a blue line
hold on    %The next plot will be superimposed over it     
plot(x2,y1,'r')  %Plot pressure vs. specific volume for vapor with a red line
plot(x1(find(x1 == x2)),y1(find(x1 == x2)),'k*')  %Plot the critical point
%format subplot 1
legend('Saturated Liquid', 'Saturated Vapor', 'Critical Point','Location','NorthEastOutside') 
axis([0 0.04 100000 30000000])
xlabel('Specific Volume (m^3/kg)')
ylabel('Pressure (Pa)')
title('H_2O')

%Plot Pressure vs. Temperature
subplot(2,1,2) %Refer to subplot 2
hold on  %Plots will be superimposed
plot(x3,y1,'k')  %Plot pressure vs. temperature
plot(x3(find(x1 == x2)),y1(find(x1 == x2)),'k*')  %Plot the critical point
%Label axes
xlabel('Temperature (Celcius)')
ylabel('Pressure (Pa)')

load SaturatedPressureData.dat

%Convert SaturatedPressureData values from psi to Pascal
for i = 1:length(SaturatedPressureData)
SaturatedPressureData(i) = PascalConvert(SaturatedPressureData(i), 'psi');
end
disp('The SaturatedPressureData.dat file was in the units of psi.')  %Display the units that the file was in before the conversion

%Delete values that are outside of the pressure range given in H2O and print them
disp('The pressure values that could not be interpolated are:')
for i = 1:length(SaturatedPressureData)
    if ((SaturatedPressureData(i) < 100000) || (SaturatedPressureData(i) > 22090000))
        fprintf('%d Pa\n',int64(SaturatedPressureData(i)))
        SaturatedPressureData(i) = 0;
    end
end

SaturatedPressureData = SaturatedPressureData(SaturatedPressureData~=0);

 
%Transpose the vector from a row vector to a column vector so that it is easier to use intuitively
SaturatedPressureData = SaturatedPressureData';    

%Create H2Ointerpolated matrix

rSat = length(SaturatedPressureData);
H2Ointerpolated = zeros(rSat,cH2O);   %Preallocate a matrix of zeros for H2Ointerpolated

for i = 1:rSat  %The outer for loop iterates through the rows of SaturatedPressureData
    for k = 1:rH2O   %An inner for loop iterates through the rows of H2O

        if (SaturatedPressureData(i) > H2O(k,1) && SaturatedPressureData(i) < H2O(k+1,1))
        lowValRow = k;    %Define high and low row indices which will be used to refer to values in H2O for the interpolation
        highValRow = k+1;

        H2Ointerpolated(i,1) = SaturatedPressureData(i);  %The first column of H2Ointerpolated will contain all of the SaturatedPressureData values

            for c = 1:(cH2O-1)  %The innermost for loop iterates through the columns of H2O, using its values as inputs for  
                %Use ThermoInterpolation to build the columns of H2Ointerpolated
                %Input the index of SaturatedPressureData as the input pressure and refer to the cooresponding high and low pressure and property values in H2O 
                H2Ointerpolated(i,c+1) = ThermoInterpolation(SaturatedPressureData(i),H2O(highValRow,1),H2O(lowValRow,1),H2O(highValRow,c+1),H2O(lowValRow,c+1));
            end


        end    
    end
end

%save H2Ointerpolates as a .dat file
save H2Ointerpolated.dat H2Ointerpolated -ascii  

%Prompt user to input a specific volume which falls within the range of the specific volumes in the first subplot
inputVol = input('Enter a Specific Volume value in m^3/kg between 0.001 and 0.04 to analyze the pressures at: ');

%Error check the input to make sure that it falls within the specified range
while inputVol < 0.001 || inputVol > 0.04
    inputVol = input('Error! Enter a Specific Volume value in m^3/kg between 0.001 and 0.04 to analyze the pressures at: ');
end

%plot the pressure values from SaturatedPressureData.dat vs. the user entered specific volume on the first subplot 
subplot(2,1,1)
plot(inputVol, SaturatedPressureData)

%Determine whether each pressure of the SatPressure data is saturated, two-phase, or superheated

pressure = 0;   %Initialize the variables that will be used
saturated = 0;
twoPhase = 0;
superheated = 0;

    for j = 1:rH2O-1  %The first loop iterates through the rows in column three of H2O 
    
        if ((inputVol > H2O(j,3)) && (inputVol < H2O(j+1,3)))  %This statement is true if the inputVol falls between two values in column three of H2O
            lowValRow = j;     %Define high and low row indices to be used in PressureInterpolation
            highValRow = j+1;
            %Define the variable 'pressure' using the function PressureInterpolation
            %Pressure will be an approximation of the saturated value 
            %PressureInterpolation interpolates a pressure value based on inputVol and its cooresponding high and low values in H2O
            pressure = PressureInterpolation(inputVol,H2O(highValRow,3),H2O(lowValRow,3),H2O(highValRow,1),H2O(lowValRow,1));  
        end
    end

    %If the previous for loop was not completed, this means that the value falls within the range of column four in H2O
    %The same loop is repeated for column four
    for j = 1:rH2O-1
        
        if ((inputVol < H2O(j,4)) && (inputVol > H2O(j+1,4)))
            lowValRow = j;    
            highValRow = j+1;
            pressure = PressureInterpolation(inputVol,H2O(highValRow,4),H2O(lowValRow,4),H2O(highValRow,1),H2O(lowValRow,1));
        end
    end
    
%This for loop iterates through the SaturatedPressureData values
%'Pressure' is compared to the SaturatedPressureData values
for i = 1:length(SaturatedPressureData)
    if SaturatedPressureData(i) == pressure  %If the SaturatedPressureData value is equal to pressure, then it counts 1 saturated value 
        saturated = 1;
    elseif SaturatedPressureData(i) < pressure  %If the SaturatedPressureData value is less than pressure, it counts 1 twoPhase value
        twoPhase = twoPhase + 1;
    elseif SaturatedPressureData(i) > pressure  %If the SaturatedPressureData value is greater than pressure, it counts 1 superheated value
        superheated = superheated + 1;
    end
end
    
%Print how many of each type is represented
fprintf('There is %d Saturated substance, %d Two-Phase substances,\n and %d Superheated substances at %.4f m^3/kg.\n',saturated, twoPhase, superheated, inputVol)