#ifndef POSPRINTER_H
#define POSPRINTER_H

#include <QObject>
//#include <QtWebKitWidgets/QWebView>

class PosPrinter : public QObject
{
    Q_OBJECT
public:
    explicit PosPrinter(QObject *parent = 0);
    Q_INVOKABLE void allPrinters();
    Q_INVOKABLE void print(QString htmlContent);
    Q_INVOKABLE QString readLogoFile();
    Q_INVOKABLE void openDrawer();
    Q_INVOKABLE void cut();
    Q_INVOKABLE QString getEnv(QString name,QString defaultvalue);
    Q_INVOKABLE QString readFile(QString path);

    Q_INVOKABLE bool sendImageToPrinter(QString printerName, QString imageName);
    Q_INVOKABLE void setup(int res,double width,double height);

    bool sendToPrinter(QString printerName,QString data);


    Q_INVOKABLE void systemPrintFile(QString printer, QString filename, QString height, double ws, double hs,int x, int y);
    Q_INVOKABLE void printFile(QString printer, QString filename, QString height);
    Q_INVOKABLE void cut(QString printer);
    Q_INVOKABLE void open(QString printer);

    QString osName();
signals:

public slots:

private:
  int printerResolution;
  double paperHeight;
  double paperWidth;
};

#endif // POSPRINTER_H
