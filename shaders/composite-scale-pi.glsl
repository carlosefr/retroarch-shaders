/*
 * Combined sharp-bilinear scaling + simple color controls optimized for the Raspberry Pi VideoCore IV (e.g. Pi 3B).
 */

#pragma parameter S_GAMMA_IN "Gamma In" 2.4 1.0 4.0 0.05
#pragma parameter S_GAMMA_OUT "Gamma Out" 2.2 1.0 4.0 0.05
#pragma parameter S_BRIGHTNESS "Brightness" 1.0 0.0 2.0 0.01
#pragma parameter S_CONTRAST "Contrast" 1.0 0.00 2.00 0.01
#pragma parameter S_BLACK "Black Level" 0.5 0.0 1.0 0.01
#pragma parameter S_BRIGHT_BOOST "Bright Boost" 1.0 1.0 2.0 0.05
#pragma parameter S_DARK_BOOST "Dark Boost" 1.0 1.0 2.0 0.05
#pragma parameter S_SATURATION "Saturation" 1.0 0.0 2.0 0.01
#pragma parameter S_TEMPERATURE "Temperature (Blue-Red)" 1.0 0.0 2.0 0.01
#pragma parameter S_RED "Red" 1.0 0.0 2.0 0.01
#pragma parameter S_GREEN "Green" 1.0 0.0 2.0 0.01
#pragma parameter S_BLUE "Blue" 1.0 0.0 2.0 0.01


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
COMPAT_VARYING vec4 TEX0;

COMPAT_VARYING vec2 vTexel;
COMPAT_VARYING vec2 vScale;
COMPAT_VARYING vec2 vRegionRange;

COMPAT_VARYING COMPAT_PRECISION float vGammaRatio;
COMPAT_VARYING COMPAT_PRECISION float vBlackScale;
COMPAT_VARYING COMPAT_PRECISION float vAdjustedBlack;
COMPAT_VARYING COMPAT_PRECISION vec3 vColorMult;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

#define SourceSize vec4(TextureSize, 1.0 / TextureSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float S_GAMMA_IN;
uniform COMPAT_PRECISION float S_GAMMA_OUT;
uniform COMPAT_PRECISION float S_BLACK;
uniform COMPAT_PRECISION float S_BRIGHTNESS;
uniform COMPAT_PRECISION float S_RED;
uniform COMPAT_PRECISION float S_GREEN;
uniform COMPAT_PRECISION float S_BLUE;
uniform COMPAT_PRECISION float S_TEMPERATURE;
#else
#define S_GAMMA_IN 2.4
#define S_GAMMA_OUT 2.2
#define S_BLACK 0.0
#define S_BRIGHTNESS 1.0
#define S_RED 1.0
#define S_GREEN 1.0
#define S_BLUE 1.0
#define S_TEMPERATURE 0.0
#endif


void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy;

    vTexel = TEX0.xy * SourceSize.xy;
    vScale = max(floor(OutputSize.xy / InputSize.xy), vec2(1.0, 1.0));
    vRegionRange = 0.5 - 0.5 / vScale;

    vGammaRatio = S_GAMMA_IN / S_GAMMA_OUT;

    vAdjustedBlack = (S_BLACK - 0.5) * 0.4;
    vBlackScale = 1.0 / (1.0 - vAdjustedBlack);

    COMPAT_PRECISION float adjusted_temperature = (S_TEMPERATURE - 1.0) * 0.5;
    vColorMult = vec3(S_RED + adjusted_temperature, S_GREEN, S_BLUE - adjusted_temperature) * S_BRIGHTNESS;
}


#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out mediump vec4 FragColor;
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

uniform COMPAT_PRECISION vec2 TextureSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

#define SourceSize vec4(TextureSize, 1.0 / TextureSize)

COMPAT_VARYING COMPAT_PRECISION vec2 vTexel;
COMPAT_VARYING COMPAT_PRECISION vec2 vScale;
COMPAT_VARYING COMPAT_PRECISION vec2 vRegionRange;

COMPAT_VARYING COMPAT_PRECISION float vGammaRatio;
COMPAT_VARYING COMPAT_PRECISION float vBlackScale;
COMPAT_VARYING COMPAT_PRECISION float vAdjustedBlack;
COMPAT_VARYING COMPAT_PRECISION vec3 vColorMult;

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float S_CONTRAST;
uniform COMPAT_PRECISION float S_SATURATION;
uniform COMPAT_PRECISION float S_BLACK;
uniform COMPAT_PRECISION float S_BRIGHT_BOOST;
uniform COMPAT_PRECISION float S_DARK_BOOST;
#else
#define S_CONTRAST 1.0
#define S_SATURATION 1.0
#define S_BLACK 0.0
#define S_BRIGHT_BOOST 1.0
#define S_DARK_BOOST 1.0
#endif


COMPAT_PRECISION vec2 sharp_bilinear_scaling(COMPAT_PRECISION vec2 texel, COMPAT_PRECISION vec2 scale, COMPAT_PRECISION vec2 region_range)
{
    COMPAT_PRECISION vec2 texel_idx = floor(texel);
    COMPAT_PRECISION vec2 fract_offset = texel - texel_idx;
    COMPAT_PRECISION vec2 center_dist = fract_offset - 0.5;
    COMPAT_PRECISION vec2 interp_weight = (center_dist - clamp(center_dist, -region_range, region_range)) * scale + 0.5;

    return texel_idx + interp_weight;
}


COMPAT_PRECISION vec3 color_correction(COMPAT_PRECISION vec3 color)
{
    color *= vColorMult;

    COMPAT_PRECISION float luminance = dot(color, vec3(0.2124, 0.7011, 0.0866));
    color = mix(vec3(luminance), color, S_SATURATION);
    color *= mix(S_DARK_BOOST, S_BRIGHT_BOOST, luminance);
    color = (color - 0.5) * S_CONTRAST + 0.5;
    color = (color - vAdjustedBlack) * vBlackScale;

    return pow(clamp(color, 0.0, 1.0), vec3(vGammaRatio));
}


void main()
{
    COMPAT_PRECISION vec2 mod_texel = sharp_bilinear_scaling(vTexel, vScale, vRegionRange);
    FragColor = vec4(color_correction(COMPAT_TEXTURE(Texture, mod_texel * SourceSize.zw).rgb), 1.0);
}


#endif
