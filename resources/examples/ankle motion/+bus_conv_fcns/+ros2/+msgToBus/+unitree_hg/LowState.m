function slBusOut = LowState(msgIn, slBusOut, varargin)
%#codegen
%   Copyright 2021-2022 The MathWorks, Inc.
                    currentlength = length(slBusOut.version);
                    slBusOut.version = uint32(msgIn.version(1:currentlength));
    slBusOut.mode_pr = uint8(msgIn.mode_pr);
    slBusOut.mode_machine = uint8(msgIn.mode_machine);
    slBusOut.tick = uint32(msgIn.tick);
    currentlength = length(slBusOut.imu_state);
    for iter=1:currentlength
        slBusOut.imu_state(iter) = bus_conv_fcns.ros2.msgToBus.unitree_hg.IMUState(msgIn.imu_state(iter),slBusOut(1).imu_state(iter),varargin{:});
    end
    slBusOut.imu_state = bus_conv_fcns.ros2.msgToBus.unitree_hg.IMUState(msgIn.imu_state,slBusOut(1).imu_state,varargin{:});
    currentlength = length(slBusOut.motor_state);
    for iter=1:currentlength
        slBusOut.motor_state(iter) = bus_conv_fcns.ros2.msgToBus.unitree_hg.MotorState(msgIn.motor_state(iter),slBusOut(1).motor_state(iter),varargin{:});
    end
                    currentlength = length(slBusOut.wireless_remote);
                    slBusOut.wireless_remote = uint8(msgIn.wireless_remote(1:currentlength));
                    currentlength = length(slBusOut.reserve);
                    slBusOut.reserve = uint32(msgIn.reserve(1:currentlength));
    slBusOut.crc = uint32(msgIn.crc);
end
