import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    visible: true
    width: 980
    height: 680
    minimumWidth: 760
    minimumHeight: 520
    title: "os_name Settings"
    color: "#101010"

    property int selectedSection: 0
    property var sections: [
        "Appearance", "Taskbar", "Windows", "Workspaces", "Keybinds",
        "Displays", "Sound", "Power", "Apps", "Privacy", "Profiles"
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 210
            Layout.fillHeight: true
            color: "#151515"
            border.color: "#2f2f2f"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    text: "os_name"
                    color: "#ffffff"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.bottomMargin: 8
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Search settings"
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
                        height: 38
                        text: modelData
                        highlighted: window.selectedSection === index
                        onClicked: window.selectedSection = index
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: Math.max(520, window.width - 260)
                spacing: 18
                anchors.margins: 28

                Label {
                    text: window.sections[window.selectedSection]
                    color: "#ffffff"
                    font.pixelSize: 24
                    font.bold: true
                }

                Label {
                    text: "Theme"
                    color: "#d4d4d8"
                    font.pixelSize: 13
                    font.bold: true
                }

                RowLayout {
                    spacing: 10

                    Repeater {
                        model: ["#101010", "#f4f4f5", "#3f3f46", "#2563eb"]

                        Rectangle {
                            required property string modelData
                            color: modelData
                            implicitWidth: 42
                            implicitHeight: 42
                            radius: 6
                            border.color: "#777777"
                            border.width: 1
                        }
                    }
                }

                Switch {
                    text: "Use dark appearance"
                    checked: true
                }

                Switch {
                    text: "Enable light background blur"
                    checked: true
                }

                Label {
                    text: "Panel opacity"
                    color: "#d4d4d8"
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0.55
                    to: 1.0
                    value: 0.84
                }

                Label {
                    text: "Window opacity"
                    color: "#d4d4d8"
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0.7
                    to: 1.0
                    value: 0.94
                }

                Label {
                    text: "Animation speed"
                    color: "#d4d4d8"
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: 0.85
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
