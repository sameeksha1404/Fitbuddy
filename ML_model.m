clear m
% Function to acquire real-time sensor data
function data = acquireSensorData()
    m = mobiledev;  % Create a mobile device object
    m.AccelerationSensorEnabled = 1;  % Enable accelerometer
    m.AngularVelocitySensorEnabled = 1; % Enable gyroscope
    
    pause(5);  % Allow time for data collection (increased to 10 seconds)
    
    % Acquire sensor data
    data.Acceleration = m.Acceleration; 
    data.AngularVelocity = m.AngularVelocity; 
    
    % Stop the mobile device object
    m.AccelerationSensorEnabled = 0; % Disable accelerometer
    m.AngularVelocitySensorEnabled = 0; % Disable gyroscope
end

% Load activity data
load('walking1.mat');
load('climbing_down_the_stairs.mat');
load('climbing_up_the_stairs.mat');
load('jogging.mat'); % Ensure these files contain 'Acceleration', 'AngularVelocity', and 'ActivityLabel'

% Step 2: Initialize Variables
allFeatures = []; % Initialize matrix to hold all features
allLabels = [];   % Initialize array to hold all labels
activities = {'walking', 'climbing down', 'climbing up', 'jogging'};
dataFiles = {'walking1.mat', 'climbing_down_the_stairs.mat', 'climbing_up_the_stairs.mat', 'jogging.mat'};

% Step 3: Preprocess Data and Feature Extraction
windowSize = 50; % Size of the sliding window

for idx = 1:length(dataFiles)
    % Load the dataset
    load(dataFiles{idx});

    % Preprocess Data (Handle Missing Values)
    Acceleration = fillmissing(table2array(Acceleration), 'linear');
    AngularVelocity = fillmissing(table2array(AngularVelocity), 'linear');

    % Extract Features
    numSamples = size(Acceleration, 1);
    numWindows = floor(numSamples / windowSize);

    % Adjust numWindows if dataset size is smaller than windowSize
    if numWindows == 0
        continue; % Skip to next file if there are not enough samples
    end

    features = zeros(numWindows, 30); % Preallocate feature matrix
    for i = 1:numWindows
        startIdx = (i - 1) * windowSize + 1;
        endIdx = min(i * windowSize, numSamples); % Ensure endIdx does not exceed numSamples
        
        % Mean, variance, and standard deviation for acceleration
        features(i, 1:3) = mean(Acceleration(startIdx:endIdx, :), 1);
        features(i, 4:6) = var(Acceleration(startIdx:endIdx, :), 0, 1); 
        features(i, 7:9) = std(Acceleration(startIdx:endIdx, :), 0, 1); 
        
        % Safety check for AngularVelocity data
        if size(AngularVelocity, 1) >= endIdx
            % Mean, variance, and standard deviation for angular velocity
            features(i, 10:12) = mean(AngularVelocity(startIdx:endIdx, :), 1);
            features(i, 13:15) = var(AngularVelocity(startIdx:endIdx, :), 0, 1); 
            features(i, 16:18) = std(AngularVelocity(startIdx:endIdx, :), 0, 1); 
        else
            % Handle case where AngularVelocity data is insufficient
            features(i, 10:12) = NaN; % or some default value
            features(i, 13:15) = NaN;
            features(i, 16:18) = NaN;
        end
    end
    
    % Step 4: Create Activity Labels
    activityLabels = categorical(cellstr(repmat(activities{idx}, numWindows, 1))); % Create categorical labels

    % Combine features and labels
    allFeatures = [allFeatures; features];  % Concatenate feature matrices
    allLabels = [allLabels; activityLabels]; % Concatenate labels
end

% Step 5: Split Data for Training and Testing
cv = cvpartition(allLabels, 'HoldOut', 0.3); % 30% for testing
trainFeatures = allFeatures(training(cv), :);
trainLabels = allLabels(training(cv));
testFeatures = allFeatures(test(cv), :);
testLabels = allLabels(test(cv));

% Step 6: Train Classifier using Machine Learning Toolbox
treeModel = fitctree(trainFeatures, trainLabels);

% Step 7: Evaluate the Model
predictedLabels = predict(treeModel, testFeatures);
confMat = confusionmat(testLabels, predictedLabels);
accuracy = sum(predictedLabels == testLabels) / length(testLabels) * 100;

% Step 8: Display Results
disp('Confusion Matrix:');
disp(confMat);
fprintf('Accuracy: %.2f%%\n', accuracy);

% Step 9: Save the trained model
save('trainedTreeModel.mat', 'treeModel'); % Save as a binary MAT-file

% Step 10: Acquire real-time sensor data
sensorData = acquireSensorData(); % Call the function to acquire real-time data

% Step 11: Preprocess Real-Time Data
Acceleration = fillmissing(sensorData.Acceleration, 'linear'); % Adjust columns accordingly
AngularVelocity = fillmissing(sensorData.AngularVelocity, 'linear');

% Step 12: Feature extraction for real-time data
numSamples = size(Acceleration, 1);
numWindows = floor(numSamples / windowSize);

if numWindows == 0
    disp('Not enough data to make predictions.');
else
    features = zeros(numWindows, 30); % Preallocate feature matrix

    for i = 1:numWindows
        startIdx = (i - 1) * windowSize + 1;
        endIdx = min(i * windowSize, numSamples);
        
        % Mean, variance, and standard deviation for acceleration
        features(i, 1:3) = mean(Acceleration(startIdx:endIdx, :), 1);
        features(i, 4:6) = var(Acceleration(startIdx:endIdx, :), 0, 1); 
        features(i, 7:9) = std(Acceleration(startIdx:endIdx, :), 0, 1); 
        
        % Safety check for AngularVelocity data
        if size(AngularVelocity, 1) >= endIdx
            features(i, 10:12) = mean(AngularVelocity(startIdx:endIdx, :), 1);
            features(i, 13:15) = var(AngularVelocity(startIdx:endIdx, :), 0, 1); 
            features(i, 16:18) = std(AngularVelocity(startIdx:endIdx, :), 0, 1); 
        else
            features(i, 10:12) = NaN; 
            features(i, 13:15) = NaN;
            features(i, 16:18) = NaN;
        end
    end

    % Step 13: Make Predictions
    predictedLabels = predict(treeModel, features);

    % Step 14: Display Results
    disp('Predicted Activities:');
    a=read.csv('predictedLabels')
    disp(a); % Display predicted activities directly in command window
end
