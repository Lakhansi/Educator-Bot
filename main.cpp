#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "authmanager.h"
#include "networkmanager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    AuthManager authManager;
    engine.rootContext()->setContextProperty("authManager", &authManager);

    // Expose NetworkManager to QML
    NetworkManager networkManager;
    engine.rootContext()->setContextProperty("networkManager", &networkManager);

    engine.load(QUrl(QStringLiteral("qrc:/chatDisplay/login.qml")));

    QObject::connect(&authManager, &AuthManager::loginSuccessful, [&]() {
        engine.clearComponentCache();
        engine.load(QUrl(QStringLiteral("qrc:/chatDisplay/main.qml")));
    });

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
