PNG to Direct Color Mode for Megadrive/Genesis
===============================================

It is possible to display all of the internal 512 colors on the Megadrive via the use of the Direct Color mode
that Chilly willy provided examples for in 2012.

He also released it with a BMP tool but it required a specific way of converting the bmp file (RGB555 and then the tool further converted that down to 512 colors).
This tool directly converts from PNG instead.

An example for use with SGDK is also provided.
GPL files are provided for use with Krita, as it's the only GUI drawing program that supports palettes larger than 256 colors.

Usage
=====
```
make
````

Then
```
pngtodirectcolor.elf input.png output.bin
```


TODO
====

- Look into 1407 color mode (512 + S/H)
