/* MIT LICENSE - Gameblabla */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <png.h>

unsigned short buffer[198*240];

static unsigned short swap(unsigned short val)
{
    return (val>>8) | (val<<8);
}


int main(int argc, char **argv) {
    FILE *fp;
    png_structp png_ptr;
    png_infop info_ptr;
    png_uint_32 width, height;
    int bit_depth, color_type, interlace_type;
    
    if (argc < 3)
    {
		printf("input output\n");
		return 0;
	}

    // Open file
    fp = fopen(argv[1], "rb");
    if (fp == NULL) return 1;

    // Create and initialize the png_struct
    png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (png_ptr == NULL) {
        fclose(fp);
        return 1;
    }

    // Allocate/initialize the memory for image information.
    info_ptr = png_create_info_struct(png_ptr);
    if (info_ptr == NULL) {
        fclose(fp);
        png_destroy_read_struct(&png_ptr, NULL, NULL);
        return 1;
    }

    // Set up error handling
    if (setjmp(png_jmpbuf(png_ptr))) {
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fclose(fp);
        return 1;
    }

    // Set up the input control
    png_init_io(png_ptr, fp);

    // Read PNG file info
    png_read_info(png_ptr, info_ptr);
    png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, &interlace_type, NULL, NULL);
    
	printf("width %d\n", width);
    printf("height %d\n", height);

    // Convert PNG data to RGB555 and then to RGB9 as needed
    // Ensure we are dealing with an RGB or RGBA file
    if (color_type != PNG_COLOR_TYPE_RGB && color_type != PNG_COLOR_TYPE_RGBA) {
        fprintf(stderr, "Unsupported PNG color type. Only RGB and RGBA are supported.\n");
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fclose(fp);
        return 1;
    }

    // If the image has an alpha channel, strip it
    if (color_type == PNG_COLOR_TYPE_RGBA) {
        png_set_strip_alpha(png_ptr);
    }

    // Update the png info struct after any transformations
    png_read_update_info(png_ptr, info_ptr);

    // Allocate memory for reading the PNG data into
    png_bytep row_pointers[height];
    for (int y = 0; y < height; y++) {
        row_pointers[y] = (png_byte *) malloc(png_get_rowbytes(png_ptr, info_ptr));
    }

    // Read the image data
    png_read_image(png_ptr, row_pointers);

    // Process each pixel and convert to RGB9
    for (int y = 0; y < height; y++) {
        png_bytep row = row_pointers[y];
        for (int x = 0; x < width; x++) {
            png_bytep px = &(row[x * 3]); // 3 bytes per pixel for RGB

            unsigned short r = px[0] >> 4; // Extract and scale red component
            unsigned short g = px[1] >> 4; // Extract and scale green component
            unsigned short b = px[2] >> 4; // Extract and scale blue component

            unsigned short rgb9 = (b << 8) | (g << 4) | r;
            buffer[y * width + x] = swap(rgb9); // swap to big endian
        }
    }

    // Free the row pointers
    for (int y = 0; y < height; y++) {
        free(row_pointers[y]);
    }

    // Clean up
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(fp);
    
    // Example of writing buffer to a file (add your own file writing code)
    FILE *output_fp = fopen(argv[2], "wb");
    if (output_fp == NULL) {
        fprintf(stderr, "Error: Unable to open output file for writing\n");
        return 1;
    }

	int totalsize = width * height;

    size_t written = fwrite(buffer, sizeof(unsigned short), totalsize, output_fp);
    if (written < totalsize) {
        fprintf(stderr, "Error: Failed to write the complete buffer to file\n");
    }
    fclose(output_fp);

    return 0;
}
