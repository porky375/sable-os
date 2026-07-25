import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property bool startMenuOpen: false
    property bool aiPanelOpen: false
    property string appFilter: ""
    property var pinnedApps: [
        { "name": "Install Sable", "command": ["sable-installer"] },
        { "name": "Browser", "command": ["firefox"] },
        { "name": "Files", "command": ["thunar"] },
        {
            "name": "Network",
            "command": ["kitty", "--class", "sable-network", "-e", "nmtui"]
        },
        {
            "name": "Settings",
            "command": ["qml6", "/usr/share/sable/settings/Main.qml"]
        },
        {
            "name": "System",
            "command": ["kitty", "--class", "sable-system", "-e", "btop"]
        },
        { "name": "Terminal", "command": ["kitty"] }
    ]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            color: "#101010"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Image {
                anchors.fill: parent
                source: "file:///usr/share/backgrounds/sable/wallpaper.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }
    }

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
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Auto

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
                        text: "S"
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
                        model: Hyprland.workspaces

                        ToolButton {
                            required property var modelData
                            text: modelData.name.startsWith("special:")
                                ? modelData.name.substring(8)
                                : "Desktop " + modelData.name
                            font.pixelSize: 12
                            highlighted: modelData.focused
                            visible: !modelData.name.startsWith("special:")
                            implicitHeight: 32
                            leftPadding: 11
                            rightPadding: 11
                            onClicked: Hyprland.dispatch(
                                "workspace " + modelData.name)
                        }
                    }

                    ToolButton {
                        text: "+"
                        font.pixelSize: 18
                        implicitWidth: 32
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "New desktop"
                        onClicked: Hyprland.dispatch("workspace empty")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "MIN"
                        font.pixelSize: 10
                        implicitWidth: 42
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "Hidden windows"
                        onClicked: Hyprland.dispatch(
                            "togglespecialworkspace minimized")
                    }

                    ToolButton {
                        text: "NET"
                        font.pixelSize: 10
                        implicitWidth: 42
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "Network"
                        onClicked: Quickshell.execDetached(
                            ["kitty", "--class", "sable-network",
                             "-e", "nmtui"])
                    }

                    ToolButton {
                        text: "VOL"
                        font.pixelSize: 10
                        implicitWidth: 42
                        implicitHeight: 32
                        ToolTip.visible: hovered
                        ToolTip.text: "Sound"
                        onClicked: Quickshell.execDetached(["pavucontrol"])
                    }

                    ToolButton {
                        text: "AI"
                        font.pixelSize: 10
                        implicitWidth: 42
                        implicitHeight: 32
                        highlighted: root.aiPanelOpen
                        ToolTip.visible: hovered
                        ToolTip.text: "Sable Assistant"
                        onClicked: root.aiPanelOpen = !root.aiPanelOpen
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
                        text: "Sable"
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
                    placeholderText: "Search applications"
                    onTextChanged: root.appFilter = text.trim().toLowerCase()
                }

                Label {
                    text: "Pinned"
                    color: "#a1a1aa"
                    font.pixelSize: 11
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: root.pinnedApps.filter(function(app) {
                            return root.appFilter.length === 0 ||
                                app.name.toLowerCase().includes(root.appFilter);
                        })

                        ToolButton {
                            required property var modelData
                            text: modelData.name
                            implicitWidth: 98
                            implicitHeight: 54
                            onClicked: {
                                Quickshell.execDetached(modelData.command);
                                root.startMenuOpen = false;
                            }
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
                        onClicked: {
                            Quickshell.execDetached(["hyprlock"]);
                            root.startMenuOpen = false;
                        }
                    }

                    ToolButton {
                        text: "Sign out"
                        onClicked: Hyprland.dispatch("exit")
                    }

                    ToolButton {
                        text: "Restart"
                        onClicked: Quickshell.execDetached(
                            ["systemctl", "reboot"])
                    }

                    ToolButton {
                        text: "Power"
                        onClicked: Quickshell.execDetached(
                            ["systemctl", "poweroff"])
                    }
                }
            }
        }
    }

    AiPanel {
        open: root.aiPanelOpen
    }
}
