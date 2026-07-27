/*
 *  Blends the current pixel with the previous and the next pixels on a line.
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 */


#pragma parameter H_BLEND_RATIO "Horizontal Blend Intensity" 0.5 0.0 1.0 0.05
#pragma parameter H_BLEND_THRESHOLD "Horizontal Blend Threshold" 0.8 0.0 1.0 0.05

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
COMPAT_VARYING COMPAT_PRECISION vec2 vTexCoord;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 TextureSize;


void main()
{
    TEX0 = TexCoord.xy;
    gl_Position = MVPMatrix * VertexCoord;

    float offset = 1.1 / max(TextureSize.x, 1.0);
    vTexCoord = vec2(TexCoord.x - offset, TexCoord.x + offset);
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
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D Source;
COMPAT_VARYING COMPAT_PRECISION vec2 TEX0;
COMPAT_VARYING COMPAT_PRECISION vec2 vTexCoord;

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float H_BLEND_RATIO;
uniform COMPAT_PRECISION float H_BLEND_THRESHOLD;
#else
#define H_BLEND_RATIO 0.5
#define H_BLEND_THRESHOLD 0.8
#endif


void main()
{
    vec3 center = COMPAT_TEXTURE(Source, TEX0).rgb;
    vec3 left = COMPAT_TEXTURE(Source, vec2(vTexCoord.x, TEX0.y)).rgb;
    vec3 right = COMPAT_TEXTURE(Source, vec2(vTexCoord.y, TEX0.y)).rgb;
    vec3 neighbors = (left + right) * 0.5;

    const vec3 lumaWeights = vec3(0.299, 0.587, 0.114);
    float lumaContrast = abs(dot(center - neighbors, lumaWeights));

    float edgeThreshold = max(1.0 - H_BLEND_THRESHOLD, 0.01);
    float edgeMask = 1.0 - smoothstep(0.0, edgeThreshold, lumaContrast);

    FragColor = vec4(mix(center, neighbors, H_BLEND_RATIO * edgeMask * 0.5), 1.0);
}


#endif  // VERTEX or FRAGMENT
