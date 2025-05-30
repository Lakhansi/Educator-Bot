#include "authmanager.h"
#include <QSqlError>
#include <QDebug>

AuthManager::AuthManager(QObject *parent) : QObject(parent) {
    openDatabase();
}

bool AuthManager::openDatabase() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("C:/chatDisplay/userDatabase.db");

    if (!db.open()) {
        qWarning() << "Database connection failed:" << db.lastError().text();
        emit showDialog("Database connection failed!");
        return false;
    }
    qDebug() << "Database connected successfully.";
    emit showDialog("Database connected successfully.");
    return true;
}

bool AuthManager::signUp(const QString &username, const QString &password) {
    if (username.isEmpty() || password.isEmpty()) {
        emit showDialog("Username or password cannot be empty!");
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO users (username, password) VALUES (?, ?)");
    query.addBindValue(username);
    query.addBindValue(password);

    if (!query.exec()) {
        emit showDialog("Sign-up failed: " + query.lastError().text());
        return false;
    }

    emit showDialog("Sign-up successful!");
    return true;
}

bool AuthManager::signIn(const QString &username, const QString &password) {
    if (username.isEmpty() || password.isEmpty()) {
        emit showDialog("Username or password cannot be empty!");
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT * FROM users WHERE username = ? AND password = ?");
    query.addBindValue(username);
    query.addBindValue(password);

    if (!query.exec()) {
        emit showDialog("Sign-in failed: " + query.lastError().text());
        return false;
    }

    if (query.next()) {
        emit showDialog("Sign-in successful!");
        emit loginSuccessful();
        return true;
    } else {
        emit showDialog("Invalid username or password!");
        return false;
    }
}
