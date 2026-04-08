/*
 * Parametrized mix frames shader optimized for the Raspberry Pi VideoCore IV (e.g. Pi 3B).
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This shader was based on:
 *
 *   - https://raw.githubusercontent.com/libretro/glsl-shaders/refs/heads/master/motionblur/shaders/mix_frames.glsl
 */


#pragma parameter MIX_RATIO "Mix Ratio" 0.5 0.0 0.5 0.01

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING COMPAT_PRECISION vec2 TEX0;

uniform mat4 MVPMatrix;


void main()
{
    TEX0 = TexCoord.xy;
    gl_Position = MVPMatrix * VertexCoord;
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
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D Texture;
uniform sampler2D PrevTexture;
COMPAT_VARYING COMPAT_PRECISION vec2 TEX0;

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float MIX_RATIO;
#else
#define MIX_RATIO 0.5
#endif


void main()
{
    vec4 curr = COMPAT_TEXTURE(Texture, TEX0);
    vec4 prev = COMPAT_TEXTURE(PrevTexture, TEX0);
    FragColor = mix(curr, prev, MIX_RATIO);
}


#endif
