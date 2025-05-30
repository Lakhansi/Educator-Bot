#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);

public slots:
    void sendQuery(const QString &query);

signals:
    // Signal to send explanation, example, and code
    void explanationReceived(const QString &explanation);
    void exampleReceived(const QString &example);
    void codeReceived(const QString &code);

    // Signal when the response is received
    void responseReceived(const QString &response);

private slots:
    void handleResponse();

private:
    QNetworkAccessManager *manager;
};

#endif // NETWORKMANAGER_H
