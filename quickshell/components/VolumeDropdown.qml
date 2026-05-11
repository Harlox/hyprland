import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Services.Pipewire

PopupWindow {
    id: dropdown

    // Fenêtre à laquelle on s'ancre (la barre)
    property Item anchorWindow: null

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow ? anchorWindow.width - width - 8 : 0
    anchor.rect.y: anchorWindow ? anchorWindow.height : 0

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

                // valeur initiale
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

            Connections {
                // PwNodeAudio ou null
                target: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
                        ? Pipewire.defaultAudioSink.audio
                        : null

                // PwNodeAudio -> volumesChanged pour le volume moyen[web:94][web:164]
                function onVolumesChanged() {
                    const sink = Pipewire.defaultAudioSink
                    if (!sink || !sink.audio)
                        return

                    const v = sink.audio.volume
                    if (Math.abs(volSlider.value - v) > 0.001)
                        volSlider.value = v
                }

                // PwNodeAudio -> mutedChanged pour l’état mute[web:94][web:167]
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
