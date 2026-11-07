import QtQml 2.15
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    SystemPalette {
        id: sysPalette
        colorGroup: SystemPalette.Active
    }

    // Work around Qt 6 builds that return English names from Qt.formatDate().
    // QML Locale.dayName()/monthName() use JS indices: Sunday=0 / January=0.
    function formatLocalizedDate(date, pattern) {
        if (!date || !pattern)
            return ""
        var locale = Qt.locale()
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

    // Click-through only applies to Plasma desktop applet containers.
    // Plasma edit mode keeps the clock movable and configurable.
    readonly property bool clickThrough: Plasmoid.configuration.click_through
    readonly property bool shellEditMode: (Plasmoid.containment && Plasmoid.containment.corona)
        ? Plasmoid.containment.corona.editMode : false
    readonly property bool desktopAppletContainer: root.parent !== null
        && ("editModeCondition" in root.parent)

    Binding {
        target: root.parent
        property: "enabled"
        value: !root.clickThrough || root.shellEditMode
        when: root.desktopAppletContainer
    }

    Item {
        id: noHitMask
        width: 0
        height: 0
        visible: false
    }

    // Also suppress the applet's right-click context menu hit test.
    Binding {
        target: root
        property: "containmentMask"
        value: (root.clickThrough && root.desktopAppletContainer && !root.shellEditMode)
            ? noHitMask : null
    }
    
    
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

        // applet default size
        Layout.minimumWidth: container.implicitWidth
        Layout.minimumHeight: container.implicitHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

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
            
            onUse24HourFormatChanged: dataChanged()
            onTimeCharacterChanged: dataChanged()
            onDateFormatChanged: dataChanged()

            onDataChanged: {
                var time_format = use24HourFormat ? "hh:mm" : "hh:mm AP"
                var curDate = dataSource.data["Local"]["DateTime"]
                display_day.text = root.formatLocalizedDate(curDate, "dddd").toUpperCase()
                display_date.text = root.formatLocalizedDate(curDate, dateFormat).toUpperCase()
                display_time.text = timeCharacter + " " + Qt.formatTime(curDate, time_format) + " " + timeCharacter
            }

            
        }

        // Main Content
        Column {
            id: container

            // Column settings
            anchors.centerIn: parent
            spacing: 5

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
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter 
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
                anchors.horizontalCenter: parent.horizontalCenter
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
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
