

% Clear the workspace and command window
clear; clc;
% User input for fitness profile
user_goal = input('What is your fitness goal? (weight loss/muscle gain/maintenance): ', 's');
user_preferences = input('What activities do you prefer? (e.g., running, cycling, yoga, strength_training): ', 's');
user_preferences = split(user_preferences, ',');  % Split preferences into a cell array
user_durations = input('How many hours can you dedicate to each activity per week? (e.g., running:2, cycling:3): ', 's');
user_durations = split(user_durations, ',');  % Split input into a cell array
% Create a structure to hold user activity durations
activity_durations = struct();
for i = 1:length(user_durations)
   activity_info = split(strtrim(user_durations{i}), ':');
   activity_durations.(strtrim(activity_info{1})) = str2double(strtrim(activity_info{2}));
end
% Display user activity preferences and durations
disp('Your activity preferences and durations:');
for activity = fieldnames(activity_durations)'
   fprintf('%s: %.1f hours/week\n', activity{1}, activity_durations.(activity{1}));
end
% Simulate a recommendation plan based on user preferences
recommendation_plan = strings(7, 1);  % Initialize recommendation plan for 7 days
for day = 1:7
   % Recommend activities based on user goal and preferences
   if any(contains(user_preferences, 'running')) && activity_durations.running > 0
       recommendation_plan(day) = "30-minute run.";
       activity_durations.running = activity_durations.running - 0.5;  % Deduct time for the recommended activity
   elseif any(contains(user_preferences, 'cycling')) && activity_durations.cycling > 0
       recommendation_plan(day) = "45-minute cycling session.";
       activity_durations.cycling = activity_durations.cycling - 0.75;  % Deduct time for the recommended activity
   elseif any(contains(user_preferences, 'yoga')) && activity_durations.yoga > 0
       recommendation_plan(day) = "30-minute yoga/stretching.";
       activity_durations.yoga = activity_durations.yoga - 0.5;  % Deduct time for the recommended activity
   elseif any(contains(user_preferences, 'strength_training')) && activity_durations.strength_training > 0
       recommendation_plan(day) = "45-minute strength training session.";
       activity_durations.strength_training = activity_durations.strength_training - 0.75;  % Deduct time for the recommended activity
   else
       recommendation_plan(day) = "Rest day or light walking.";
   end
end
% Display the recommendation plan
fprintf('\nWeekly Recommendation Plan based on your preferences:\n');
for day = 1:7
   fprintf('Day %d: %s\n', day, recommendation_plan(day));
end
% User feedback on the plan
user_feedback = input('Do you want to adjust the recommendation plan? (yes/no): ', 's');
if strcmp(user_feedback, 'yes')
   % Allow user to adjust recommendations based on feedback
   fprintf('Adjusting the plan based on user preferences...\n');
   adjustment = input('What activity would you like to change? ', 's');
   new_activity = input('What is your new preferred activity? ', 's');
  
   for day = 1:7
       if contains(recommendation_plan(day), adjustment)
           recommendation_plan(day) = strrep(recommendation_plan(day), adjustment, new_activity);
       end
   end
  
   % Display the adjusted recommendation plan
   fprintf('\nAdjusted Weekly Recommendation Plan:\n');
   for day = 1:7
       fprintf('Day %d: %s\n', day, recommendation_plan(day));
   end
end
