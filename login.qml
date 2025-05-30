import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true

    Material.theme: Material.Light
    Material.primary: "#3498db"
    Material.accent: "#FF5722"
    color: "#1E3D49"

    property bool isPopupVisible: false
    property string popupMessage: ""

    function showDialog(message) {
        popupMessage = message;
        isPopupVisible = true;
    }

    Popup {
        id: feedbackPopup
        width: 300
        height: 120
        visible: isPopupVisible
        focus: true
        modal: true

        Rectangle {
            anchors.fill: parent
            color: "#ecf0f1"
            radius: 10
            border.color: "#bdc3c7"
            border.width: 2

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: popupMessage
                    font.pixelSize: 18
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "OK"
                    onClicked: {
                        isPopupVisible = false;
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
        spacing: 10

        Image {
            id: botImage
            source: "qrc:/chatDisplay/bot.png"
            width: 50
            height: 50
            fillMode: Image.PreserveAspectFit
            smooth: true
            antialiasing: true
            mipmap: true
        }

        Text {
            id: titleText
            text: "EduBot Sign In"
            font.pixelSize: 24
            font.bold: true
            font.italic: true
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        id: loginFrame
        width: 300
        height: 300
        x: 20
        y: 120
        radius: 20
        color: "#8DAEB7"
        border.color: "#8DAEB7"
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            TextField {
                id: usernameInput
                placeholderText: "Username"
                font.pixelSize: 18
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    radius: 10
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    border.width: 1
                }
            }

            TextField {
                id: passwordInput
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 18
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    radius: 10
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    border.width: 1
                }
            }

            Button {
                text: "Sign In"
                onClicked: {
                    if (authManager.signIn(usernameInput.text, passwordInput.text)) {
                        showDialog("Sign-in successful!");
                        botAnimation.start();
                    } else {
                        showDialog("Sign-in failed! Invalid credentials.");
                    }
                }
            }

            Text {
                text: "Register?"
                color: "blue"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        titleText.text = "EduBot Sign Up"
                        loginToSignupAnimation.start();
                    }
                }
            }
        }
    }

    Rectangle {
        id: signupFrame
        width: 300
        height: 380
        x: window.width
        y: 80
        radius: 20
        color: "#8DAEB7"
        border.color: "#8DAEB7"
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            TextField {
                id: signupUsernameInput
                placeholderText: "Username"
                font.pixelSize: 18
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    radius: 10
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    border.width: 1
                }
            }

            TextField {
                id: signupPasswordInput
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 18
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    radius: 10
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    border.width: 1
                }
            }

            TextField {
                id: signupConfirmInput
                placeholderText: "Confirm Password"
                echoMode: TextInput.Password
                font.pixelSize: 18
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    radius: 10
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    border.width: 1
                }
            }

            Button {
                text: "Sign Up"
                onClicked: {
                    if (signupPasswordInput.text !== signupConfirmInput.text) {
                        showDialog("Passwords do not match!");
                    } else if (authManager.signUp(signupUsernameInput.text, signupPasswordInput.text)) {
                        showDialog("Sign-up successful!");
                    } else {
                        showDialog("Sign-up failed!");
                    }
                }
            }

            Text {
                text: "Go to Sign In"
                color: "blue"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        titleText.text = "EduBot Sign In"
                        signupToLoginAnimation.start();
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: botAnimation
        PropertyAnimation {
            target: botImage
            property: "width"
            to: 300
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: botImage
            property: "height"
            to: 300
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: loginToSignupAnimation
        PropertyAnimation {
            target: loginFrame
            property: "x"
            to: -loginFrame.width
            duration: 500
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: signupFrame
            property: "x"
            from: window.width
            to: window.width - signupFrame.width - 20
            duration: 500
            easing.type: Easing.OutBack
        }
    }

    SequentialAnimation {
        id: signupToLoginAnimation
        PropertyAnimation {
            target: signupFrame
            property: "x"
            to: window.width
            duration: 500
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: loginFrame
            property: "x"
            to: 20
            duration: 500
            easing.type: Easing.OutBack
        }
    }

    StackView {
        id: stackView

    }
}
