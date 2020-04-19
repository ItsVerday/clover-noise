# Frost Noise
Frost Noise is an icy-looking noise created with Clover Noise. It is created using Curl Clover Noise, and layering a few different layers of noise, some with offsets.

![Frost Noise](../media/frost_noise.png)

# Implementation
Frost Noise is created with the algorithm described below, in pseudo-code:

```
function frost_noise(position [vector]):
    curl_1 [vector] = curl_fractal_clover_noise(position, 3) * (fractal_clover_noise(position, 2) * 0.4 + 0.3)
    position_offset_1 [vector] = position + curl_1
    curl_2 [vector] = curl_fractal_clover_noise(position_offset_1, 4) * (fractal_clover_noise(position_offset_1, 3) * 0.1 + 0.05)
    position_offset_2 [vector] = position_offset_1 + curl_2

    value [float] = fractal_clover_noise(position_offset_2, 5) - fractal_clover_noise(position_offset_1, 3) * 0.5 + fractal_clover_noise(position, 2) * 0.3
    return value
```

Alternatively, a second position can be passed into the Frost Noise algorithm, which is offset from the first, in order to create the illusion of perspective:

```
function frost_noise(position [vector], position_under [vector]):
    curl_1 [vector] = curl_fractal_clover_noise(position, 3) * (fractal_clover_noise(position, 2) * 0.4 + 0.3)
    position_offset_1 [vector] = position + curl_1
    curl_2 [vector] = curl_fractal_clover_noise(position_offset_1, 4) * (fractal_clover_noise(position_offset_1, 3) * 0.1 + 0.05)
    position_offset_2 [vector] = position_offset_1 + curl_2

    value [float] = fractal_clover_noise(position_under + curl_2, 5) - fractal_clover_noise(position_offset_1, 3) * 0.5 + fractal_clover_noise(position, 2) * 0.3
    return value

position [vector] = ... // some way of getting the position
position_under [vector] = position * 0.5 - time * 0.25
value = frost_noise(position, position_under)
```