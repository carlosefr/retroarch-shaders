# Carlos' custom CRT shader presets for RetroArch

This repository contains a set of custom CRT shader presets for [RetroArch](https://www.retroarch.com/) based on its [glsl-shaders](https://github.com/libretro/glsl-shaders). These presets are meant to look reasonable on resolutions slightly below 1080p and have good performance on weak graphics cards — I'm using them with an [ATI Mobility Radeon HD 2600](https://en.wikipedia.org/wiki/Radeon_HD_2000_series) from **2008** driving a 1680x1050 LCD screen.


* **crt-tv** &ndash; subtle scanlines and a Sony Trinitron-like mask (aperture grille);
* **crt-tv-slotmask** &ndash; same as `crt-tv`, but with a slot mask instead (most non-Sony TVs);
* **crt-tv-monitor** &ndash; same as `crt-tv-slotmask`, but sharper;
* **crt-tv-slotmask-mixed** &ndash; same as `crt-tv-slotmask` but approximating slower phosphor decay;
* **crt-scanlines** &ndash; pronounced scanlines, with no discernible mask;
* **crt-mask** &ndash; pronounced scanlines and shadow mask (slightly harsher look than `crt-scanlines`);
* **crt-mask-horizontal** &ndash; pronounced scanlines and a bit blurry (like a worn CRT);
* **crt-mask-vertical** &ndash; same as `crt-mask-horizontal` but for vertical (arcade) games;
* **crt-ega-newer** &ndash; pronounced scanlines and subtle mask, mimicking EGA monitors;
* **crt-ega-older** &ndash; same as `crt-ega-newer` but slightly more blurry;
* **crt-vga-newer** &ndash; barely any scanlines and subtle mask;
* **crt-vga-older** &ndash; same as `crt-vga-newer` but slightly more blurry;
* **crt-vga-alternate** &ndash; similar to `crt-vga-newer` with added sharp-bilinear filtering.

I've found that `crt-tv-slotmask` or `crt-tv` works best for consoles, but I tend to prefer `crt-scanlines` for most arcade games. I know it's less accurate, because CRTs in arcade cabinets (like any color CRT) also had shadow masks, but fits better with my subjective memories somehow.

The `crt-tv-slotmask-mixed` preset is sometimes useful for demos with effects that depend on a CRT's phospor persistence to blend fast switching colors, like [Mescaline Synesthesia](https://www.pouet.net/prod.php?which=54207) for the ZX Spectrum.

The `crt-ega-*` presets are meant to be used with an MS-DOS emulator that can do single-scan (like [DOSBox Pure](https://github.com/schellingb/dosbox-pure)), otherwise the scanlines won't be realistic at all. In VGA low-res graphics modes (e.g. 320x200) each row of pixels is drawn as two consecutive scanlines (double-scan), but not in EGA. In real EGA monitors the scanlines were very visible, while in VGA monitors they weren't.

Both the EGA and VGA presets approximate a slot mask which, truth be told, isn't very realistic upon close inspection but still provides reasonable texture from a distance. In reality, PC monitor shadow masks mostly used [triads](https://en.wikipedia.org/wiki/Shadow_mask#/media/File:CRT_pixel_array.jpg) (circular dots in a triangular arrangement), but I haven't yet found a shader that simulates this and fulfills my performance and resolution requirements.


### Composite Output

In the `composite` directory there are a couple more presets that may be useful when using an actual CRT fed by the composite video output of a Raspberry Pi. These (of course) don't attempt to simulate a CRT, they merely adjust the image slightly:

* **composite** &ndash; sharp-bilinear filtering and gamma adjustment;
* **composite-mixed** &ndash; sharp-bilinear filtering, approximating a slower phosphor.

You may be wondering why sharp-bilinear filtering is necessary, but consider that the emulated system isn't driving the CRT's electron beam directly, therefore the game's resolution probably doesn't match the Raspberry Pi's output resolution. For example, a Mega Drive game at 320x224 with the Pi outputting 720x480i. The sharp-bilinear filter makes the pixels uniformly sized while minimizing blur.

Also, you may wonder why it's necessary to approximate a slower phosphor. Again, because the emulated system isn't driving the CRT, it may be expecting a progressive scan output when the Pi is actually doing interlaced output. With interlacing the scanlines of successive frames don't blend together because the scanlines of the next frame are drawn in the empty space between the scanlines of the previous frame.

For these and other reasons, emulation on a Raspberry Pi with composite output to a CRT isn't an accurate reproduction of the orignal hardware. Though, in practice, it's often close enough.


## Install

Clone this repository into a subdirectory of RetroArch's shader directory, like this:

```
cd /opt/retropie/configs/all/retroarch/shaders
git clone https://github.com/carlosefr/retroarch-shaders.git custom
```

The new presets will appear in RetroArch's `Shaders / Load Preset` menu under the `custom` folder. You can name it something other than "custom" if you prefer.


## Examples

Click the following images to see them at their full 1680x1050 size:

[In the Hunt](https://www.mobygames.com/game/24351/in-the-hunt/) and [Puzzle Bobble](https://www.mobygames.com/game/80773/bust-a-move/) for the arcade running in [lr-fbneo](https://github.com/libretro/FBNeo) with the `crt-scanlines` preset:

<img src="screenshots/inthunt-crt-scanlines.png" alt="crt-scanlines" width="400"/>&nbsp;&nbsp;<img src="screenshots/pbobblen-crt-scanlines.png" alt="crt-scanlines" width="400"/>

The same two games, but using `crt-mask` instead:

<img src="screenshots/inthunt-crt-mask.png" alt="crt-mask" width="400"/>&nbsp;&nbsp;<img src="screenshots/pbobblen-crt-mask.png" alt="crt-mask" width="400"/>

[Zanac Neo](https://www.mobygames.com/game/22778/zanac-x-zanac/) for the PS1 running in [lr-pcsx-rearmed](https://github.com/libretro/pcsx_rearmed), and [Sonic the Hedgehog](https://www.mobygames.com/game/6579/sonic-the-hedgehog/) for the Mega Drive running in [lr-genesis-plus-gx](https://github.com/libretro/Genesis-Plus-GX), with the `crt-tv` preset:

<img src="screenshots/zanacneo-crt-tv.png" alt="crt-tv" width="400"/>&nbsp;&nbsp;<img src="screenshots/sonic-crt-tv.png" alt="crt-tv" width="400"/>

[Aliens: Neoplasma II](https://sinc-lair.itch.io/aliens-neoplasma-2) for the ZX Spectrum running in [lr-fuse](https://github.com/libretro/fuse-libretro), and [Super Mario Bros.](https://www.mobygames.com/game/7298/super-mario-bros/) for the NES running in [lr-fceumm](https://github.com/libretro/libretro-fceumm), with the `crt-tv-slotmask` preset:

<img src="screenshots/aliens-crt-tv-slotmask.png" alt="crt-tv-slotmask" width="400"/>&nbsp;&nbsp;<img src="screenshots/mario-crt-tv-slotmask.png" alt="crt-tv-slotmask" width="400"/>

[Crystal Caves](https://www.mobygames.com/game/953/crystal-caves/) and [Prince of Persia](https://www.mobygames.com/game/196/prince-of-persia/) for MS-DOS, both running in [lr-dosbox-pure](https://github.com/schellingb/dosbox-pure) with the `crt-ega-newer` and `crt-vga-newer` presets respectively:

<img src="screenshots/crystal-crt-ega-newer.png" alt="crt-ega-newer" width="400"/>&nbsp;&nbsp;<img src="screenshots/pop-crt-vga-newer.png" alt="crt-vga-newer" width="400"/>
