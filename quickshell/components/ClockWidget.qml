import QtQuick

Text {
    id: clock
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
