#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QtQml>
#include "posprinter.h"
#include "capturer.h"
#include "logger.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    //qmlRegisterType <Capturer> ("com.tualo", 1, 0, "Capturer");
    //@uri Tualo.PosPrinter
    qmlRegisterType <PosPrinter> ("com.tualo", 1, 0, "PosPrinter");
    int typeId = qmlRegisterType<Logger>("com.tualo", 1, 0, "Logger");
    // if typeId is 0 => Error
    Q_ASSERT(typeId);
    //qmlRegisterSingletonType( QUrl("qrc:/qml/singleton/App.qml"), "App", 1, 0, "App" );
    //qmlRegisterSingletonType( QUrl("qrc:/qml/singleton/Remote.qml"), "Remote", 1, 0, "Remote" );
    //qmlRegisterSingletonType( QUrl("qrc:/qml/singleton/Local.qml"), "Local", 1, 0, "Local" );
    //qmlRegisterSingletonType( QUrl("qrc:/qml/singleton/ReportStore.qml"), "ReportStore", 1, 0, "ReportStore" );

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    return app.exec();

}
