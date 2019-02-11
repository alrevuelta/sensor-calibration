clear all; clc; close all;
%-------------------------------------------------------------------------%
% Code  : sensor_calibration.m                                            %
% Author: alrevuelta (2017)                                               %
%                                                                         %
% Description: This code is used to calibrate an accelerometer,           %
% magnetometer and gyroscope. You can use any hardware, just connect      %
% it to the computer and send through the serial port data with the       %
% following structure:                                                    %
% [time, acc_x, acc_y, acc_z, gyr_x, gyr_y, gyr_z, mag_x, mag_y, mag_z]   %
%                                                                         %
% The calibration is done in three different steps, see "calibrate"       %
% variable. Each step corresponds to a different sensor calibration       %
%   -Accelerometer (0): Read max and maximum values for the accelerometer %
%   -Gyroscope (1)    : Reads static angular speed                        %
%   -Magnetometer (2) : Uses the ellipsoid fit method                     %
%                                                                         %
% Really good information and documentation of how calibration is done    %
% can be found in the following links:                                    %
%   -https://github.com/Razor-AHRS/razor-9dof-ahrs                        %
%-------------------------------------------------------------------------%

% External dependancies
% Download and locate in this folder the following:
% https://github.com/Razor-AHRS/razor-9dof-ahrs/tree/master/Matlab/magnetometer_calibration
if ~exist('magnetometer_calibration.m', 'file') || ...
        ~exist('ellipsoid_fit.m', 'file')
    error('Download from https://github.com/Razor-AHRS Matlab dependancies')
end

% Modify the variable:
%   0: Calibrate accelerometer
%   1: Calibrate gyroscope
%   2: Calibrate magnetometer

% Set the calibration mode
%--------------------------------------------------------------------------
calibrate = 0;
%--------------------------------------------------------------------------

% Set the serial port name
%--------------------------------------------------------------------------
serialPortName = '/dev/cu.usbmodem1421'
%--------------------------------------------------------------------------

% Closes previous opened streams
try
    fclose(instrfindall);
catch
end

% Open the serial port
serialPort = serial(serialPortName);
fopen(serialPort);

% Arrays to store the data
Accelerometer = [[]];
Gyroscope     = [[]];
Magnetometer  = [[]];
Time          = [];

%-------------------------------------------------------------------------%
% A C E L E R O M E T E R                    C A L I B R A T I O N        %
%-------------------------------------------------------------------------%
% To calibrate the accelerometer we need to know the maximum and minimum
% values of the gravity for each x, y, z axis.
% So run the code and move the sensor very slowly in all directions. Do it
% slowly to capture only pure earth gravity and not external accelerations.
% When finished write down the values. You will have to modify the Arduino
% code with that values.
% Click Control+C to end the execution of the infinite loop.
if (calibrate == 0)
    ax_max = 0; ay_max = 0; az_max = 0;
    ax_min = 0; ay_min = 0; az_min = 0;
    
    tic
    i = 1;
    while 1
        udp_packet = serialPort.fscanf;
        if ~(isempty(udp_packet))
            
            try
                test = strsplit(udp_packet, '=');
                test = test{2};
                fields = strsplit(test, ',');
                
                ax = str2double(fields{2});
                ay = str2double(fields{3});
                az = str2double(fields{4});
                
                if (ax > ax_max)
                    ax_max = ax;
                elseif (ax < ax_min)
                    ax_min = ax;
                end
                
                if (ay > ay_max)
                    ay_max = ay;
                elseif (ay < ay_min)
                    ay_min = ay;
                end
                
                if (az > az_max)
                    az_max = az;
                elseif (az < az_min)
                    az_min = az;
                end
                
                disp([num2str(ax_min) ',' num2str(ax_max) '  ' num2str(ay_min) ',' ...
                    num2str(ay_max) '  ' num2str(az_min) ',' num2str(az_max)])
                
                i = i + 1;
            catch
                disp('Lost packet')
            end
            
        end
        
        if isempty(udp_packet)
            continue;
        end
        
    end
    
    fclose(serialPort);
    delete(serialPort);
    
end

%-------------------------------------------------------------------------%
% G Y R O S C O P E                          C A L I B R A T I O N        %
%-------------------------------------------------------------------------%
% Now it is time to get the offset of the gyroscope. In an ideal gyro
% the output angular speed would be zero if it is idle, without moving.
% However in real applications that is not true. Even if the gyroscope
% is not moving the speed will have a small value. This calibration step
% focus on how to get that offset speed. Run this code and wait for 10
% seconds. At the end, write down the values.
if (calibrate == 1)
    
    tic
    i = 1;
    while toc < 10
        udp_packet = serialPort.fscanf;
        if ~(isempty(udp_packet))
            
            try
                test = strsplit(udp_packet, '=');
                test = test{2};
                fields = strsplit(test, ',');
                
                gx = str2double(fields{5});
                gy = str2double(fields{6});
                gz = str2double(fields{7});
                
                disp([num2str(gx) ',' num2str(gy) ',' num2str(gz)])
                
                i = i + 1;
            catch
                disp('Lost packet')
            end
            
        end
        
        if isempty(udp_packet)
            continue;
        end
        
    end
    
    fclose(serialPort);
    delete(serialPort);
    
end


%-------------------------------------------------------------------------%
% M A G N E T O M E T E R                    C A L I B R A T I O N        %
%-------------------------------------------------------------------------%
% Now it is time to calibrate the magnetometer. Remember that if the WiFi
% module is used, the calibration has to be done with if turned on, because
% it will affect to the magnetometer measurements.

% The calibration is done by measuring the field in each axis in all
% directions. So run this code and move the sensor along al directions,
% trying to cover an imaginary sphere. After 30 seconds the ellipsoid
% fit will be printed (See documentation)
if (calibrate == 2)
    
    % Arrays to store the data
    Magnetometer  = [[]];
    
    time = [];
    
    tic
    i = 1;
    % Run for x seconds
    while toc<30
        udp_packet = serialPort.fscanf;
        if ~(isempty(udp_packet))
            
            try
                test = strsplit(udp_packet, '=');
                test = test{2};
                fields = strsplit(test, ',');
                
                Magnetometer(i,1) = str2double(fields{8});
                Magnetometer(i,2) = str2double(fields{9});
                Magnetometer(i,3) = str2double(fields{10});
                
                disp([num2str(Magnetometer(i,1)) ',' num2str(Magnetometer(i,1)) ',' num2str(Magnetometer(i,1))])
                
                i = i + 1;
            catch
                disp('Lost packet')
            end
            
        end
        
        if isempty(udp_packet)
            continue;
        end
    end
    
    % Close the opened port
    fclose(serialPort);
    delete(serialPort);
    
    x = Magnetometer(:,1);
    y = Magnetometer(:,2);
    z = Magnetometer(:,3);

    % This function is located in the external libraries folder
    magnetometer_calibration;
end
