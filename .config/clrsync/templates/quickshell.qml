pragma Singleton
import QtQuick

QtObject {
    id: theme
    readonly property color background: '{background}'
    readonly property color border: '{border}'
    readonly property color borderFocused: Qt.lighter(primary, 1.2)
    readonly property color foreground: '{foreground}'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.5)
    readonly property color primary: '{accent}'
    readonly property color primaryMuted: Qt.darker(primary, 2.5)
    readonly property color secondary: '{accent_secondary}'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.5)

    readonly property color warning: '{warning}'
    readonly property color success: '{success}'
    readonly property color error: '{error}'

    readonly property color surfaceBase: '{surface}'
    readonly property color surfaceContainer: '{surface_variant}'
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: '{on_surface_variant}'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: primaryMuted

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}





