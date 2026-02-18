/*
 *  CRT noise.
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  Based on "gizmo-slotmask-crt" (https://github.com/gizmo98/gizmo-crt-shader).
 */


#pragma parameter NOISE_INTENSITY "Noise Intensity" 2.0 0.0 5.0 0.05
#pragma parameter NOISE_WEIGHTED "Noise Uniformity" 1.0 0.0 1.0 1.0


#if defined(VERTEX)

#if __VERSION__ >= 130
    #define COMPAT_VARYING out
    #define COMPAT_ATTRIBUTE in
#else
    #define COMPAT_VARYING varying
    #define COMPAT_ATTRIBUTE attribute
#endif

#ifdef GL_ES
    #define COMPAT_PRECISION mediump
#else
    #define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING COMPAT_PRECISION vec4 vNoiseWeights;

uniform mat4 MVPMatrix;

#ifdef PARAMETER_UNIFORM
    uniform COMPAT_PRECISION float NOISE_INTENSITY;
    uniform COMPAT_PRECISION float NOISE_WEIGHTED;
#else
    #define NOISE_INTENSITY 2.0
    #define NOISE_WEIGHTED 1.0
#endif


void main() {  // VERTEX
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy;

    vNoiseWeights = (NOISE_INTENSITY * 0.03125) * mix(vec4(1.0), vec4(1.4, 1.0, 2.0, 1.0), NOISE_WEIGHTED);
}


#elif defined(FRAGMENT)

#if __VERSION__ >= 130
    #define COMPAT_VARYING in
    #define COMPAT_TEXTURE texture
    out vec4 FragColor;
#else
    #define COMPAT_VARYING varying
    #define FragColor gl_FragColor
    #define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif
    #define COMPAT_PRECISION mediump
#else
    #define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameCount;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING COMPAT_PRECISION vec4 vNoiseWeights;  // pre-calculated (vertex)


COMPAT_PRECISION vec4 add_noise(in COMPAT_PRECISION vec4 color, in vec2 coord) {
    COMPAT_PRECISION float seed = length(coord) * 1.618 + float(FrameCount) * 0.025;
    COMPAT_PRECISION float noise = fract(sin(seed) * coord.x * coord.y);

    return clamp(color + (noise - 0.5) * vNoiseWeights, 0.0, 1.0);
}


void main() {  // FRAGMENT
    FragColor = add_noise(COMPAT_TEXTURE(Texture, TEX0.xy), gl_FragCoord.xy);
}


#endif  // VERTEX or FRAGMENT
