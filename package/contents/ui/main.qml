import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    // Initial desktop size only. Plasma may override these dimensions when
    // the user resizes the widget; we never bind the dimensions to its text.
    width: 490
    height: 155

    SystemPalette {
        id: sysPalette
        colorGroup: SystemPalette.Active
    }

    // Work around Qt 6 builds that return English names from Qt.formatDate().
    // QML Locale.dayName()/monthName() use JS indices: Sunday=0 / January=0.
    function formatLocalizedDate(date, pattern) {
        if (!date || !pattern)
            return ""
        // English is the original appearance; allow an explicit system-locale opt-in.
        var locale = root.useSystemDateLocale ? Qt.locale() : Qt.locale("en_US")
        var weekDay = date.getDay()
        var month = date.getMonth()
        var day = date.getDate()
        var year = date.getFullYear()
        var pad2 = function (n) { return n < 10 ? "0" + n : "" + n }
        var result = ""
        var quoted = false

        for (var i = 0; i < pattern.length;) {
            var ch = pattern.charAt(i)
            if (ch === "'") {
                if (i + 1 < pattern.length && pattern.charAt(i + 1) === "'") {
                    result += "'"
                    i += 2
                } else {
                    quoted = !quoted
                    i++
                }
                continue
            }
            if (quoted) {
                result += ch
                i++
                continue
            }
            var j = i + 1
            while (j < pattern.length && pattern.charAt(j) === ch)
                j++
            var length = j - i
            if (ch === "d" && length <= 4) {
                result += length === 4 ? locale.dayName(weekDay, Locale.LongFormat)
                    : length === 3 ? locale.dayName(weekDay, Locale.ShortFormat)
                    : length === 2 ? pad2(day) : day
            } else if (ch === "M" && length <= 4) {
                result += length === 4 ? locale.monthName(month, Locale.LongFormat)
                    : length === 3 ? locale.monthName(month, Locale.ShortFormat)
                    : length === 2 ? pad2(month + 1) : month + 1
            } else if (ch === "y" && length <= 4) {
                result += length === 2 ? pad2(year % 100) : year
            } else {
                result += pattern.substring(i, j)
            }
            i = j
        }
        return result
    }

    // The actual Plasma desktop AppletContainer catches mouse events, even
    // when the clock's labels are disabled. Find that container via its
    // editModeCondition property instead of assuming it is our direct parent.
    readonly property bool clickThrough: Plasmoid.configuration.click_through
    readonly property bool useSystemDateLocale: Plasmoid.configuration.use_system_date_locale
    readonly property bool shellEditMode: (Plasmoid.containment && Plasmoid.containment.corona)
        ? Plasmoid.containment.corona.editMode : false
    property var desktopContainer: null

    function findDesktopContainer() {
        var item = root.parent
        for (var depth = 0; item && depth < 12; depth++) {
            if ("editModeCondition" in item) {
                root.desktopContainer = item
                return
            }
            item = item.parent
        }
        root.desktopContainer = null
    }

    // Plasma assigns the item parent after creating the QML root.
    onParentChanged: root.findDesktopContainer()
    Component.onCompleted: Qt.callLater(root.findDesktopContainer)
    Timer {
        interval: 1250
        running: true
        repeat: false
        onTriggered: root.findDesktopContainer()
    }

    readonly property bool passMouseEvents: clickThrough && !shellEditMode && desktopContainer !== null

    // Tested approach on Plasma 6: a disabled applet container is omitted
    // from hit testing, so left clicks reach Folder View beneath it.
    Binding {
        target: root.desktopContainer
        property: "enabled"
        value: !root.clickThrough || root.shellEditMode
        when: root.desktopContainer !== null
    }

    // KDE also finds a right-click target by geometry. Suppress that hit
    // test using a zero-sized mask on the PlasmoidItem (not on the wrapper).
    Item {
        id: noHitMask
        width: 0
        height: 0
        visible: false
    }
    Binding {
        target: root
        property: "containmentMask"
        value: root.passMouseEvents ? noHitMask : null
    }

    // Diagnostics from 1.0.3 are no longer required now that passthrough works.

    // setting background as transparent with a drop shadow
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    
    // loading fonts
    FontLoader {
        id: font_anurati
        source: "../fonts/Anurati.otf"
    }
    FontLoader {
        id: font_poppins
        source: "../fonts/Poppins.ttf"
    }
    

    // setting preferred size
    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        id: clockView
        // Keep the 1.0.3 input passthrough (this is independent of size).
        enabled: !root.passMouseEvents

        // A desktop widget must remain freely resizable. Never derive its
        // minimum size from the label dimensions (which grow with the text).
        // Avoid preferred dimensions that can override saved desktop sizes.
        Layout.minimumWidth: 120
        Layout.minimumHeight: 50
        implicitWidth: container.width
        implicitHeight: container.implicitHeight

        // Updating time every minute
        Plasma5Support.DataSource {
            id: dataSource
            engine: "time"
            connectedSources: ["Local"]
            intervalAlignment: Plasma5Support.Types.AlignToMinute
            interval: 60000

            property bool use24HourFormat: plasmoid.configuration.use_24_hour_format
            property string timeCharacter: plasmoid.configuration.time_character
            property string dateFormat: plasmoid.configuration.date_format
            property bool useSystemDateLocale: root.useSystemDateLocale

            onUse24HourFormatChanged: dataChanged()
            onTimeCharacterChanged: dataChanged()
            onDateFormatChanged: dataChanged()
            onUseSystemDateLocaleChanged: dataChanged()

            onDataChanged: {
                var time_format = use24HourFormat ? "hh:mm" : "hh:mm AP"
                var localData = dataSource.data["Local"]
                if (!localData || !localData["DateTime"])
                    return
                var curDate = localData["DateTime"]
                display_day.text = root.formatLocalizedDate(curDate, "dddd").toUpperCase()
                display_date.text = root.formatLocalizedDate(curDate, dateFormat).toUpperCase()
                display_time.text = timeCharacter + " " + Qt.formatTime(curDate, time_format) + " " + timeCharacter
            }

            
        }

        // Font advance widths can include invisible letter-spacing after the
        // final glyph. Center the visible ink, not just the text layout box.
        TextMetrics {
            id: dayInk
            font: display_day.font
            text: display_day.text
        }
        TextMetrics {
            id: dateInk
            font: display_date.font
            text: display_date.text
        }
        TextMetrics {
            id: timeInk
            font: display_time.font
            text: display_time.text
        }

        // Main Content
        Column {
            id: container

            // All lines have one natural width and a common visual center.
            // This width is based on unscaled text metrics and does NOT follow
            // the assigned widget width, preventing a binding loop.
            anchors.centerIn: parent
            spacing: 5
            width: Math.max(
                display_day.visible ? display_day.implicitWidth : 0,
                display_date.visible ? display_date.implicitWidth : 0,
                display_time.visible ? display_time.implicitWidth : 0
            ) + 14

            // Resize the complete clock, including spacing, when the desktop
            // widget is dragged larger or smaller. Its center remains fixed.
            transformOrigin: Item.Center
            scale: Math.max(0.05, Math.min(
                clockView.width / Math.max(1, width + 8),
                clockView.height / Math.max(1, implicitHeight + 8)
            ))

            // The day ("Tuesday", "Wednesday" etc..)
            PlasmaComponents.Label {
                id: display_day
                
                // visible
                visible: plasmoid.configuration.show_day

                // font settings
                font.pixelSize: plasmoid.configuration.day_font_size
                font.letterSpacing: plasmoid.configuration.day_letter_spacing
                font.family: plasmoid.configuration.day_font_family
                    ? plasmoid.configuration.day_font_family : font_anurati.name
                color: plasmoid.configuration.follow_system_text_color
                    ? sysPalette.windowText
                    : plasmoid.configuration.day_font_color
                width: container.width
                // Optical midpoint of visible glyphs (accounts for font
                // bearings and the invisible trailing letter spacing).
                transform: Translate {
                    x: dayInk.advanceWidth / 2 -
                       (dayInk.tightBoundingRect.x + dayInk.tightBoundingRect.width / 2)
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap 
            }

            // The Date
            PlasmaComponents.Label {
                id: display_date

                // visibility
                visible: plasmoid.configuration.show_date

                // font settings
                font.pixelSize: plasmoid.configuration.date_font_size
                font.letterSpacing: plasmoid.configuration.date_letter_spacing
                font.family: plasmoid.configuration.date_font_family
                    ? plasmoid.configuration.date_font_family : font_poppins.name
                color: plasmoid.configuration.follow_system_text_color
                    ? sysPalette.windowText
                    : plasmoid.configuration.date_font_color
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                width: container.width
                // Optical midpoint of visible glyphs (accounts for font
                // bearings and the invisible trailing letter spacing).
                transform: Translate {
                    x: dateInk.advanceWidth / 2 -
                       (dateInk.tightBoundingRect.x + dateInk.tightBoundingRect.width / 2)
                }
            }

            // The Time
            PlasmaComponents.Label {
                id: display_time

                // visibility
                visible: plasmoid.configuration.show_time

                // font settings
                font.pixelSize: plasmoid.configuration.time_font_size
                font.family: plasmoid.configuration.time_font_family
                    ? plasmoid.configuration.time_font_family : font_poppins.name
                color: plasmoid.configuration.follow_system_text_color
                    ? sysPalette.windowText
                    : plasmoid.configuration.time_font_color
                font.letterSpacing: plasmoid.configuration.time_letter_spacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                width: container.width
                // Optical midpoint of visible glyphs (accounts for font
                // bearings and the invisible trailing letter spacing).
                transform: Translate {
                    x: timeInk.advanceWidth / 2 -
                       (timeInk.tightBoundingRect.x + timeInk.tightBoundingRect.width / 2)
                }
            }

        }
    }
}
