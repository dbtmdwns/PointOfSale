#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QtQml>
#include "posprinter.h"
#include "capturer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    //qmlRegisterType <Capturer> ("com.tualo", 1, 0, "Capturer");
    //@uri Tualo.PosPrinter
    qmlRegisterType <PosPrinter> ("com.tualo", 1, 0, "PosPrinter");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    return app.exec();

}
