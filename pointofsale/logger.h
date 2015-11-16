#include <QQuickItem>
#include <QObject>


class Logger : public QQuickItem
{
    Q_OBJECT
public:
    explicit Logger(QQuickItem *iParent = 0);

    // Q_INVOKABLE log method will be called by Qml source.
    Q_INVOKABLE void log(unsigned int iLogLevel,  QString iDataToLog) ;
    Q_INVOKABLE void error( QString iDataToLog) ;
    Q_INVOKABLE void info( QString iDataToLog) ;
    Q_INVOKABLE void warn( QString iDataToLog) ;
    Q_INVOKABLE void debug( QString iDataToLog) ;

    Q_INVOKABLE QStringList getError( ) ;
    Q_INVOKABLE QStringList getInfo( ) ;
    Q_INVOKABLE QStringList getWarn( ) ;
    Q_INVOKABLE QStringList getDebug( ) ;

    enum Level
    {
        Error = 0,
        Warning,
        Info,
        Debug,
        Trace
    };

    Q_ENUMS(Level)

private:
  QStringList errorList;
  QStringList infoList;
  QStringList warnList;
  QStringList debugList;
  QStringList traceList;

    //YourLogger mYourLogger; // YourLogger is your system to log on C++ world
};
