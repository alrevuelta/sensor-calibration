# Dependancies
You must download the following Matlab code before running the calibration: https://github.com/Razor-AHRS/razor-9dof-ahrs/tree/master/Matlab/magnetometer_calibration

# Sensor calibration
This repository contains Matlab code to perform sensor calibration of a 9 degrees of freedom sensor, which is a set of thre different sensors: accelerometer, magnetometer and gyroscope. The code is quite generic and can be used with any sensor, but it specifically design for the 9 DOF Sensor Stick from SparkFun (SEN10724).

If you want to use the code as it is, you need the following hardware setup. Just connect your sensors to a microcontroller, such as Arduino and connect it to your computer via a serial port. Write to the serial port the following information:

```cpp
[time, acc_x, acc_y, acc_z, gyr_x, gyr_y, gyr_z, mag_x, mag_y, mag_z]
```
You need to send a set of 10 values, one for timestamp and 9 with the sensor measurements:
* time: Delta of time since the last measurement.
* acc_x: Data from the accelerometer, x-axis.
* acc_y: Data from the accelerometer, y-axis.
* acc_z: Data from the accelerometer, z-axis.
* gyr_x: Data from the gyroscope, x-axis.
* gyr_y: Data from the gyroscope, y-axis.
* gyr_z: Data from the gyroscope, z-axis.
* mag_x: Data from the magnetometer, x-axis.
* mag_y: Data from the magnetometer, y-axis.
* mag_z: Data from the magnetometer, z-axis.

There are three calibration modes, one for each sensor. Modify the variable `calibrate` from 0 to 2:
* `calibrate=0` reads the accelerometer values. In this calibration mode you have to move the sensor around all three axis slowly, trying to not induce to much external accelerations. This will return the minimum and maximum values that the accelerometer measures.
* `calibrate=1` reads the gyroscope values for 10 seconds. In this mode you have to leave the gyroscope still, without applying any external movement. Just leave in on the table. The returned values are the offset. In an ideal sensor they would be zero.
* `calibrate=2` reads the magnetometer values. In this mode you have to move the sensor around the space, trying to cover all the possible points in an imaginary sphere. After 30 seconds, the measurement will finish and you will be given the ellipsoid fit parameters. Without going to much into details, this algorithm peforms a matrix transformation, where an ellipse is transformed into a sphere given some parameters.

# Accelerometer calibration


|           | 1ºPair | 2ºPair | 2ºPair |
|-----------|--------|--------|--------|
| 1ºTriplet | maxX   | maxY   | maxZ   |
| 2ºTriplet | minX   | minY   | minZ   |

<p align="center">
  <img width="700" height="400" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/accel_calib.png">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_x&space;=&space;\frac{min_x&space;&plus;&space;max_x}{2}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_y&space;=&space;\frac{min_y&space;&plus;&space;max_y}{2}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_z&space;=&space;\frac{min_z&space;&plus;&space;max_z}{2}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_x&space;=&space;\frac{1}{max_x&space;-&space;offset_x}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_y&space;=&space;\frac{1}{max_y&space;-&space;offset_y}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_z&space;=&space;\frac{1}{max_z&space;-&space;offset_z}">
</p>

Resulting values
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?calibrated_x&space;=&space;(acc_x&space;-&space;offset_x)scale_x">
</p>
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?calibrated_y&space;=&space;(acc_y&space;-&space;offset_y)scale_y">
</p>
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?calibrated_z&space;=&space;(acc_z&space;-&space;offset_z)scale_z">
</p>

# Gyroscope calibration

# Magnetometer calibration


<p align="center">
  <img width="560" height="420" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/mag_calibration_fit.png">
</p>

<p align="center">
  <img width="560" height="420" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/mag_calibration_wifi.png">
</p>
