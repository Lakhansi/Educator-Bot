import QtQuick 2.15

Rectangle {
    id: messageBubble
    property alias text: messageText.text
    property bool isUser: true
    property bool isCode: false  // ✅ Declare the property properly

    width: Math.min(parent ? parent.width * 0.7 : 400, messageText.paintedWidth + 20)
    height: Math.max(messageText.paintedHeight + 20, 40)

    color: isUser ? "#A9A9A9" : (isCode ? "#282C34" : "#A9A9A9") // Code messages have a dark background
    radius: 10
    border.color: isUser ? "#A9A9A9" : (isCode ? "#61AFEF" : "#A9A9A9") // Blue border for code
    border.width: isCode ? 2 : 1
    anchors.margins: 10

    // ✅ Check if parent exists before setting anchors
    anchors.right: parent ? (isUser ? parent.right : undefined) : undefined
    anchors.left: parent ? (isUser ? undefined : parent.left) : undefined

    Text {
        id: messageText
        text: messageBubble.text
        wrapMode: Text.WordWrap
        color: isCode ? "#98C379" : "black"  // Code text is green
        font.pixelSize: isCode ? 14 : 16
        font.family: isCode ? "Courier New" : "Arial"
        width: parent.width - 20
        anchors.centerIn: parent
        anchors.margins: 10
        verticalAlignment: Text.AlignVCenter
    }
}
