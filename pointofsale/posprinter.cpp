#include "posprinter.h"
#include <QPrinterInfo>
#include <QDebug>
#include <QPainter>
#include <QFont>
#include <QDir>
#include <QPrinter>
#include <QTextDocument>
//#include <QtWebKitWidgets/QWebView>
//#include <QtWebKitWidgets/QWebFrame>

#include <QFile>
#include <QPainter>
#include <QPaintEngine>
#include <QProcessEnvironment>
#include <QTimer>


#include <QFile>
#include <QByteArray>
#include <QImage>


#if defined(_WIN32)
    #include <windows.h>
    #include <winspool.h>
#endif

#include "escimage.h"

PosPrinter::PosPrinter(QObject *parent) :
    QObject(parent)
{

}

QString PosPrinter::getEnv(QString name,QString defaultvalue){
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    return env.value(name,defaultvalue);
}

QString PosPrinter::osName()
{
#if defined(Q_OS_ANDROID)
   return QLatin1String("android");
#elif defined(Q_OS_BLACKBERRY)
   return QLatin1String("blackberry");
#elif defined(Q_OS_IOS)
   return QLatin1String("ios");
#elif defined(Q_OS_MAC)
   return QLatin1String("osx");
#elif defined(Q_OS_WINCE)
   return QLatin1String("wince");
#elif defined(Q_OS_WIN)
   return QLatin1String("windows");
#elif defined(Q_OS_LINUX)
   return QLatin1String("linux");
#elif defined(Q_OS_UNIX)
   return QLatin1String("unix");
#else
   return QLatin1String("unknown");
#endif
}

void PosPrinter::cut(){
    QPrinter printer(QPrinter::HighResolution);

    if(osName().compare("windows")==0){
        QStringList codes = getEnv("POSCUT","10,27,109").split(",");
        int codes_i;
        QString data = "";
        for(codes_i=0;codes_i<codes.count();codes_i++){
            data.append(QChar(codes.at(codes_i).toInt()));
        }


        qDebug() << "Sending " << data;
        if (sendToPrinter(printer.printerName(), data)){
            qDebug() << "Data was send successfully";

        }else{
            qDebug() << "There was an error";
        }
    }else{
        QPainter painter(&printer); // create a painter which will paint 'on printer'.
        painter.setFont(QFont("control",10));
        QString s = QString(" \n \n \n").toLocal8Bit();
        painter.drawText(0,0,s);
        painter.end();
    }
}

void PosPrinter::openDrawer(){
     QPrinter printer(QPrinter::ScreenResolution);

     if(osName().compare("windows")==0){
         QStringList codes = getEnv("POSOPENDRAWER","27,112,48,55,121").split(",");
         int codes_i;
         QString data = "";
         for(codes_i=0;codes_i<codes.count();codes_i++){
             data.append(QChar(codes.at(codes_i).toInt()));
         }
         qDebug() << "Sending " << data;
         if (sendToPrinter(printer.printerName(), data)){
             qDebug() << "Data was send successfully";

         }else{
             qDebug() << "There was an error";
         }
     }else{

        QPainter painter(&printer); // create a painter which will paint 'on printer'.
        painter.setFont(QFont("control",10));
        QString s = QString("\n \n \n").toLocal8Bit();
        painter.drawText(0,0,s);
        painter.end();

    }
}

bool PosPrinter::sendImageToPrinter(QString printerName, QString imageName){
  /*
  QByteArray ar;


  QImage image(imageName);
  ESCPOSImage posImage( image );
  ar.append(posImage.getGSStar());
  ar.append((char) 29);
  ar.append('/');
  ar.append((char) 0);

  QFile file("x.prn");
  file.open(QIODevice::WriteOnly);
  file.write(ar);
  file.close();
  return true;
  */
  /*
  char escp_seq[BYTES_FOR_SEQUENCE];

// ...initialize the ESC/P sequence.

int printer_fd = open("/dev/lp0", O_WRONLY);
ssize_t bytes_written = write(printer_fd, escp_seq, sizeof(escp_seq));
close(printer_fd);
  */
}

bool PosPrinter::sendToPrinter(QString printerName, QString data){
#if defined(_WIN32)
    // Windows
    HANDLE hPrinter;
    DOC_INFO_1A DocInfo;
    DWORD dwJob;
    DWORD dwBytesWritten;

    LPSTR szPrinterName=(char*)printerName.toLocal8Bit().data();
    LPBYTE lpData = (unsigned char*)data.toLocal8Bit().data();
    DWORD dwCount = (long) data.length();

    if (!OpenPrinterA(szPrinterName,&hPrinter,NULL)){
        return false;
    }

    DocInfo.pDocName = (char*)(QString("PRN COMMNAD")).toLocal8Bit().data();
    DocInfo.pOutputFile = NULL;
    DocInfo.pDatatype = NULL;//(char*)(QString("RAW")).toLocal8Bit().data();

    if ((dwJob=StartDocPrinterA(hPrinter,1,(PBYTE)&DocInfo))==0){
        ClosePrinter(hPrinter);
        return false;
    }

    if(!StartPagePrinter(hPrinter)){
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);
        return false;
    }

    if (!WritePrinter(hPrinter,lpData,dwCount,&dwBytesWritten)){
        EndPagePrinter(hPrinter);
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);

        return false;
    }

    if(!EndPagePrinter(hPrinter)){
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);
        return false;
    }

    if(!EndDocPrinter(hPrinter)){
        ClosePrinter(hPrinter);
        return false;
    }

    ClosePrinter(hPrinter);

    if (dwBytesWritten != dwCount){
        return false;
    }

    return true;
    // -- Windows
