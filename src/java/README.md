# Java Clover Noise
Clover Noise is currently implemented in Java, for use in Java programs and applications. The code for the class containing both 2D and 3D Clover Noise can be found [here](./CloverNoise.java).

# Usage
Java Clover Noise is used as so:

```glsl
// 2D
CloverNoise.Noise2D noise2D = new CloverNoise.Noise2D([long seed]); // Seed is optional, will default to current system time if not specified.
double value = noise2D.noise(double x, double y);
double value = noise2D.fractalNoise(double x, double y, int iterations);
CloverNoise.Vector2 curl = noise2D.curlNoise(double x, double y);
CloverNoise.Vector2 curl = noise2D.fractalCurlNoise(double x, double y, int iterations);

double value = noise2D.frostNoise(double x, double y);
double value = noise2D.marbleNoise(double x, double y);

// 3D
CloverNoise.Noise3D noise3D = new CloverNoise.Noise3D([long seed]); // Seed is optional, will default to current system time if not specified.
double value = noise3D.noise(double x, double y, double z);
double value = noise3D.fractalNoise(double x, double y, double z, int iterations);
CloverNoise.Vector3 curl = noise3D.curlNoise(double x, double y, double z);
CloverNoise.Vector3 curl = noise3D.fractalCurlNoise(double x, double y, double z, int iterations);

double value = noise3D.frostNoise(double x, double y, double z);
double value = noise3D.marbleNoise(double x, double y, double z);
```