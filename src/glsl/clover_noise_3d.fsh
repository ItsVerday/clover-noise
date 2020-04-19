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

const float CLOVER_NOISE_3D_POINT_SPREAD = .2;
const float CLOVER_NOISE_3D_PI = radians(180.);

float clover_noise_3d_hash(vec3 p) {
    return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x - p.z)) * sin(12.0 * p.z - sin(p.x * 10.0))));
}

vec3 clover_noise_3d_offset(vec3 p, float hash) {
    float rotation = hash * PI * 2000.;
    float height = (fract((floor(hash * 1000.) + .5) / 100.) - .5) * PI / 2.;
    float layer = floor(hash * 10. + 1.) * .1;
    vec3 offset = vec3(sin(rotation) * cos(height), sin(height), cos(rotation) * cos(height)) * layer + .5;
    return p + offset * CLOVER_NOISE_3D_POINT_SPREAD * 2. + .5 - CLOVER_NOISE_3D_POINT_SPREAD;
}

bool clover_noise_3d_boundary(vec3 p, vec3 c_00, vec3 c_10, vec3 c_20, vec3 c_01, vec3 c_11, vec3 c_21, vec3 c_02, vec3 c_12, vec3 c_22) {
    vec2 d_p_c11 = p.yx - c_11.yx;
    vec2 m_p_c11 = d_p_c11 * c_11.xy;

    vec2 side_nx = m_p_c11 - d_p_c11 * c_01.xy;
    vec2 side_px = m_p_c11 - d_p_c11 * c_21.xy;

    vec3 a, b, c, d;

    if ((side_nx.y - side_nx.x < 0. && p.x < c_11.x) || (side_px.y - side_px.x > 0. && p.x >= c_11.x)) {
        vec2 side_py = m_p_c11 - d_p_c11 * c_12.xy;

        if (side_py.y - side_py.x > 0.) {
            a = c_01;
            b = c_02;
            c = c_12;
            d = c_11;
        } else {
            a = c_11;
            b = c_12;
            c = c_22;
            d = c_21;
        }
    } else {
        vec2 side_ny = m_p_c11 - d_p_c11 * c_10.xy;

        if (side_ny.y - side_ny.x > 0.) {
            a = c_10;
            b = c_11;
            c = c_21;
            d = c_20;
        } else {
            a = c_00;
            b = c_01;
            c = c_11;
            d = c_10;
        }
    }

    vec3 f = a;
    vec3 g = c;
    vec3 h = d;

    vec3 ac = a - c;
    vec3 pa = p - a;

    if (pa.x * ac.y - pa.y * ac.x > 0.) {
        h = b;
    }

    vec2 bc_v0 = g.xy - f.xy;
    vec2 bc_v1 = h.xy - f.xy;
    vec2 bc_v2 = p.xy - f.xy;
    float den = 1. / (bc_v0.x * bc_v1.y - bc_v1.x * bc_v0.y);
    float v = (bc_v2.x * bc_v1.y - bc_v1.x * bc_v2.y) * den;
    float w = (bc_v0.x * bc_v2.y - bc_v2.x * bc_v0.y) * den;
    float u = 1. - v - w;

    return p.z < u * f.z + v * g.z + w * h.z;
}

/**
 * Finds the value of 3D clover noise at a certain location.
 *
 * @param vec3 p The 3D vector where clover noise will be calculated at.
 * @return float The value of clover noise at p, the 3D vector.
 */
