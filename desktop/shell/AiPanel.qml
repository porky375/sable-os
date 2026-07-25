// Sable Assistant — a local AI chat panel for the QuickShell desktop.
// Talks to the on-device sable-ai backend (Ollama router + desktop/coding
// preamble). Nothing leaves the machine. Toggled from the taskbar via `open`.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: aiPanel

    property bool open: false

    visible: open
    anchors {
        right: true
        bottom: true
    }
    margins {
        right: 14
        bottom: 62
    }
    implicitWidth: 430
    implicitHeight: 580
    color: "transparent"

    // Conversation as a list of { role: "user"|"assistant"|"system", text }.
    ListModel {
        id: history
    }
    property bool busy: false

    function appendMessage(role, text) {
        history.append({ "role": role, "text": text });
        chatView.positionViewAtEnd();
    }

    function send(text) {
        const trimmed = text.trim();
        if (trimmed.length === 0 || aiPanel.busy)
            return;
        appendMessage("user", trimmed);
        aiPanel.busy = true;
        appendMessage("assistant", "…");
        aiProc.command = ["sable-ai", trimmed];
        aiProc.running = true;
    }

    Process {
        id: aiProc
        stdout: StdioCollector {
            id: aiOut
        }
        onExited: function (code, status) {
            // Replace the trailing "…" placeholder with the reply.
            const reply = aiOut.text.trim();
            if (history.count > 0) {
                history.set(history.count - 1, {
                    "role": "assistant",
                    "text": code === 0 && reply.length > 0
                        ? reply
                        : "I could not reach the local model. Make sure ollama.service is running, then click ‘Set up model’."
                });
            }
            aiPanel.busy = false;
            chatView.positionViewAtEnd();
        }
    }

    Process {
        id: setupProc
        command: ["kitty", "--class", "sable-ai-setup", "-e", "sable-ai", "--setup"]
    }

    Rectangle {
        anchors.fill: parent
        color: "#f2111111"
        border.color: "#45ffffff"
        border.width: 1
        radius: 7

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Sable Assistant"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }
                Label {
                    text: "local"
                    color: "#8ae234"
                    font.pixelSize: 10
                    rightPadding: 8
                }
                ToolButton {
                    text: "X"
                    onClicked: aiPanel.open = false
                    ToolTip.visible: hovered
                    ToolTip.text: "Close"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#35ffffff"
            }

            ListView {
                id: chatView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: history
                boundsBehavior: Flickable.StopAtBounds

                delegate: Column {
                    width: chatView.width
                    spacing: 2

                    Label {
                        text: model.role === "user" ? "You" : "Sable"
                        color: model.role === "user" ? "#a1a1aa" : "#8ab4f8"
                        font.pixelSize: 10
                    }
                    Rectangle {
                        width: parent.width
                        radius: 6
                        color: model.role === "user" ? "#22ffffff" : "#1a8ab4f8"
                        implicitHeight: msgText.implicitHeight + 12
                        Label {
                            id: msgText
                            anchors.fill: parent
                            anchors.margins: 6
                            text: model.text
                            color: "#f4f4f5"
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            textFormat: Text.PlainText
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: history.count === 0
                    width: parent.width - 24
                    horizontalAlignment: Text.AlignHCenter
                    text: "Ask me about Linux, the shell, configuration, or code.\nRuns fully on your machine."
                    color: "#71717a"
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                TextField {
                    id: input
                    Layout.fillWidth: true
                    placeholderText: aiPanel.busy ? "Thinking…" : "Message Sable Assistant"
                    enabled: !aiPanel.busy
                    onAccepted: {
                        aiPanel.send(text);
                        text = "";
                    }
                }
                ToolButton {
                    text: "Send"
                    enabled: !aiPanel.busy && input.text.trim().length > 0
                    onClicked: {
                        aiPanel.send(input.text);
                        input.text = "";
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                ToolButton {
                    text: "Set up model"
                    font.pixelSize: 10
                    ToolTip.visible: hovered
                    ToolTip.text: "Download the local model (first-run, needs internet)"
                    onClicked: setupProc.running = true
                }
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: "Clear"
                    font.pixelSize: 10
                    onClicked: history.clear()
                }
            }
        }
    }
}
