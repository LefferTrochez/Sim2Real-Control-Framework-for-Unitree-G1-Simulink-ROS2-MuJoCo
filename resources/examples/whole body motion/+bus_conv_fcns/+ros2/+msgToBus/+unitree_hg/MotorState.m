function slBusOut = MotorState(msgIn, slBusOut, varargin)
%#codegen
%   Copyright 2021-2022 The MathWorks, Inc.
    slBusOut.mode = uint8(msgIn.mode);
    slBusOut.q = single(msgIn.q);
    slBusOut.dq = single(msgIn.dq);
    slBusOut.ddq = single(msgIn.ddq);
    slBusOut.tau_est = single(msgIn.tau_est);
                    currentlength = length(slBusOut.temperature);
                    slBusOut.temperature = int16(msgIn.temperature(1:currentlength));
    slBusOut.vol = single(msgIn.vol);
                    currentlength = length(slBusOut.sensor);
                    slBusOut.sensor = uint32(msgIn.sensor(1:currentlength));
    slBusOut.motorstate = uint32(msgIn.motorstate);
                    currentlength = length(slBusOut.reserve);
                    slBusOut.reserve = uint32(msgIn.reserve(1:currentlength));
end
