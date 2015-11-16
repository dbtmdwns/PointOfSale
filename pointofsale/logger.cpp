#include <logger.h>
#include <qDebug>


Logger::Logger(QQuickItem *parent) :
    QQuickItem(parent)

{
}

void Logger::error( QString iDataToLog)
{
  this->log(0,iDataToLog);
}
void Logger::warn( QString iDataToLog)
{
  this->log(1,iDataToLog);
}
void Logger::info( QString iDataToLog)
{
  this->log(2,iDataToLog);
}
void Logger::debug( QString iDataToLog)
{
  this->log(3,iDataToLog);
}

QStringList Logger::getError( )
{
  return errorList;
}

QStringList Logger::getInfo( )
{
  return infoList;
}

QStringList Logger::getWarn( )
{
  return warnList;
}

QStringList Logger::getDebug( )
{
  return debugList;
}

// Implementation of log method callable from Qml source
void Logger::log(unsigned int iLogLevel,  QString iDataToLog)
{
    qDebug() << "Logger" << iLogLevel << iDataToLog;
    switch(iLogLevel)
    {
        case 0: // ERROR
            errorList.append(iDataToLog);
            // use you logger to log iDataToLog at error level
            break;
        case 1: // WARNING
            warnList.append(iDataToLog);
            // use you logger to log iDataToLog at warning level
            break;
        case 2: // INFO
            // use you logger to log iDataToLog at info level
            infoList.append(iDataToLog);
            break;
        case 3: // DEBUG
            // use you logger to log iDataToLog at debug level
            debugList.append(iDataToLog);
            break;
        case 4: // TRACE
            // use you logger to log iDataToLog at trace level
            break;
    }
}
