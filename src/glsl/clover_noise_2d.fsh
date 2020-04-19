/*
    Copyright (c) 2020 ValgoBoi

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    Clover Noise algorithm from: https://github.com/ValgoBoi/clover-noise
*/

const float CLOVER_NOISE_2D_POINT_SPREAD = .3;
const float CLOVER_NOISE_2D_PI = radians(180.);

float clover_noise_2d_hash(vec2 p) {
    return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

vec2 clover_noise_2d_offset(vec2 p, float hash) {
    vec2 offset = vec2(sin(hash * PI * 100.), cos(hash * PI * 100.)) * floor(hash * 50. + 1.) * .01 + .5;
    return p + offset * CLOVER_NOISE_2D_POINT_SPREAD * 2. + .5 - CLOVER_NOISE_2D_POINT_SPREAD;
}

/**
 * Finds the value of 2D clover noise at a certain location.
 *
 * @param vec2 p The 2D vector where clover noise will be calculated at.
 * @return float The value of clover noise at p, the 2D vector.
 */
float clover_noise_2d(vec2 p) {
    vec2 p_floor = floor(p);

    vec2 c_11 = clover_noise_2d_offset(p_floor, clover_noise_2d_hash(p_floor));
    vec2 c_10 = p_floor + vec2(0, -1);
    c_10 = clover_noise_2d_offset(c_10, clover_noise_2d_hash(c_10));
    vec2 c_12 = p_floor + vec2(0, 1);
    c_12 = clover_noise_2d_offset(c_12, clover_noise_2d_hash(c_12));
    vec2 c_01 = p_floor + vec2(-1, 0);
    c_01 = clover_noise_2d_offset(c_01, clover_noise_2d_hash(c_01));
    vec2 c_21 = p_floor + vec2(1, 0);
    c_21 = clover_noise_2d_offset(c_21, clover_noise_2d_hash(c_21));

    vec2 d_p_c11 = vec2(p.y - c_11.y, p.x - c_11.x);
    vec2 m_p_c11 = d_p_c11 * c_11;

    vec2 side_nx = m_p_c11 - d_p_c11 * c_01;
    vec2 side_px = m_p_c11 - d_p_c11 * c_21;

    vec2 a, c, d;

    if ((side_nx.y - side_nx.x < 0. && p.x < c_11.x) || (side_px.y - side_px.x > 0. && p.x >= c_11.x)) {
        vec2 side_py = m_p_c11 - d_p_c11 * c_12;

        if (side_py.y - side_py.x > 0.) {
            a = c_12;
            c = c_01;
            d = vec2(-1, 1);
        } else {
            a = c_21;
            c = c_12;
            d = vec2(1, 1);
        }
    } else {
        vec2 side_ny = m_p_c11 - d_p_c11 * c_10;

        if (side_ny.y - side_ny.x > 0.) {
            a = c_10;
            c = c_21;
            d = vec2(1, -1);
        } else {
            a = c_01;
            c = c_10;
            d = vec2(-1, -1);
        }
    }

    d = clover_noise_2d_offset(p_floor + d, clover_noise_2d_hash(p_floor + d));

    vec2 f = a;
    vec2 g = c;
    vec2 h = d;

    vec2 ac = a - c;
    vec2 bd = c_11 - d;

    if (ac.x * ac.x + ac.y * ac.y < bd.x * bd.x + bd.y * bd.y) {
        vec2 pa = p - a;

        if (pa.x * ac.y - pa.y * ac.x > 0.) {
            h = c_11;
        }
    } else {
        vec2 pb = p - c_11;

        if (pb.x * bd.y - pb.y * bd.x > 0.) {
            f = c_11;
        } else {
            g = c_11;
        }
    }

    vec2 bc_v0 = g - f;
    vec2 bc_v1 = h - f;
    vec2 bc_v2 = p - f;
    float den = 1. / (bc_v0.x * bc_v1.y - bc_v1.x * bc_v0.y);
    float v = (bc_v2.x * bc_v1.y - bc_v1.x * bc_v2.y) * den;
    float w = (bc_v0.x * bc_v2.y - bc_v2.x * bc_v0.y) * den;
    float u = 1. - v - w;

    v = v * v * v;
    w = w * w * w;
    u = u * u * u;
    float s = 1. / (u + v + w);
    v *= s;
    w *= s;
    u *= s;

    float fv = clover_noise_2d_hash(f);
    float gv = clover_noise_2d_hash(g);
    float hv = clover_noise_2d_hash(h);

    return u * fv + v * gv + w * hv;
}

/**
 * Finds the value of 2D fractal clover noise at a certain location.
 *
 * @param vec2 p The 2D vector where fractal clover noise will be calculated at.
 * @param int iterations The amount of iterations to perform for fractal noise. Capped at 10.
 * @return float The value of fractal clover noise at p, the 2D vector.
 */
float fractal_clover_noise_2d(vec2 p, int iterations) {
    float total = 0.;
    float divide = 0.;

    float scale = 1.;
    float invScale = 1.;

    for (int iter = 0; iter < 10; iter++) {
        if (iter >= iterations) {
            break;
        }
        
        total += clover_noise_2d(p * invScale) * scale;
        divide += scale;
        
        scale *= .4;
        invScale *= 2.5;
    }

    return total / divide;
}

/**
 * Finds the value of 2D curl clover noise at a certain location.
 *
 * @param vec2 p The 2D vector where fractal clover noise will be calculated at.
 * @return vec2 The value of curl clover noise at p, the 2D vector.
 */
vec2 curl_clover_noise_2d(vec2 p) {
    const float DX = 0.01;

    float v = clover_noise_2d(p);
    float x = clover_noise_2d(p + vec2(DX, 0.));
    float y = clover_noise_2d(p + vec2(0., DX));
    return normalize(vec2(v - x, v - y));
}

/**
 * Finds the value of 2D curl fractal clover noise at a certain location.
 *
 * @param vec2 p The 2D vector where curl fractal clover noise will be calculated at.
 * @param int iterations The amount of iterations to perform for fractal noise. Capped at 10.
 * @return vec2 The value of curl fractal clover noise at p, the 2D vector.
 */
vec2 curl_fractal_clover_noise_2d(vec2 p, int iterations) {
    const float DX = 0.01;

    float v = fractal_clover_noise_2d(p, iterations);
    float x = fractal_clover_noise_2d(p + vec2(DX, 0.), iterations);
    float y = fractal_clover_noise_2d(p + vec2(0., DX), iterations);
    return normalize(vec2(v - x, v - y));
}