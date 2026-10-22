% Choose where you want to store custom ROS2 messages
base = "C:\matlab_ros2_custom_msgs";
src  = fullfile(base, "src");
pkg  = fullfile(src, "unitree_hg");

% Create folders if they don't exist
if ~isfolder(base), mkdir(base); end
if ~isfolder(src),  mkdir(src);  end

disp("Created/checked folders:")
disp(base)
disp(src)
disp("Now you must copy the unitree_hg package folder into:")
disp(src)
