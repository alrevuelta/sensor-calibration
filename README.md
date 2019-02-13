# Dependancies
You must download the following Matlab code into your workspace before running the calibration: https://github.com/Razor-AHRS/razor-9dof-ahrs/tree/master/Matlab/magnetometer_calibration, since it is used for the magnetometer calibration.

# Sensor calibration
This repository contains Matlab code to perform sensor calibration on a 9 degrees of freedom sensor, which is a set of three different sensors: accelerometer, magnetometer and gyroscope. The code is quite generic and can be used with any sensor, but it specifically design for the 9 DOF Sensor Stick from SparkFun (SEN10724).

If you want to use the code as it is, you need the following hardware setup. Just connect your sensor to a microcontroller, such as an Arduino and connect it to your computer via a serial port. Write to the serial port the following information:

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

Once you are sending this information through the serial port, you can run the Matlab code in three different modes. There are three calibration modes, one for each sensor. Modify the variable `calibrate` from 0 to 2:
* `calibrate=0` reads the accelerometer values. In this calibration mode you have to move the sensor around all three axis slowly, trying to not induce to much external accelerations. This will return the minimum and maximum values that the accelerometer measures.
* `calibrate=1` reads the gyroscope values for 10 seconds. In this mode you have to leave the gyroscope still, without applying any external movement. Just leave in on the table. The returned values are the offset. In an ideal sensor they would be zero.
* `calibrate=2` reads the magnetometer values. In this mode you have to move the sensor around the space, trying to cover all the possible points in an imaginary sphere. After 30 seconds, the measurement will finish and you will be given the ellipsoid fit parameters. Without going to much into details, this algorithm peforms a matrix transformation, where an ellipse is transformed into a sphere given some parameters.

Each calibration mode will return a set of values, that are used for the calibration of each sensor. In the following section some information for each sensor is given, so you can know how to use them for calibrating your sensors. Note that calibrate means that after reading the raw data from the sensors, some transformation are performed that take into account different bias of the sensor to get a more accurate measurement.


# Accelerometer calibration
Once you have reached this point, you should have the minimum and maximum values of the accelerometer per axis. Lets note this values as `maxX, maxY, maxZ` and `minX, minY, minZ`. Note that if you are using `Gs` these values should be around `1` and `-1`.

<center>
|           | 1ºPair | 2ºPair | 2ºPair |
|-----------|--------|--------|--------|
| 1ºTriplet | maxX   | maxY   | maxZ   |
| 2ºTriplet | minX   | minY   | minZ   |
</center>

In this table you can see how you have to move your sensor to read all the possible values that we have mentioned. Note that it is very important that you don't induce external acceleration to the sensor, so move it slowly.
<p align="center">
  <img width="700" height="400" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/accel_calib.png">
</p>

Once that we have all 6 values, we have to do some basic calculations to get the `offsets` and `scales`. Accelerometer calibration is done using these two values (per axis). So you can calculate the `offsets` using the following expressions:

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_x&space;=&space;\frac{min_x&space;&plus;&space;max_x}{2}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_y&space;=&space;\frac{min_y&space;&plus;&space;max_y}{2}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?offset_z&space;=&space;\frac{min_z&space;&plus;&space;max_z}{2}">
</p>

And the `scales` using the following expressions:
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_x&space;=&space;\frac{1}{max_x&space;-&space;offset_x}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_y&space;=&space;\frac{1}{max_y&space;-&space;offset_y}">
</p>

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?scale_z&space;=&space;\frac{1}{max_z&space;-&space;offset_z}">
</p>

Once we have the `offsets` and `scales`, we have to just apply them to our accelerometer measurement. This just squeezes or expands the measurements and adds an offset. If you try to run the calibration code again, but having the accelerometer measurements calibrated, you should see that all values are exactly either 1 or -1.
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

Gyroscope calibration is pretty straight forward. The Matlab code will return a set of three offset values (one per axis). You just have to substract them from you gyroscope measurements. Feel free to experiment with this. You can also average a bunch of samples and use that as the offset.

# Magnetometer calibration
You can search further information about the magnetometer calibration by the keyword `hard iron` and `soft iron`. In this code we use the `ellipsoid fit` method to correct `soft iron` effects. This method assumes that the measurements of the magnetometer will have an ellipsoid like distribution, and with a simple transformation, it is transformed into an sphere.

Note that we can describe and ellipse with the following equiations using `A,B,C,D,E,G,H,I` parameters.
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?Ax^2&space;&plus;&space;By^2&space;&plus;&space;Cz^2&space;&plus;&space;2Dxy&space;&plus;&space;2Exz&space;&plus;&space;2Fyz&space;&plus;&space;2Gx&space;&plus;&space;2Hy&space;&plus;&space;2Iz">
</p>

With the following expression we can do this transformation. Note that `c` is the center of the transformation and `exy` is the `xy` element of the transformation matrix. The Matlab code available in this repository, will give you this two matrices. One 3x3 and one 3x1. Once you have them, you are ready to calibrate your magnetometer measurements.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?\begin{pmatrix}&space;mag_x&space;\\&space;max_y&space;\\&space;max_z&space;\\&space;\end{pmatrix}&space;=&space;\begin{pmatrix}&space;e_{11}&space;&&space;e_{12}&space;&&space;e_{13}\\&space;e_{21}&space;&&space;e_{22}&space;&&space;e_{23}\\&space;e_{31}&space;&&space;e_{32}&space;&&space;e_{33}\\&space;\end{pmatrix}\begin{pmatrix}&space;mag_x&space;-&space;c_x&space;\\&space;max_y&space;-&space;c_y\\&space;mag_z&space;-&space;c_z\\&space;\end{pmatrix}">
</p>

Note that the influence of nearby ferromagnetic material or electromagnetic fields can change the readings of the magnetometer. Here you have an example of the dots distribution os a SEN10724 sensor with an Arduino MKR1000.

<p align="center">
  <img width="560" height="420" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/mag_calibration_fit.png">
</p>

And here you have the distribution for the same setup but with the MKR1000 WiFi module on. The result is quite different.
<p align="center">
  <img width="560" height="420" src="https://github.com/alrevuelta/sensor-calibration/blob/master/img/mag_calibration_wifi.png">
</p>
