import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

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

    PopupWindow {
        id: volumePopup

        anchor.window: bar
        anchor.rect.x: bar.width - width - 8
        anchor.rect.y: bar.height

        visible: false

        implicitWidth: 220
        implicitHeight: 70
        color: "#181818"

        VolumeMenu { }   // tout le contenu audio est dans ce composant
    }
}