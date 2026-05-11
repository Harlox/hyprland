import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "components"

ShellRoot {
    // PipeWire suivi global
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    TopBar { }
}
