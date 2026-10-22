function rosmsgOut = MotorCmd(slBusIn, rosmsgOut)
%#codegen
%   Copyright 2021 The MathWorks, Inc.
    rosmsgOut.mode = uint8(slBusIn.mode);
    rosmsgOut.q = single(slBusIn.q);
    rosmsgOut.dq = single(slBusIn.dq);
    rosmsgOut.tau = single(slBusIn.tau);
    rosmsgOut.kp = single(slBusIn.kp);
    rosmsgOut.kd = single(slBusIn.kd);
    rosmsgOut.reserve = uint32(slBusIn.reserve);
end
