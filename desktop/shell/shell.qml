import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property bool startMenuOpen: false
    property var workspaces: [
        { "id": "desktop-1", "name": "Desktop 1", "active": true },
        { "id": "desktop-2", "name": "Desktop 2", "active": false }
    ]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: taskbar
            required property var modelData
            screen: modelData
            anchors {
                left: true
                right: true
                bottom: true
            }
            margins {
                left: 12
                right: 12
                bottom: 8
            }
            implicitHeight: 46
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#d9141414"
                border.color: "#35ffffff"
                border.width: 1
                radius: 7

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    spacing: 6

                    ToolButton {
                        id: startButton
                        text: "os"
                        font.bold: true
                        font.pixelSize: 14
                        implicitWidth: 36
                        implicitHeight: 32
                        onClicked: root.startMenuOpen = !root.startMenuOpen
                        ToolTip.visible: hovered
                        ToolTip.text: "Start"
                    }

                    Rectangle {
                        implicitWidth: 1
                        implicitHeight: 22
                        color: "#35ffffff"
                    }

                    Repeater {
                        model: root.workspaces

                        ToolButton {
                            required property var modelData
                            text: modelData.name
                            font.pixelSize: 12
                            highlighted: modelData.active
                            implicitHeight: 32
                            leftPadding: 11
                            rightPadding: 11
                            onClicked: {
                                // D-Bus activation is connected after the shell client lands.
                            }
                        }
                    }

                    ToolButton {
                        text: "+"
                        font.pixelSize: 18
                        implicitWidth: 32
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "New desktop"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "0"
                        implicitWidth: 34
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "Hidden windows"
                    }

                    ToolButton {
                        text: "VOL"
                        font.pixelSize: 10
                        implicitWidth: 42
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "Sound"
                    }

                    Label {
                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: "#f4f4f5"
                        font.pixelSize: 12
                        font.bold: true
                        leftPadding: 8
                        rightPadding: 8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        id: startMenu
        visible: root.startMenuOpen
        anchors {
            left: true
            bottom: true
        }
        margins {
            left: 14
            bottom: 62
        }
        implicitWidth: 360
        implicitHeight: 460
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f2111111"
            border.color: "#45ffffff"
            border.width: 1
            radius: 7

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "os_name"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "X"
                        onClicked: root.startMenuOpen = false
                        ToolTip.visible: hovered
                        ToolTip.text: "Close"
                    }
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Search apps, settings, and files"
                }

                Label {
                    text: "Pinned"
                    color: "#a1a1aa"
                    font.pixelSize: 11
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: ["Files", "Terminal", "Browser", "Settings",
                                "Software", "Security", "Games", "System"]

                        ToolButton {
                            required property string modelData
                            text: modelData
                            implicitWidth: 76
                            implicitHeight: 54
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: "#35ffffff"
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "User"
                        color: "#f4f4f5"
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "Lock"
                    }

                    ToolButton {
                        text: "Power"
                    }
                }
            }
        }
    }
}