float clover_noise_3d(vec3 p) {
    vec3 p_floor = floor(p);

    vec3 c_111 = clover_noise_3d_offset(p_floor, clover_noise_3d_hash(p_floor));
    vec3 c_100 = p_floor + vec3(0, -1, -1);
    c_100 = clover_noise_3d_offset(c_100, clover_noise_3d_hash(c_100));
    vec3 c_010 = p_floor + vec3(-1, 0, -1);
    c_010 = clover_noise_3d_offset(c_010, clover_noise_3d_hash(c_010));
    vec3 c_110 = p_floor + vec3(0, 0, -1);
    c_110 = clover_noise_3d_offset(c_110, clover_noise_3d_hash(c_110));
    vec3 c_210 = p_floor + vec3(1, 0, -1);
    c_210 = clover_noise_3d_offset(c_210, clover_noise_3d_hash(c_210));
    vec3 c_120 = p_floor + vec3(0, 1, -1);
    c_120 = clover_noise_3d_offset(c_120, clover_noise_3d_hash(c_120));
    vec3 c_001 = p_floor + vec3(-1, -1, 0);
    c_001 = clover_noise_3d_offset(c_001, clover_noise_3d_hash(c_001));
    vec3 c_101 = p_floor + vec3(0, -1, 0);
    c_101 = clover_noise_3d_offset(c_101, clover_noise_3d_hash(c_101));
    vec3 c_201 = p_floor + vec3(1, -1, 0);
    c_201 = clover_noise_3d_offset(c_201, clover_noise_3d_hash(c_201));
    vec3 c_011 = p_floor + vec3(-1, 0, 0);
    c_011 = clover_noise_3d_offset(c_011, clover_noise_3d_hash(c_011));
    vec3 c_211 = p_floor + vec3(1, 0, 0);
    c_211 = clover_noise_3d_offset(c_211, clover_noise_3d_hash(c_211));
    vec3 c_021 = p_floor + vec3(-1, 1, 0);
    c_021 = clover_noise_3d_offset(c_021, clover_noise_3d_hash(c_021));
    vec3 c_121 = p_floor + vec3(0, 1, 0);
    c_121 = clover_noise_3d_offset(c_121, clover_noise_3d_hash(c_121));
    vec3 c_221 = p_floor + vec3(1, 1, 0);
    c_221 = clover_noise_3d_offset(c_221, clover_noise_3d_hash(c_221));
    vec3 c_102 = p_floor + vec3(0, -1, 1);
    c_102 = clover_noise_3d_offset(c_102, clover_noise_3d_hash(c_102));
    vec3 c_012 = p_floor + vec3(-1, 0, 1);
    c_012 = clover_noise_3d_offset(c_012, clover_noise_3d_hash(c_012));
    vec3 c_112 = p_floor + vec3(0, 0, 1);
    c_112 = clover_noise_3d_offset(c_112, clover_noise_3d_hash(c_112));
    vec3 c_212 = p_floor + vec3(1, 0, 1);
    c_212 = clover_noise_3d_offset(c_212, clover_noise_3d_hash(c_212));
    vec3 c_122 = p_floor + vec3(0, 1, 1);
    c_122 = clover_noise_3d_offset(c_122, clover_noise_3d_hash(c_122));

    bool x_bound = clover_noise_3d_boundary(p.yzx, c_100.yzx, c_110.yzx, c_120.yzx, c_101.yzx, c_111.yzx, c_121.yzx, c_102.yzx, c_112.yzx, c_122.yzx);
    bool y_bound = clover_noise_3d_boundary(p.xzy, c_010.xzy, c_110.xzy, c_210.xzy, c_011.xzy, c_111.xzy, c_211.xzy, c_012.xzy, c_112.xzy, c_212.xzy);
    bool z_bound = clover_noise_3d_boundary(    p,     c_001,     c_101,     c_201,     c_011,     c_111,     c_211,     c_021,     c_121,     c_221);

    vec3 a, b, c, d, e, f, g, h;

    if (x_bound) {
        if (y_bound) {
            if (z_bound) {
                a = p_floor + vec3(-1, -1, -1);
                b = c_001;
                c = c_010;
                d = c_011;
                e = c_100;
                f = c_101;
                g = c_110;
                h = c_111;

                a = clover_noise_3d_offset(a, clover_noise_3d_hash(a));
            } else {
                a = c_001;
                b = p_floor + vec3(-1, -1, 1);
                c = c_011;
                d = c_012;
                e = c_101;
                f = c_102;
                g = c_111;
                h = c_112;

                b = clover_noise_3d_offset(b, clover_noise_3d_hash(b));
            }
        } else {
            if (z_bound) {
                a = c_010;
                b = c_011;
                c = p_floor + vec3(-1, 1, -1);
                d = c_021;
                e = c_110;
                f = c_111;
                g = c_120;
                h = c_121;

                c = clover_noise_3d_offset(c, clover_noise_3d_hash(c));
            } else {
                a = c_011;
                b = c_012;
                c = c_021;
                d = p_floor + vec3(-1, 1, 1);
                e = c_111;
                f = c_112;
                g = c_121;
                h = c_122;

                d = clover_noise_3d_offset(d, clover_noise_3d_hash(d));
            }
        }
    } else {
        if (y_bound) {
            if (z_bound) {
                a = c_100;
                b = c_101;
                c = c_110;
                d = c_111;
                e = p_floor + vec3(1, -1, -1);
                f = c_201;
                g = c_210;
                h = c_211;

                e = clover_noise_3d_offset(e, clover_noise_3d_hash(e));
            } else {
                a = c_101;
                b = c_102;
                c = c_111;
                d = c_112;
                e = c_201;
                f = p_floor + vec3(1, -1, 1);
                g = c_211;
                h = c_212;

                f = clover_noise_3d_offset(f, clover_noise_3d_hash(f));
            }
        } else {
            if (z_bound) {
                a = c_110;
                b = c_111;
                c = c_120;
                d = c_121;
                e = c_210;
                f = c_211;
                g = p_floor + vec3(1, 1, -1);
                h = c_221;

                g = clover_noise_3d_offset(g, clover_noise_3d_hash(g));
            } else {
                a = c_111;
                b = c_112;
                c = c_121;
                d = c_122;
                e = c_211;
                f = c_212;
                g = c_221;
                h = p_floor + vec3(1, 1, 1);

                h = clover_noise_3d_offset(h, clover_noise_3d_hash(h));
            }
        }
    }

    vec3 ah = a - h;
    vec3 pa = p - a;
    
    vec3 plane_b_sum = cross(ah, b - h) * pa;
    float plane_b = plane_b_sum.x + plane_b_sum.y + plane_b_sum.z;
    vec3 plane_c_sum = cross(ah, c - h) * pa;
    float plane_c = plane_c_sum.x + plane_c_sum.y + plane_c_sum.z;
    vec3 plane_d_sum = cross(ah, d - h) * pa;
    float plane_d = plane_d_sum.x + plane_d_sum.y + plane_d_sum.z;
    vec3 plane_e_sum = cross(ah, e - h) * pa;
    float plane_e = plane_e_sum.x + plane_e_sum.y + plane_e_sum.z;
    vec3 plane_f_sum = cross(ah, f - h) * pa;
    float plane_f = plane_f_sum.x + plane_f_sum.y + plane_f_sum.z;
    vec3 plane_g_sum = cross(ah, g - h) * pa;
    float plane_g = plane_g_sum.x + plane_g_sum.y + plane_g_sum.z;

    vec3 i, j, k, l;
    i = a;
    j = h;

    if (plane_b > 0. && plane_d <= 0.) {
        k = b;
        l = d;
    } else if (plane_d > 0. && plane_c <= 0.) {
        k = d;
        l = c;
    } else if (plane_c > 0. && plane_g <= 0.) {
        k = c;
        l = g;
    } else if (plane_g > 0. && plane_e <= 0.) {
        k = g;
        l = e;
    } else if (plane_e > 0. && plane_f <= 0.) {
        k = e;
        l = f;
    } else {
        k = f;
        l = b;
    }

    vec3 bc_ap = p - i;
    vec3 bc_bp = p - j;

    vec3 bc_ab = j - i;
    vec3 bc_ac = k - i;
    vec3 bc_ad = l - i;

    vec3 bc_bc = k - j;
    vec3 bc_bd = l - j;

    float bc_va6 = dot(bc_bp, cross(bc_bd, bc_bc));
    float bc_vb6 = dot(bc_ap, cross(bc_ac, bc_ad));
    float bc_vc6 = dot(bc_ap, cross(bc_ad, bc_ab));
    float bc_vd6 = dot(bc_ap, cross(bc_ab, bc_ac));
    float bc_v6 = 1. / dot(bc_ab, cross(bc_ac, bc_ad));

    float v = bc_va6 * bc_v6;
    float w = bc_vb6 * bc_v6;
    float t = bc_vc6 * bc_v6;
    float u = bc_vd6 * bc_v6;
    
    float fiu = u * u * u * (1. - v * w * t);
    float fiv = v * v * v * (1. - u * w * t);
    float fiw = w * w * w * (1. - v * u * t);
    float fit = t * t * t * (1. - v * w * u);
    float s = fiu + fiv + fiw + fit;
    fiu /= s;
    fiv /= s;
    fiw /= s;
    fit /= s;

    float iv = clover_noise_3d_hash(i);
    float jv = clover_noise_3d_hash(j);
    float kv = clover_noise_3d_hash(k);
    float lv = clover_noise_3d_hash(l);
    
    return fiv * iv + fiw * jv + fit * kv + fiu * lv;
}

