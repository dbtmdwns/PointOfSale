#include "escimage.h"

ESCPOSImage::ESCPOSImage(const QImage & image) {
    // Set up x and y as pr. epson manual
    m_width = image.width();
    m_height = image.height();

    m_gs_x = m_width / 8 + (m_width % 8 != 0?1:0);
    m_gs_y = m_height / 8 + (m_height % 8 != 0?1:0);

     if ( m_gs_x > 255 || m_gs_y > 255 ) {
        // You may want to write an error message here
        throw "Too large on dimension";
    }

    m_gs_k = m_gs_x * m_gs_y * 8;
    // Bit unsure about this limit. It depends on the actual printer....
    if ( m_gs_k > (3072*8) ) {
        // You may want to write an error message here
        throw "Too large on area";
    }

    vector<char> bytes( m_gs_k, 0 ); // Blank all bytes.
    m_bytes = bytes;

    // Iterate over the image, turn on any pixels that are set in the monochromo image.
    for ( int i_y = 0; i_y < m_height; ++i_y ) {
        for ( int i_x = 0; i_x < m_width; ++i_x ) {
            if ( image.pixelIndex( i_x, i_y ) == Qt::color1 ) {
                setPixel( i_x, i_y );
            }
        }
    }
}

/*
// Access internal representation. Should be const something, I guess.
vector<unsigned char>& ESCPOSImage::getBytes() {

  ESCPOSImage posImage( monoImage );
  QByteArray ar = posImage.getGSStar();
  for ( int i = 0; i < ar.size(); ++i ) {
      cout << (unsigned char) ar[i];
  }
  cout << "\n"; // This may not be needed, actually.

  // Do a GS / to actually output the bitmap.
  cout << (unsigned char) 29 << "/" << (unsigned char) 0 << "\n";

    return m_bytes;
}
*/


void ESCPOSImage::setPixel( int x, int y ) {
    size_t byte_index = x * m_gs_y + y / 8;
    int bit_no = y % 8;
    // Swap msb/lsb order. This probably only works on machines with "normal" endianess.....
    unsigned char bit = 1 << ( 7 - bit_no );
    m_bytes.at( byte_index ) = m_bytes.at( byte_index ) | bit;
}

// Bytes suitable to send to the printer to define the bitmap.
QByteArray ESCPOSImage::getGSStar() {
    QByteArray res( m_bytes.size() + 4, 0 );
    res.append((char) 29 );
    res.append( '*' );
    res.append( (char) m_gs_x );
    res.append( (char) m_gs_y );
    for ( size_t i = 0; i < m_bytes.size(); ++i ) {
      res.append( m_bytes.at( i ) ) ;
    }
    return res;
};
