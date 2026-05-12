import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Services.Pipewire
import Quickshell.Networking

Rectangle {
    id: root
    color: "#181818"
    radius: 6
    border.color: "#444444"
    border.width: 1

    anchors.fill: parent

    // Détection simple Ethernet / Wi‑Fi / rien
    readonly property string networkStatus: {
        for (let i = 0; i < Networking.devices.length; ++i) {
            const d = Networking.devices[i];
            if (d.type === DeviceType.Ethernet && d.connected)
                return "Ethernet";
            if (d.type === DeviceType.Wifi && d.connected)
                return "Wi‑Fi";
        }
        return "Non connecté";
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // ----------------- VOLUME -----------------
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

        Slider {
            id: volSlider

            Layout.fillWidth: true

            from: 0.0
            to: 1.0
            stepSize: 0.01

            enabled: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio

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

        // Sync PipeWire (PwNodeAudio) [volumesChanged / mutedChanged]
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

        // ----------------- RÉSEAU -----------------
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Réseau"
                color: "#ffffff"
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            Text {
                color: "#bbbbbb"
                font.pixelSize: 11
                text: networkStatus
            }
        }

        // Ligne Wi‑Fi (toggle software) [wifiEnabled]
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Wi‑Fi"
                color: "#ffffff"
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            Switch {
                id: wifiSwitch
                checked: Networking.wifiEnabled
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        // Liste des réseaux Wi‑Fi
        // On parcourt Networking.devices et on ne montre que les devices Wi‑Fi
        Repeater {
            Layout.fillWidth: true
            model: Networking.devices

            delegate: ColumnLayout {
                required property var modelData    // Device

                visible: modelData.type === DeviceType.Wifi

                // Liste des SSID pour ce device
                Repeater {
                    Layout.fillWidth: true

                    // Tri : connectés en premier, puis par puissance de signal [network.qml officiel]
                    model: {
                        if (modelData.type !== DeviceType.Wifi)
                            return [];

                        return [...modelData.networks.values].sort((a, b) => {
                            if (a.connected !== b.connected)
                                return b.connected - a.connected;
                            return b.signalStrength - a.signalStrength;
                        });
                    }

                    delegate: Rectangle {
                        required property var modelData   // réseau Wi‑Fi

                        Layout.fillWidth: true
                        height: 32
                        radius: 4
                        color: modelData.connected ? "#304050" : "#222222"
                        border.color: "#555555"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.known ? "Enregistré" : ""
                                        color: "#aaaaaa"
                                        font.pixelSize: 10
                                    }
                                }

                                RowLayout {
                                    spacing: 4

                                    Text {
                                        text: "Sécurité: " + WifiSecurityType.toString(modelData.security)
                                        color: "#aaaaaa"
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: "| Signal: " + Math.round(modelData.signalStrength * 100) + " %"
                                        color: "#aaaaaa"
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 4

                                Button {
                                    text: modelData.connected ? "Déconnecter" : "Connecter"
                                    onClicked: {
                                        if (modelData.connected)
                                            modelData.disconnect();
                                        else
                                            modelData.connect();
                                    }
                                }

                                Button {
                                    visible: modelData.known
                                    text: "Oublier"
                                    onClicked: modelData.forget()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
