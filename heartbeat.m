% Clear any previous mobile device connections
clear m;

% Initialize the mobiledev object
m = mobiledev;  
m.AccelerationSensorEnabled = 0;  % Disable accelerometer
m.AngularVelocitySensorEnabled = 1;  % Enable gyroscope (angular velocity)
m.Logging = 1;  % Start logging data
pause(30);  % Record data for 30 seconds while moving

% Stop logging the data after collection
m.Logging = 0;

% Retrieve the angular velocity data with their timestamps
[data_gyro, time_gyro] = angvellog(m);  % Retrieve gyroscope data and time

% Ensure data has been collected
if isempty(data_gyro)
    error('No gyroscope data found. Ensure the sensor was recording properly.');
end

% Calculate the sampling frequency based on timestamps
fs = 1 / mean(diff(time_gyro));  
fprintf('Sampling Frequency: %.2f Hz\n', fs);

% Process the angular velocity data to simulate a heartbeat
% For simplicity, we'll assume that a higher angular velocity correlates to a higher heart rate

% Calculate mean angular velocity
mean_angular_velocity = mean(data_gyro, 1);
fprintf('Mean Angular Velocity: %.2f rad/s\n', mean_angular_velocity);

% Generate heartbeat signal based on the mean angular velocity
% This can be done by mapping the angular velocity to a heart rate (bpm)
heart_rate_bpm = 60 + 10 * mean(mean_angular_velocity);  % Example mapping

% Generate a time vector for the heartbeat signal
t = 0:1/fs:10;  % 10 seconds duration
heartbeat_signal = 0.5 * sin(2 * pi * heart_rate_bpm / 60 * t);  % Heartbeat signal

% Plot the heartbeat signal
figure;
plot(t, heartbeat_signal);
xlabel('Time (s)');
ylabel('Heartbeat Signal Amplitude');
title('Generated Heartbeat Signal from Angular Velocity Data');
grid on;

% Display the calculated heart rate
fprintf('Calculated Heart Rate: %.2f bpm\n', heart_rate_bpm);

% Optionally, you can save the heartbeat signal to a file
% save('heartbeat_signal.mat', 'heartbeat_signal', 't');
