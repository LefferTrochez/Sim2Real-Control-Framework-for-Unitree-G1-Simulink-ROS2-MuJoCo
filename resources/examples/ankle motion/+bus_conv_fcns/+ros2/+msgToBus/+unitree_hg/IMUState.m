function slBusOut = IMUState(msgIn, slBusOut, varargin)
%#codegen
%   Copyright 2021-2022 The MathWorks, Inc.
                    currentlength = length(slBusOut.quaternion);
                    slBusOut.quaternion = single(msgIn.quaternion(1:currentlength));
                    currentlength = length(slBusOut.gyroscope);
                    slBusOut.gyroscope = single(msgIn.gyroscope(1:currentlength));
                    currentlength = length(slBusOut.accelerometer);
                    slBusOut.accelerometer = single(msgIn.accelerometer(1:currentlength));
                    currentlength = length(slBusOut.rpy);
                    slBusOut.rpy = single(msgIn.rpy(1:currentlength));
    slBusOut.temperature = int16(msgIn.temperature);
end
