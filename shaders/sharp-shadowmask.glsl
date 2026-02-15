/*
 *  CRT slotmask or aperture grille over antialiased nearest-neighbor scaling.
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  Based on "gizmo-slotmask-crt" (https://github.com/gizmo98/gizmo-crt-shader).
 */


#pragma parameter MASK_INTENSITY "Shadow Mask Intensity" 0.3 0.0 2.0 0.05
#pragma parameter MASK_WIDTH "Shadow Mask Width"         3.0 2.0 6.0 1.0
#pragma parameter MASK_HEIGHT "Shadow Mask Height"       3.0 2.0 6.0 1.0
#pragma parameter MASK_TRINITRON "Shadow Mask Trinitron" 0.0 0.0 1.0 1.0


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
COMPAT_VARYING COMPAT_PRECISION float vMaskScale;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 OutputSize;

#ifdef PARAMETER_UNIFORM
    uniform COMPAT_PRECISION float MASK_INTENSITY;
    uniform COMPAT_PRECISION float MASK_WIDTH;
    uniform COMPAT_PRECISION float MASK_HEIGHT;
    uniform COMPAT_PRECISION float MASK_TRINITRON;
#else
    #define MASK_INTENSITY 0.3
    #define MASK_WIDTH 3.0
    #define MASK_HEIGHT 3.0
    #define MASK_TRINITRON 0.0
#endif


void main() {  // VERTEX
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy;

    vMaskScale = (OutputSize.x / TextureSize.y) * 0.25;
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

uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING COMPAT_PRECISION float vMaskScale;  // pre-calculated (vertex)

#ifdef PARAMETER_UNIFORM
    uniform COMPAT_PRECISION float MASK_INTENSITY;
    uniform COMPAT_PRECISION float MASK_WIDTH;
    uniform COMPAT_PRECISION float MASK_HEIGHT;
    uniform COMPAT_PRECISION float MASK_TRINITRON;
#else
    #define MASK_INTENSITY 0.3
    #define MASK_WIDTH 3.0
    #define MASK_HEIGHT 3.0
    #define MASK_TRINITRON 0.0
#endif


vec2 scale_antialias(in vec2 uv) {
    uv *= TextureSize;
    return (floor(uv) + clamp(fract(uv) / fwidth(uv), 0.0, 1.0) - 0.5) / TextureSize;
}


COMPAT_PRECISION vec4 draw_shadowmask(in COMPAT_PRECISION vec4 color, in vec2 coord) {
    //
    // On my old ATI Mobility Radeon HD 2600, when MASK_WIDTH/HEIGHT is a multiple of 3.0 the vertical/horizontal lines disappear!
    // If MASK_WIDTH/HEIGHT is replaced by the constant 3.0, they appear! Adding 0.001 to the floor() calls solves this problem...
    //

    // Vertical lines (for both slotmask and trinitron).
    COMPAT_PRECISION float v_mask = step(mod(floor(coord.x) + 0.001, MASK_WIDTH), 0.5);

    // Staggered horizontal lines (for slotmask only).
    COMPAT_PRECISION float field = fract(coord.x / (MASK_WIDTH * 2.0));
    COMPAT_PRECISION float h_mask_a = step(0.0, field) * (1.0 - step(0.5, field)) * step(mod(floor(coord.y + MASK_HEIGHT / 2.0) + 0.001, MASK_HEIGHT), 0.5);
    COMPAT_PRECISION float h_mask_b = step(0.5, field) * step(mod(floor(coord.y) + 0.001, MASK_HEIGHT), 0.5);
    COMPAT_PRECISION float h_mask = (h_mask_a + h_mask_b) * (1.0 - MASK_TRINITRON);

    COMPAT_PRECISION vec4 mask_color = vec4(0.0, 0.0, 0.0, 0.5 * vMaskScale);
    color = mix(color, mask_color, v_mask * MASK_INTENSITY);
    color = mix(color, mask_color, h_mask * MASK_INTENSITY * 0.3);

    return color;
}


void main() {  // FRAGMENT
    vec2 scaled_uv = scale_antialias(TEX0.xy);
    FragColor = draw_shadowmask(COMPAT_TEXTURE(Texture, scaled_uv), gl_FragCoord.xy);
}


#endif  // VERTEX or FRAGMENT
