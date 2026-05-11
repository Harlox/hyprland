import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Services.Pipewire

Rectangle {
    id: root
    color: "#181818"
    radius: 6
    border.color: "#444444"
    border.width: 1

    // petite marge interne
    anchors.fill: parent
    anchors.margins: 0

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
                color: "#ffffff"
                font.pixelSize: 12
                text: Math.round(volSlider.value * 100) + " %"
            }
        }

        // Affichage "no audio" si PipeWire n'a pas de sink par défaut
        Text {
            visible: !(Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
            color: "#ff8080"
            font.pixelSize: 11
            text: "Aucun périphérique audio"
        }

        Slider {
            id: volSlider

            Layout.fillWidth: true

            from: 0.0
            to: 1.0
            stepSize: 0.01

            enabled: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio

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

        // Sync avec PipeWire (PwNodeAudio) – pattern recommandé par la doc.[web:94][web:167]
        Connections {
            target: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
                    ? Pipewire.defaultAudioSink.audio
                    : null

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