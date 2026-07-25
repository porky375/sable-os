import QtQuick

Rectangle {
    id: root
    color: "#101010"

    function onActivate() {
        pulse.restart()
    }

    function onLeave() {
        pulse.stop()
    }

    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S"
            color: "#f4f4f5"
            font.pixelSize: 72
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Installing Sable"
            color: "#f4f4f5"
            font.pixelSize: 24
        }

        Rectangle {
            id: line
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220
            height: 2
            color: "#52525b"
        }
    }

    SequentialAnimation {
        id: pulse
        loops: Animation.Infinite
        running: true

        NumberAnimation {
            target: line
            property: "opacity"
            from: 0.35
            to: 1
            duration: 900
        }
        NumberAnimation {
            target: line
            property: "opacity"
            from: 1
            to: 0.35
            duration: 900
        }
    }
}
