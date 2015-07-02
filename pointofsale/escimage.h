#ifndef ESCIMAGE_H
#define ESCIMAGE_H
// C++
#include <iostream>
#include <iomanip>
#include <vector>

// Qt
#include <QCoreApplication>
#include <QImage>

using namespace std;

class ESCPOSImage {
  private:
      int m_width;
      int m_height;
      int m_gs_x;
      int m_gs_y;
      int m_gs_k;
      // Actual bytes for image - could have used QByteArray for this, I guess.
      vector<char> m_bytes;

      // This turns on a pixel a position x, y as you would expect.
      // The bytes in the bitmap is stored in a weird "y first", "x second" order.
      // The bit fiddling here takes care of it.
      void setPixel( int x, int y );

  public:
    explicit ESCPOSImage(const QImage & image);
    // Bytes suitable to send to the printer to define the bitmap.
    QByteArray getGSStar();
};

#endif // ESCIMAGE_H
