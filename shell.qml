import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

ShellRoot {
    // Suivi du sink audio par défaut
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    PanelWindow {
        id: bar
        anchors.top: true
        anchors.left: true
        anchors.right: true

        implicitHeight: 32
        color: "#111111"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            // --------- WORKSPACES (gauche) ----------
            RowLayout {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                spacing: 4

                Repeater {
                    model: Hyprland.workspaces

                    delegate: Rectangle {
                        required property HyprlandWorkspace modelData

                        width: 22
                        height: 18
                        radius: 4
                        color: modelData.active ? "#ffffff" : "#333333"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.activate()
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name !== "" ? modelData.name : modelData.id
                            color: modelData.active ? "#000000" : "#ffffff"
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // Spacer pour centrer l'heure
            Item {
                Layout.fillWidth: true
            }

            // --------- HEURE (centre) ----------
            Text {
                id: clock
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                color: "#ffffff"
                font.pixelSize: 12

                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    interval: 10 * 1000
                    repeat: true
                    running: true
                    onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            // Spacer pour pousser le bouton à droite
            Item {
                Layout.fillWidth: true
            }

            // --------- BOUTON DROPDOWN (droite) ----------
            Rectangle {
                id: menuButton
                width: 26
                height: 18
                radius: 4
                color: dropdown.visible ? "#555555" : "#333333"

                MouseArea {
                    anchors.fill: parent
                    onClicked: dropdown.visible = !dropdown.visible
                }

                Text {
                    anchors.centerIn: parent
                    text: "⋮"
                    color: "#ffffff"
                    font.pixelSize: 12
                }
            }
        }
    }

    // --------- POPUP DROPDOWN AVEC SLIDER VOLUME ----------
    PopupWindow {
        id: dropdown

        // Ancrage relatif à la barre
        anchor.window: bar
        anchor.rect.x: bar.width - width - 8
        anchor.rect.y: bar.height

        visible: false

        implicitWidth: 220
        implicitHeight: 70
        color: "#181818"

        Rectangle {
            anchors.fill: parent
            color: "#181818"
            radius: 6
            border.color: "#444444"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Volume"
                        color: "#ffffff"
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        id: volPercent
                        color: "#ffffff"
                        font.pixelSize: 12
                        text: Math.round(volSlider.value * 100) + " %"
                    }
                }

                Slider {
                    id: volSlider

                    Layout.fillWidth: true

                    from: 0.0
                    to: 1.0
                    stepSize: 0.01

                    value: Pipewire.defaultAudioSink?.audio
                           ? Pipewire.defaultAudioSink.audio.volume
                           : 0.5

                    onMoved: {
                        const sink = Pipewire.defaultAudioSink
                        if (sink && sink.audio) {
                            sink.audio.muted = false
                            sink.audio.volume = value
                        }
                    }
                }

                // Sync quand le volume change ailleurs (clavier, autre app)
                Connections {
                    target: Pipewire.defaultAudioSink?.audio

                    function onVolumeChanged() {
                        const sink = Pipewire.defaultAudioSink
                        if (!sink || !sink.audio)
                            return

                        const v = sink.audio.volume
                        if (Math.abs(volSlider.value - v) > 0.001)
                            volSlider.value = v
                    }

                    function onMutedChanged() {
                        const sink = Pipewire.defaultAudioSink
                        if (!sink || !sink.audio)
                            return

                        if (sink.audio.muted && volSlider.value > 0)
                            volSlider.value = 0
                    }
                }
            }
        }
    }
}
