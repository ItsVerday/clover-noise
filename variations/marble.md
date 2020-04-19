# Marble Noise
Marble Noise emulates the texture of Marble, a type of stone. It is created by taking the difference of two noise values, and darkening the areas where the two values are close together.

![Marble Noise](../media/marble_noise.png)

# Implementation
Marble Noise is created with the algorithm described below, in pseudo-code:

```
function marble_noise(position [vector]):
    position_2 [vector] = position * 0.6
    d1 [float] = max(1 - abs(fractal_clover_noise(position_2 + 100, 4) - fractal_clover_noise(position_2 + 200, 3)) * 3, 0)
    d1 = d1 * d1 * d1
    d1 *= fractal_clover_noise(position_2 + 300, 2) * 0.3

    curl_1 [vector] = curl_fractal_clover_noise(position + 400, 3) * fractal_clover_noise(position + 500, 2) * 0.05

    position_3 [vector] = position * 1.2
    d2 [float] = max(1 - abs(fractal_clover_noise(position_3 + curl_1 + 600, 4) - fractal_clover_noise(position_3 + curl_1 + 700, 3)) * 2, 0)
    d2 = d2 * d2 * d2
    d2 *= fractal_clover_noise(position_3 + 800, 2) * 0.5

    value [float] = 1 - fractal_clover_noise(p + 900, 5)
    v = 1 - v * v * v

    return constrain(v - d1 - d2, 0, 1)
```