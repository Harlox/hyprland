import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import "."

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

        // --- Workspaces (gauche) ---
        WorkspacesStrip {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        }

        // Spacer centre
        Item {
            Layout.fillWidth: true
        }

        // --- Clock (centre) ---
        ClockWidget {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        // Spacer droite
        Item {
            Layout.fillWidth: true
        }

        // --- Bouton dropdown volume (droite) ---
        Rectangle {
            id: menuButton
            width: 26
            height: 18
            radius: 4
            color: volumePopup.visible ? "#555555" : "#333333"

            MouseArea {
                anchors.fill: parent
                onClicked: volumePopup.visible = !volumePopup.visible
            }

            Text {
                anchors.centerIn: parent
                text: "⋮"
                color: "#ffffff"
                font.pixelSize: 12
            }
        }
    }

    // --------- POPUP VOLUME directement dans la barre ---------
    PopupWindow {
        id: volumePopup

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

                    value: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
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

                // Sync avec PipeWire (PwNodeAudio)
                Connections {
                    target: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
                            ? Pipewire.defaultAudioSink.audio
                            : null

                    // PwNodeAudio → volumesChanged / mutedChanged[web:94][web:167]
                    function onVolumesChanged() {
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
