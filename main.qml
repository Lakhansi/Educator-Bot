import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "AI Tutor Chat"

    property bool isCodeMessage: false

    Component {
        id: mainPage
        Item {
            Loader {
                anchors.fill: parent
                source: "main.qml"
            }
        }
    }

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: "gray"

        Rectangle {
            id: historyPanel
            width: parent.width * 0.25
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: "#2C2F33"

            ListView {
                id: historyListView
                anchors.fill: parent
                spacing: 10
                clip: true
                model: ListModel {}

                delegate: Item {
                    width: parent.width
                    height: contentItem.implicitHeight + 1

                    Column {
                        spacing: 10
                        id: contentItem

                        Text {
                            text: model.isDateHeader ? model.date : model.messageText
                            color: model.isDateHeader ? "lightblue" : "white"
                            font.pixelSize: model.isDateHeader ? 16 : 14
                            font.bold: model.isDateHeader
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            padding: model.isDateHeader ? 16 : 16
                        }
                    }
                }
            }
        }

        Rectangle {
            id: chatArea
            anchors.top: parent.top
            anchors.left: historyPanel.right
            anchors.right: parent.right
            anchors.bottom: inputField.top
            color: "transparent"

            ListView {
                id: messageListView
                anchors.fill: parent
                spacing: 10
                clip: true
                model: ListModel {}

                delegate: MessageBubble {
                    id: messageBubble
                    text: model.messageText
                    isUser: model.isUser
                    isCode: model.isCode !== undefined ? model.isCode : false
                    anchors.right: model.isUser ? parent.right : undefined  // ✅ Right-align user messages
                    anchors.left: model.isUser ? undefined : parent.left
                }
            }
            Connections {
                target: networkManager
                function onResponseReceived(response) {
                    console.log("QML Received response:", response);

                    // Remove "Thinking..." message if it exists
                    if (messageListView.model.count > 0) {
                        let lastItem = messageListView.model.get(messageListView.model.count - 1);
                        if (lastItem.messageText === "Thinking...") {
                            messageListView.model.remove(messageListView.model.count - 1);
                        }
                    }

                    if (!response || response.trim().length === 0) {
                        console.warn("Warning: Empty response received");
                        return;
                    }

                    // Always remove only the last 3 bot responses if they exist
                    for (let i = messageListView.model.count - 1; i >= 0; i--) {
                        let item = messageListView.model.get(i);
                        if (!item.isUser) {
                            messageListView.model.remove(i);
                        }
                        if (messageListView.model.count > 0 && messageListView.model.get(messageListView.model.count - 1).isUser) {
                            break;
                        }
                    }

                    // Split the response
                    var parts = response.split("\n\n");
                    var explanationPart = parts.length > 0 ? parts[0].trim() : "";
                    var codePart = parts.length > 1 ? parts[1].trim() : "";
                    var outputPart = parts.length > 2 ? parts.slice(2).join("\n\n").trim() : "";

                    if (explanationPart.length > 0) {
                        messageListView.model.append({
                            messageText: explanationPart,
                            isUser: false,
                            isCode: false
                        });
                    }

                    if (codePart.length > 0) {
                        if (!codePart.includes("```")) {
                            codePart = "```cpp\n" + codePart + "\n```";
                        }
                        messageListView.model.append({
                            messageText: codePart,
                            isUser: false,
                            isCode: true
                        });
                    }

                    if (outputPart.length > 0) {
                        messageListView.model.append({
                            messageText: outputPart,
                            isUser: false,
                            isCode: false
                        });
                    }
                }
            }

        }

        Rectangle {
            id: inputField
            width: chatArea.width * 0.9
            color: "transparent"
            anchors.horizontalCenter: chatArea.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            height: Math.max(40, userInput.contentHeight + 20)

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    height: inputField.height
                    color: "#A9A9A9"
                    radius: 16
                    border.color: "transparent"

                    Flickable {
                        id: flickable
                        anchors.fill: parent
                        contentHeight: userInput.contentHeight
                        clip: true

                        TextInput {
                            id: userInput
                            width: flickable.width - 40
                            color: "black"
                            font.pixelSize: 16
                            wrapMode: TextInput.Wrap
                            verticalAlignment: TextInput.AlignTop
                            padding: 8

                            PlaceholderText {
                                text: "Type your message here..."
                                color: "gray"
                                anchors.centerIn: parent
                                visible: userInput.text === ""
                            }

                            Keys.onReturnPressed: {
                                if (userInput.text.trim() !== "") {
                                    messageListView.model.append({
                                        messageText: userInput.text,
                                        isUser: true
                                    });

                                    addToHistory(userInput.text);
                                    networkManager.sendQuery(userInput.text);
                                    userInput.text = "";
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 35
                    height: 35
                    radius: 20
                    color: "#A9A9A9"

                    Image {
                        source: "qrc:/chatDisplay/arrow.png"
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: parent.height * 0.7
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (userInput.text.trim() !== "") {
                                messageListView.model.append({
                                    messageText: userInput.text,
                                    isUser: true
                                });

                                addToHistory(userInput.text);
                                networkManager.sendQuery(userInput.text);
                                userInput.text = "";
                            }
                        }
                    }
                }
            }
        }
    }

    function addToHistory(userQuery) {
        let currentDate = new Date().toDateString();
        let lastDateHeader = null;

        for (let i = historyListView.model.count - 1; i >= 0; i--) {
            let item = historyListView.model.get(i);
            if (item.isDateHeader) {
                lastDateHeader = item.date;
                break;
            }
        }

        if (lastDateHeader !== currentDate) {
            historyListView.model.append({
                isDateHeader: true,
                date: currentDate
            });
        }

        let keyword = getRelatedKeyword(userQuery);
        historyListView.model.append({
            isDateHeader: false,
            messageText: keyword
        });
    }

    function getRelatedKeyword(query) {
        if (query.toLowerCase().includes("hello")) return "Greeting";
        if (query.toLowerCase().includes("condition")) return "Programming: Conditions";
        if (query.toLowerCase().includes("loop")) return "Programming: Loops";
        if (query.toLowerCase().includes("sql")) return "Database: SQL";
        if (query.toLowerCase().includes("os")) return "Operating Systems";
        return "General Query";
    }
}

//this is final
