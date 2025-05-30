#include "networkmanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QRegularExpression>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent) {
    manager = new QNetworkAccessManager(this);
}

void NetworkManager::sendQuery(const QString &query) {
    QUrl url("http://127.0.0.1:5000/chat");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["text"] = query.trimmed();  // ✅ Ensure clean input

    QJsonDocument doc(json);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);

    qDebug() << "Sending POST request with data: " << jsonData;

    QNetworkReply *reply = manager->post(request, jsonData);
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleResponse);
}

void NetworkManager::handleResponse() {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;

    QByteArray response_data = reply->readAll();
    qDebug() << "Raw response received:" << response_data;

    // Parse JSON response
    QJsonDocument jsonResponse = QJsonDocument::fromJson(response_data);
    if (!jsonResponse.isObject()) {
        qDebug() << "Error: Response is not a valid JSON object";
        emit responseReceived("Error: Invalid response from server.");
        reply->deleteLater();
        return;
    }

    QJsonObject jsonObject = jsonResponse.object();

    QString explanation = jsonObject.value("explanation").toString().trimmed();
    QString example = jsonObject.value("example").toString().trimmed();
    QString code = jsonObject.value("code").toString().trimmed();

    // Don't use fallback/defaults. Only send what the model generates.
    QString finalResponse = explanation + "\n\n💡 **Example**:\n\n" + example + "\n\n💻 **Code**:\n\n" + code;
    finalResponse = finalResponse.trimmed();

    emit responseReceived(finalResponse);
    emit explanationReceived(explanation);
    emit exampleReceived(example);
    emit codeReceived(code);

    reply->deleteLater();
}

//this is final
