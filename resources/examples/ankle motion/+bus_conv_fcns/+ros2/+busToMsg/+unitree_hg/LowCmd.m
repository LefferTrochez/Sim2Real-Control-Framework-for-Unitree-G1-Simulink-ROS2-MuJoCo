function rosmsgOut = LowCmd(slBusIn, rosmsgOut)
%#codegen
%   Copyright 2021 The MathWorks, Inc.
    rosmsgOut.mode_pr = uint8(slBusIn.mode_pr);
    rosmsgOut.mode_machine = uint8(slBusIn.mode_machine);
    for iter=1:35
        rosmsgOut.motor_cmd(iter) = bus_conv_fcns.ros2.busToMsg.unitree_hg.MotorCmd(slBusIn.motor_cmd(iter),rosmsgOut.motor_cmd(1));
    end
    rosmsgOut.reserve = uint32(slBusIn.reserve);
    rosmsgOut.crc = uint32(slBusIn.crc);
end
