pragma Singleton
import QtQuick

QtObject {
    id: theme
    readonly property color background: '#1C0905'
    readonly property color border: '#782515'
    readonly property color borderFocused: Qt.lighter(primary, 1.2)
    readonly property color foreground: '#DB9A84'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.5)
    readonly property color primary: '#73281B'
    readonly property color primaryMuted: Qt.darker(primary, 2.5)
    readonly property color secondary: '#73281B'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.5)

    readonly property color warning: '#74281A'
    readonly property color success: '#73281B'
    readonly property color error: '#6A2217'

    readonly property color surfaceBase: '#1C0905'
    readonly property color surfaceContainer: '#1C0905'
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: '#DB9A84'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: primaryMuted

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}