/**
 * Finds the value of 3D fractal clover noise at a certain location.
 *
 * @param vec3 p The 3D vector where fractal clover noise will be calculated at.
 * @param int iterations The amount of iterations to perform for fractal noise. Capped at 10.
 * @return float The value of fractal clover noise at p, the 3D vector.
 */
float fractal_clover_noise_3d(vec3 p, int iterations) {
    float total = 0.;
    float divide = 0.;

    float scale = 1.;
    float invScale = 1.;

    for (int iter = 0; iter < 10; iter++) {
        if (iter >= iterations) {
            break;
        }
        
        total += clover_noise_3d(p * invScale) * scale;
        divide += scale;
        
        scale *= .4;
        invScale *= 2.5;
    }

    return total / divide;
}

/**
 * Finds the value of 3D curl clover noise at a certain location.
 *
 * @param vec3 p The 3D vector where fractal clover noise will be calculated at.
 * @return vec3 The value of curl clover noise at p, the 3D vector.
 */
vec3 curl_clover_noise_3d(vec3 p) {
    const float DX = 0.01;

    float v = clover_noise_3d(p);
    float x = clover_noise_3d(p + vec3(DX, 0., 0.));
    float y = clover_noise_3d(p + vec3(0., DX, 0.));
    float z = clover_noise_3d(p + vec3(0., 0., DX));
    return normalize(vec3(v - x, v - y, v - x));
}

/**
 * Finds the value of 3D curl fractal clover noise at a certain location.
 *
 * @param vec3 p The 3D vector where curl fractal clover noise will be calculated at.
 * @param int iterations The amount of iterations to perform for fractal noise. Capped at 10.
 * @return vec3 The value of curl fractal clover noise at p, the 3D vector.
 */
vec3 curl_fractal_clover_noise_3d(vec3 p, int iterations) {
    const float DX = 0.01;

    float v = fractal_clover_noise_3d(p, iterations);
    float x = fractal_clover_noise_3d(p + vec3(DX, 0., 0.), iterations);
    float y = fractal_clover_noise_3d(p + vec3(0., DX, 0.), iterations);
    float z = fractal_clover_noise_3d(p + vec3(0., 0., DX), iterations);
    return normalize(vec3(v - x, v - y, v - z));
}