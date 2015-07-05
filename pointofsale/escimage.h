#ifndef ESCIMAGE_H
#define ESCIMAGE_H
// C++
#include <iostream>
#include <iomanip>
#include <vector>

// Qt
#include <QImage>

using namespace std;

class ESCPOSImage : public QObject
{
    Q_OBJECT
public:
    explicit ESCPOSImage(QObject *parent = 0);
    void saveImage(QImage *img, QString fname, QString imageHeight);
};

#endif // ESCIMAGE_H
