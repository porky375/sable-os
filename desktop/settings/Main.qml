import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    visible: true
    width: 860
    height: 580
    minimumWidth: 720
    minimumHeight: 480
    title: "Sable Settings"
    color: "#101010"

    property int selectedSection: 0
    property var sections: [
        "Appearance", "Displays", "Network", "Sound", "System"
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 190
            Layout.fillHeight: true
            color: "#151515"
            border.color: "#2f2f2f"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    text: "Sable"
                    color: "#ffffff"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.bottomMargin: 8
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 3
                    model: window.sections
                    clip: true

                    delegate: ItemDelegate {
                        required property string modelData
                        required property int index
                        width: ListView.view.width
                        height: 40
                        text: modelData
                        highlighted: window.selectedSection === index
                        onClicked: window.selectedSection = index
                    }
                }
            }
        }

        StackLayout {
            currentIndex: window.selectedSection
            Layout.fillWidth: true
            Layout.fillHeight: true

            Pane {
                padding: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 18

                    Label {
                        text: "Appearance"
                        color: "#ffffff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Switch {
                        text: "Window blur"
                        checked: true
                        onToggled: Quickshell.execDetached(
                            ["sable-control", "set", "blur",
                             checked ? "1" : "0"])
                    }

                    Switch {
                        text: "Animations"
                        checked: true
                        onToggled: Quickshell.execDetached(
                            ["sable-control", "set", "animations",
                             checked ? "1" : "0"])
                    }

                    Label {
                        text: "Window opacity"
                        color: "#d4d4d8"
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0.75
                        to: 1.0
                        value: 0.97
                        stepSize: 0.01
                        onMoved: Quickshell.execDetached(
                            ["sable-control", "set", "opacity",
                             value.toFixed(2)])
                    }

                    Button {
                        text: "Reset appearance"
                        onClicked: Quickshell.execDetached(
                            ["sable-control", "reset"])
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Pane {
                padding: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 18

                    Label {
                        text: "Displays"
                        color: "#ffffff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Button {
                        text: "Open display configuration"
                        onClicked: Quickshell.execDetached(["wdisplays"])
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Pane {
                padding: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 18

                    Label {
                        text: "Network"
                        color: "#ffffff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Button {
                        text: "Open network configuration"
                        onClicked: Quickshell.execDetached(
                            ["kitty", "--class", "sable-network",
                             "-e", "nmtui"])
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Pane {
                padding: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 18

                    Label {
                        text: "Sound"
                        color: "#ffffff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Button {
                        text: "Open volume controls"
                        onClicked: Quickshell.execDetached(["pavucontrol"])
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Pane {
                padding: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 18

                    Label {
                        text: "System"
                        color: "#ffffff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Label {
                        text: "Sable Bootstrap Preview"
                        color: "#d4d4d8"
                        font.pixelSize: 16
                    }

                    Button {
                        text: "Open system monitor"
                        onClicked: Quickshell.execDetached(
                            ["kitty", "--class", "sable-system",
                             "-e", "btop"])
                    }

                    Button {
                        text: "Open terminal"
                        onClicked: Quickshell.execDetached(["kitty"])
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