#elif defined(Q_OS_MAC)

#endif

    return true;
}


QString PosPrinter::readLogoFile(){

    QFile file( QDir::homePath() + "/posLogo.svg");
    file.open(QIODevice::ReadOnly | QIODevice::Text);

    QString line;
    QString fileContent;
    QTextStream t( &file );
    do {
        line = t.readLine();
        fileContent += line;
     } while (!line.isNull());
    file.close();
    return fileContent;
}

QString PosPrinter::readFile(QString path){

    QFile file( path );
    file.open(QIODevice::ReadOnly | QIODevice::Text);

    QString line;
    QString fileContent;
    QTextStream t( &file );
    do {
        line = t.readLine();
        fileContent += line;
     } while (!line.isNull());
    file.close();
    return fileContent;
}



void PosPrinter::print(QString htmlContent){

    /*
    QPrinter printer(QPrinter::ScreenResolution);
    printer.setResolution(printerResolution);
    printer.setPaperSize(QSizeF(paperWidth,paperHeight),QPrinter::Millimeter);
    printer.setPageSize(QPrinter::Custom);
    printer.setFullPage(true);


    QWebView *m_pWebView = new QWebView();
    m_pWebView->setHtml(htmlContent);
    //printer.setPageMargins(4,4,4,15,QPrinter::Millimeter);
    //printer.setPaperSize(QSizeF(80,200),QPrinter::Millimeter);
    m_pWebView->print(&printer);
    */
}

void PosPrinter::setup(int res,double width,double height){
  printerResolution = res;
  paperWidth = width;
  paperHeight = height;
}

void PosPrinter::allPrinters(){
    int i;
    QList<QPrinterInfo> list = QPrinterInfo::availablePrinters ();
    for(i=0;i<list.count();i++){
        QPrinterInfo pInfo = list.at(i);
        qDebug() << pInfo.printerName();
        qDebug() << pInfo.defaultPageSize().sizePoints();
        qDebug() << pInfo.supportedPaperSizes();
        qDebug() << pInfo.supportedResolutions();
    }


}



void PosPrinter::printFile(QString printer, QString filename, QString height){
  QImage *img = new QImage(filename);
  ESCPOSImage *esc = new ESCPOSImage();
  esc->saveImage(img,filename+".bin",height);
  /*
  QString convertProgram = "png2pos";
  QStringList convertArguments;
  convertArguments << "-l" << height;
  convertArguments << "-o" << filename+".bin";
  convertArguments << filename;
  QProcess *convertProcess = new QProcess();
  convertProcess->start(convertProgram, convertArguments);
  convertProcess->waitForFinished();
  */
  QString printProgram = "";
  QStringList arguments;
  if( (osName().compare("osx")==0) ||
      (osName().compare("linux")==0)
  ){
    printProgram = "lp";
    arguments << "-d" << printer;
    arguments << filename+".bin";
  }else if (
    (osName().compare("windows")==0)
  ){
    // print /D:"\\%COMPUTERNAME%\PRINTER" "%~dpn1.bin"
    printProgram = "print";
    arguments << "/D:\""+printer+"\"";
    arguments << filename+".bin";
  }

  if (printProgram.compare("")!=0){
    QProcess *printProcess = new QProcess();
    printProcess->start(printProgram, arguments);
    printProcess->waitForFinished(1000);
    QFile::remove(filename+".bin");
    QFile::remove(filename);
  }
}

void PosPrinter::cut(QString printer){
  QStringList codes = getEnv("POSCUT","27,109").split(",");
  int codes_i;
  QString data = "";
  for(codes_i=0;codes_i<codes.count();codes_i++){
      data.append(QChar(codes.at(codes_i).toInt()));
  }

  QString filename="cut.prn";
  QFile file( filename );
  if ( file.open(QIODevice::ReadWrite) )
  {
      QTextStream stream( &file );
      stream << data;
  }

  QString printProgram = "lp";
  QStringList arguments;
  arguments << "-d" << printer;
  arguments << "cut.prn";

  QProcess *printProcess = new QProcess();
  printProcess->start(printProgram, arguments);
  printProcess->waitForFinished(1000);
  QFile::remove("cut.prn");
}


void PosPrinter::open(QString printer){

  QStringList codes = getEnv("POSOPEN","27,112,0,25,250").split(",");
  qDebug() << "PosPrinter::open" << printer << codes;
  int codes_i;
  QString data = "";
  for(codes_i=0;codes_i<codes.count();codes_i++){
      data.append(QChar(codes.at(codes_i).toInt()));
  }

  QString filename="open.prn";
  QFile file( filename );
  if ( file.open(QIODevice::ReadWrite) )
  {
      QTextStream stream( &file );
      stream << data;
  }

  QString printProgram = "lp";
  QStringList arguments;
  arguments << "-d" << printer;
  arguments << "open.prn";

  QProcess *printProcess = new QProcess();
  printProcess->start(printProgram, arguments);
  printProcess->waitForFinished(1000);

  QFile::remove("open.prn");

}
