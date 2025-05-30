#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

class AuthManager : public QObject {
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);
    bool openDatabase();
    Q_INVOKABLE bool signUp(const QString &username, const QString &password);
    Q_INVOKABLE bool signIn(const QString &username, const QString &password);

signals:
    void showDialog(const QString &message);
    void loginSuccessful();

private:
    QSqlDatabase db;
};

#endif
