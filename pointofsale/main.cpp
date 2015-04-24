#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QtQml>
#include "posprinter.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

//    QApplication::addLibraryPath(QCoreApplication::applicationDirPath());
//    QApplication::addLibraryPath(QCoreApplication::applicationDirPath()+QDir::separator()+"plugins");

//    QCoreApplication::addLibraryPath(QCoreApplication::applicationDirPath());


    //@uri Tualo.PosPrinter
    qmlRegisterType <PosPrinter> ("com.tualo", 1, 0, "PosPrinter");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    /*
    QQuickView view;
    view.rootContext()->setContextProperty("printer",&printer);
    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    */
    return app.exec();
}
