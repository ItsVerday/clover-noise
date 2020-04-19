# GLSL Clover Noise
Clover Noise is currently implemented in GLSL, for use in GLSL shaders. The code for 2D Clover Noise can be found [here](./clover_noise_2d.fsh), and the 3D code can be found [here](./clover_noise_3d.fsh).

# Usage
GLSL Clover Noise is used as so:

```glsl
// 2D
float value = clover_noise_2d(vec2 position);
float value = fractal_clover_noise_2d(vec2 position, int iterations); // iterations is capped at 10
vec2 curl = curl_clover_noise_2d(vec2 position);
vec2 curl = curl_fractal_clover_noise_2d(vec2 position, int iterations);  // iterations is capped at 10

// 3D
float value = clover_noise_3d(vec3 position);
float value = fractal_clover_noise_3d(vec3 position, int iterations); // iterations is capped at 10
vec3 curl = curl_clover_noise_3d(vec3 position);
vec3 curl = curl_fractal_clover_noise_3d(vec3 position, int iterations);  // iterations is capped at 10
```