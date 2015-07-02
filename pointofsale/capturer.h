#ifndef CAPTURER_H
#define CAPTURER_H

#include <QObject>
#include <QQuickItem>

class Capturer : public QObject
{
  Q_OBJECT
public:
  explicit Capturer(QObject *parent = 0);
  Q_INVOKABLE void save(QQuickItem *obj);
};

#endif // CAPTURER_H
