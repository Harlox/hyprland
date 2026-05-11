import QtQuick
import QtQuick.Layouts

import Quickshell.Hyprland

RowLayout {
    id: root
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
