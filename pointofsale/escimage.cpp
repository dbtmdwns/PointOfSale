/*
This file contains source code parts form https://github.com/petrkutalek/png2pos
modified to work with QImage instead of loadpng.

(c) 2012 - 2015 Petr Kutalek: png2pos

Licensed under the MIT License:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#include "escimage.h"



// ESC sequences
#define ESC_INIT_LENGTH 2
const unsigned char ESC_INIT[ESC_INIT_LENGTH] = {
    // ESC @, Initialize printer, p. 412
    0x1b, 0x40
};

#define ESC_CUT_LENGTH 4
const unsigned char ESC_CUT[ESC_CUT_LENGTH] = {
    // GS V, Sub-Function B, p. 373
    0x1d, 0x56, 0x41,
    // Feeds paper to (cutting position + n × vertical motion unit)
    // and executes a full cut (cuts the paper completely)
    // The vertical motion unit is specified by GS P.
    0x40
};

#define ESC_OFFSET_LENGTH 4
unsigned char ESC_OFFSET[ESC_OFFSET_LENGTH] = {
    // GS L, Set left margin, p. 169
    0x1d, 0x4c,
    // nl, nh
    0x00, 0x00
};

#define ESC_STORE_LENGTH 17
unsigned char ESC_STORE[ESC_STORE_LENGTH] = {
    // GS 8 L, Store the graphics data in the print buffer (raster format), p. 252
    0x1d, 0x38, 0x4c,
    // p1 p2 p3 p4
    0x0b, 0x00, 0x00, 0x00,
    // Function 112
    0x30, 0x70, 0x30,
    // bx by, zoom
    0x01, 0x01,
    // c, single-color printing model
    0x31,
    // xl, xh, number of dots in the horizontal direction
    0x00, 0x00,
    // yl, yh, number of dots in the vertical direction
    0x00, 0x00
};

#define ESC_FLUSH_LENGTH 7
const unsigned char ESC_FLUSH[ESC_FLUSH_LENGTH] = {
    // GS ( L, Print the graphics data in the print buffer, p. 241
    // Moves print position to the left side of the print area after
    // printing of graphics data is completed
    0x1d, 0x28, 0x4c, 0x02, 0x00, 0x30,
    // Fn 50
    0x32
};

// number of dots/lines in vertical direction in one F112 command
// set to <= 128u for Epson TM-J2000/J2100
#ifndef GS8L_MAX_Y
#define GS8L_MAX_Y 384u
#endif

// max image width printer is able to process
#ifndef PRINTER_MAX_WIDTH
#define PRINTER_MAX_WIDTH 512u
#endif

// app configuration
struct {
    unsigned int cut;
    unsigned int photo;
    unsigned int maxImageHeight;
    char align;
    unsigned int rotate;
    const char *output;
    unsigned int threshold;
    unsigned int gs8l_max_y;
    unsigned int printer_max_width;
} config = {
    .cut = 0,
    .photo = 0,
    .maxImageHeight = 15000,
    .align = '?',
    .rotate = 0,
    .output = NULL,
    .threshold = 0x80,
    .gs8l_max_y = GS8L_MAX_Y,
    .printer_max_width = PRINTER_MAX_WIDTH
};

// Gamma 2.2 lookup table
const unsigned char GAMMA_22[256] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02,
    0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05, 0x05, 0x06,
    0x06, 0x06, 0x07, 0x07, 0x07, 0x08, 0x08, 0x08, 0x09, 0x09, 0x09, 0x0a, 0x0a, 0x0a, 0x0b, 0x0b,
    0x0c, 0x0c, 0x0d, 0x0d, 0x0d, 0x0e, 0x0e, 0x0f, 0x0f, 0x10, 0x10, 0x11, 0x11, 0x12, 0x12, 0x13,
    0x13, 0x14, 0x15, 0x15, 0x16, 0x16, 0x17, 0x17, 0x18, 0x19, 0x19, 0x1a, 0x1b, 0x1b, 0x1c, 0x1d,
    0x1d, 0x1e, 0x1f, 0x1f, 0x20, 0x21, 0x21, 0x22, 0x23, 0x24, 0x24, 0x25, 0x26, 0x27, 0x28, 0x28,
    0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
    0x48, 0x49, 0x4a, 0x4b, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x54, 0x55, 0x56, 0x57, 0x58, 0x5a,
    0x5b, 0x5c, 0x5d, 0x5f, 0x60, 0x61, 0x63, 0x64, 0x65, 0x67, 0x68, 0x69, 0x6b, 0x6c, 0x6d, 0x6f,
    0x70, 0x72, 0x73, 0x75, 0x76, 0x77, 0x79, 0x7a, 0x7c, 0x7d, 0x7f, 0x80, 0x82, 0x83, 0x85, 0x87,
    0x88, 0x8a, 0x8b, 0x8d, 0x8e, 0x90, 0x92, 0x93, 0x95, 0x97, 0x98, 0x9a, 0x9c, 0x9d, 0x9f, 0xa1,
    0xa2, 0xa4, 0xa6, 0xa8, 0xa9, 0xab, 0xad, 0xaf, 0xb0, 0xb2, 0xb4, 0xb6, 0xb8, 0xba, 0xbb, 0xbd,
    0xbf, 0xc1, 0xc3, 0xc5, 0xc7, 0xc9, 0xcb, 0xcd, 0xcf, 0xd1, 0xd3, 0xd5, 0xd7, 0xd9, 0xdb, 0xdd,
    0xdf, 0xe1, 0xe3, 0xe5, 0xe7, 0xe9, 0xeb, 0xed, 0xef, 0xf1, 0xf4, 0xf6, 0xf8, 0xfa, 0xfc, 0xff
};

// Lightness lookup table
const unsigned char LIGHTNESS[256] = {
    0x00, 0x05, 0x11, 0x1a, 0x21, 0x26, 0x2b, 0x30, 0x34, 0x38, 0x3b, 0x3e, 0x41, 0x44, 0x47, 0x4a,
    0x4c, 0x4f, 0x51, 0x53, 0x55, 0x57, 0x59, 0x5b, 0x5d, 0x5f, 0x61, 0x63, 0x64, 0x66, 0x68, 0x69,
    0x6b, 0x6c, 0x6e, 0x6f, 0x71, 0x72, 0x74, 0x75, 0x76, 0x78, 0x79, 0x7a, 0x7b, 0x7d, 0x7e, 0x7f,
    0x80, 0x81, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90,
    0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
    0xa0, 0xa1, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xa9, 0xaa, 0xab, 0xac,
    0xac, 0xad, 0xae, 0xae, 0xaf, 0xb0, 0xb1, 0xb1, 0xb2, 0xb3, 0xb3, 0xb4, 0xb5, 0xb6, 0xb6, 0xb7,
    0xb8, 0xb8, 0xb9, 0xba, 0xba, 0xbb, 0xbb, 0xbc, 0xbd, 0xbd, 0xbe, 0xbf, 0xbf, 0xc0, 0xc1, 0xc1,
    0xc2, 0xc2, 0xc3, 0xc4, 0xc4, 0xc5, 0xc5, 0xc6, 0xc7, 0xc7, 0xc8, 0xc8, 0xc9, 0xc9, 0xca, 0xcb,
    0xcb, 0xcc, 0xcc, 0xcd, 0xcd, 0xce, 0xcf, 0xcf, 0xd0, 0xd0, 0xd1, 0xd1, 0xd2, 0xd2, 0xd3, 0xd3,
    0xd4, 0xd4, 0xd5, 0xd6, 0xd6, 0xd7, 0xd7, 0xd8, 0xd8, 0xd9, 0xd9, 0xda, 0xda, 0xdb, 0xdb, 0xdc,
    0xdc, 0xdd, 0xdd, 0xde, 0xde, 0xdf, 0xdf, 0xe0, 0xe0, 0xe0, 0xe1, 0xe1, 0xe2, 0xe2, 0xe3, 0xe3,
    0xe4, 0xe4, 0xe5, 0xe5, 0xe6, 0xe6, 0xe7, 0xe7, 0xe7, 0xe8, 0xe8, 0xe9, 0xe9, 0xea, 0xea, 0xeb,
    0xeb, 0xec, 0xec, 0xec, 0xed, 0xed, 0xee, 0xee, 0xef, 0xef, 0xef, 0xf0, 0xf0, 0xf1, 0xf1, 0xf2,
    0xf2, 0xf2, 0xf3, 0xf3, 0xf4, 0xf4, 0xf4, 0xf5, 0xf5, 0xf6, 0xf6, 0xf7, 0xf7, 0xf7, 0xf8, 0xf8,
    0xf9, 0xf9, 0xf9, 0xfa, 0xfa, 0xfb, 0xfb, 0xfb, 0xfc, 0xfc, 0xfd, 0xfd, 0xfd, 0xfe, 0xfe, 0xff
};


ESCPOSImage::ESCPOSImage(QObject *parent) :
    QObject(parent)
{

}

inline int rebound(const int value, const int min, const int max) {
    int a = value;
    if (a > max) {
        a = max;
    }
    else if (a < min) {
        a = min;
    }
    return a;
}

void print(FILE *stream, const unsigned char *buffer, const size_t length) {
  for (unsigned int i = 0; i != length; ++i) {
    fputc(buffer[i], stream);
  }
}



void ESCPOSImage::saveImage(QImage *img, QString fname, QString imageHeight){
  FILE *fout = NULL;

  unsigned char *img_rgba = img->bits();
  unsigned char *img_grey = NULL;
  unsigned char *img_bw = NULL;

  int optc = -1;

  config.maxImageHeight = atoi(imageHeight.toLocal8Bit().data());
  config.output = fname.toLocal8Bit().data();

  // open output file and disable line buffering
  if (!config.output || !strcmp(config.output, "-")) {
      fout = stdout;
  } else {
      fout = fopen(config.output, "wb");
      if (!fout) {
          fprintf(stderr, "Could not open output file '%s'\n", config.output);
          return ;
      }
  }


  if (setvbuf(fout, NULL, _IOFBF, 8192)) {
      fprintf(stderr, "Could not set new buffer policy on output stream\n");
  }

  // init printer
  print(fout, ESC_INIT, ESC_INIT_LENGTH);
  fflush(fout);

  // for each input file

  // load RGBA PNG
  unsigned int img_w = img->width();
  unsigned int img_h = img->height();
  //unsigned int lodepng_error = lodepng_decode32_file(&img_rgba, &img_w, &img_h, input);

  if (img_h>config.maxImageHeight){
    img_h = config.maxImageHeight;

  }


  if (img_w > config.printer_max_width) {
      fprintf(stderr, "Image width %u px exceeds the printer's capability (%u px)\n", img_w, config.printer_max_width);
      return ;
  }

  unsigned int histogram[256] = { 0 };

  // convert RGBA to greyscale
  const unsigned int img_grey_size = img_h * img_w;
  img_grey = (unsigned char *)calloc(img_grey_size, 1);
  if (!img_grey) {
      fprintf(stderr, "Could not allocate enough memory\n");
      return ;
  }

  for (unsigned int i = 0; i != img_grey_size; ++i) {
      // A
      const unsigned int a = img_rgba[(i << 2) | 3];
      // RGBA → RGB
      const unsigned int r = (255 - a) + a / 255 * img_rgba[i << 2];
      const unsigned int g = (255 - a) + a / 255 * img_rgba[(i << 2) | 1];
      const unsigned int b = (255 - a) + a / 255 * img_rgba[(i << 2) | 2];
      // RGB → R'G'B'
      const unsigned int r_ = GAMMA_22[r];
      const unsigned int g_ = GAMMA_22[g];
      const unsigned int b_ = GAMMA_22[b];
      // R'G'B' → luma Y' (!= luminance), ITU-R: BT.709
      const unsigned int y_ = (55 * r_ + 182 * g_ + 18 * b_) / 255;
      // Y' → lightness L*
      img_grey[i] = LIGHTNESS[y_];

      // prepare a histogram for HEA
      ++histogram[img_grey[i]];
  }

  //free(img_rgba), img_rgba = NULL;

  {
      // -p hints
      unsigned int colors = 0;
      for (unsigned int i = 0; i != 256; ++i) {
          if (histogram[i]) {
              ++colors;
          }
      }
      if (colors < 16 && config.photo) {
          fprintf(stderr, "Image seems to be B/W. -p is probably not good option this time\n");
      }
      if (colors >= 16 && !config.photo) {
          fprintf(stderr, "Image seems to be greyscale or colored. Maybe you should use options -p and -t for better results\n");
      }
  }

  // post-processing
  // convert to B/W bitmap
  if (config.photo) {
    // Histogram Equalization Algorithm
    for (unsigned int i = 1; i != 256; ++i) {
        histogram[i] += histogram[i - 1];
    }
    for (unsigned int i = 0; i != img_grey_size; ++i) {
        img_grey[i] = 255 * histogram[img_grey[i]] / img_grey_size;
    }
    config.threshold = 255 * histogram[config.threshold] / img_grey_size;
    fprintf(stderr, "Threshold shift, new value = %d\n", config.threshold);

    // http://www.tannerhelland.com/4660/dithering-eleven-algorithms-source-code/
    // One of the best dithering algorithms from mid-1980's was developed by Bill Atkinson,
    // a Apple employee who worked on everything from MacPaint (which he wrote from scratch
    // for the original Macintosh) to HyperCard and QuickDraw.
    // Atkinson’s formula is a bit different from others, because it only propagates
    // a fraction of the error instead of the full amount. This technique is sometimes offered
    // by modern graphics applications as a “reduced color bleed” option. By only propagating part
    // of the error, speckling is reduced, but contiguous dark or bright sections of an image may
    // become washed out.

    // Atkinson Dithering Algorithm
    #define DITHERING_MATRIX_SIZE 6
    const struct {
        int dx;
        int dy;
        // for simplicity of computation, all standard dithering formulas
        // push the error forward, never backward
    } dithering_matrix[DITHERING_MATRIX_SIZE] = {
        { .dx =  1, .dy = 0 },
        { .dx =  2, .dy = 0 },
        { .dx = -1, .dy = 1 },
        { .dx =  0, .dy = 1 },
        { .dx =  1, .dy = 1 },
        { .dx =  0, .dy = 2 }
    };
    for (unsigned int i = 0; i != img_grey_size; ++i) {
        const unsigned int o = img_grey[i];
        const unsigned int n = o <= config.threshold ? 0x00 : 0xff;
        // the residual quantization error
        const int d = (int)(o - n) / 8;
        img_grey[i] = n;
        const unsigned int x = i % img_w;
        const unsigned int y = i / img_w;

        for (unsigned int j = 0; j != DITHERING_MATRIX_SIZE; ++j) {
            const int x0 = x + dithering_matrix[j].dx;
            const int y0 = y + dithering_matrix[j].dy;
            if (x0 >= img_w || x0 < 0 || y0 >= img_h) {
                continue;
            }
            img_grey[x0 + img_w * y0] = rebound(img_grey[x0 + img_w * y0] + d, 0x00, 0xff);
        }
    }
  }

  // canvas size is width of a picture rounded up to nearest multiple of 8
  const unsigned int canvas_w = (img_w + 7) & ~0x7u;

  const unsigned int img_bw_size = img_h * (canvas_w >> 3);
  img_bw = (unsigned char *)calloc(img_bw_size, 1);
  if (!img_bw) {
      fprintf(stderr, "Could not allocate enough memory\n");
      return ;
  }

  // align rotated image to the right border
  if (config.rotate && config.align == '?') {
      config.align = 'R';
  }

  // compress bytes into bitmap
  for (unsigned int i = 0; i != img_grey_size; ++i) {
      const unsigned int idx = !config.rotate ? i : (img_grey_size - 1) - i;
      if (img_grey[idx] <= config.threshold) {
          const unsigned int x = i % img_w;
          const unsigned int y = i / img_w;
          img_bw[(y * canvas_w + x) >> 3] |= 0x80 >> (x & 0x07);
      }
  }

  free(img_grey), img_grey = NULL;

  // left offset
  int offset = 0;
  switch (config.align) {
      case 'C':
          offset = (config.printer_max_width - canvas_w) / 2;
          break;

      case 'R':
          offset = config.printer_max_width - canvas_w;
          break;

      case 'L':
      case '?':
      default:
          offset = 0;
  }

  if (offset < 0) {
      offset = 0;
  }

  // offset have to be a multiple of 8
  offset &= ~0x7u;

  // chunking, l = lines already printed, currently processing a chunk of height k
  for (unsigned int l = 0, k = config.gs8l_max_y; l < img_h; l += k) {
      if (k > img_h - l) {
          k = img_h - l;
      }

      if (offset) {
          ESC_OFFSET[2] = offset & 0xff;
          ESC_OFFSET[3] = offset >> 8 & 0xff;
          print(fout, ESC_OFFSET, ESC_OFFSET_LENGTH);
      }

      const unsigned int f112_p = 10 + k * (canvas_w >> 3);
      ESC_STORE[ 3] = f112_p & 0xff;
      ESC_STORE[ 4] = f112_p >> 8 & 0xff;
      ESC_STORE[13] = canvas_w & 0xff;
      ESC_STORE[14] = canvas_w >> 8 & 0xff;
      ESC_STORE[15] = k & 0xff;
      ESC_STORE[16] = k >> 8 & 0xff;

      print(fout, ESC_STORE, ESC_STORE_LENGTH);
      print(fout, &img_bw[l * (canvas_w >> 3)], k * (canvas_w >> 3));
      print(fout, ESC_FLUSH, ESC_FLUSH_LENGTH);
      fflush(fout);
  }

  free(img_bw), img_bw = NULL;

  if (config.cut) {
      // cut the paper
      print(fout, ESC_CUT, ESC_CUT_LENGTH);
      fflush(fout);
  }



}
