% Clear any previous mobile device connections
clear m;

% Initialize the mobiledev object
m = mobiledev;  
m.AccelerationSensorEnabled = 0;  % Disable accelerometer if not needed
m.AngularVelocitySensorEnabled = 1;  % Enable gyroscope (optional)
m.Logging = 1;  % Start logging data
pause(10);  % Record data for 30 seconds while moving

% Stop logging the data after collection
m.Logging = 0;

% Retrieve angular velocity data (if needed)
[data_gyro, time_gyro] = angvellog(m);  % Retrieve gyroscope data and time

% Ensure data has been collected
if isempty(data_gyro)
    error('No gyroscope data found. Ensure the sensor was recording properly.');
end

% Get user inputs for MET, weight, and duration

MET = input('Enter the MET value for the activity (e.g., 8 for vigorous exercise): ');
weight = input('Enter your weight in kilograms (kg): ');
duration = input('Enter the duration of the activity in hours (e.g., 1 for 1 hour): ');

% Calculate calories burned
calories_burned = MET * weight * duration;

% Display the result
fprintf('Calories Burned: %.2f calories\n', calories_burned);
