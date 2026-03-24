import QtQml 2.15
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    function resolvedFontFamily(configuredFamily, fallbackFamily) {
        var family = (configuredFamily || "").trim()
        return family.length > 0 ? family : fallbackFamily
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
        function updateDisplay() {
            var time_format = plasmoid.configuration.use_24_hour_format ? "hh:mm" : "hh:mm AP"
            var curDate = dataSource.data["Local"]["DateTime"]
            if (!curDate) {
                curDate = new Date()
            }
            display_day.text = Qt.formatDate(curDate, "dddd").toUpperCase()
            display_date.text = Qt.formatDate(curDate, plasmoid.configuration.date_format).toUpperCase()
            display_time.text = plasmoid.configuration.time_character + " " + Qt.formatTime(curDate, time_format) + " " + plasmoid.configuration.time_character
            display_day.font.family = root.resolvedFontFamily(plasmoid.configuration.day_font_family, font_anurati.name)
            display_date.font.family = root.resolvedFontFamily(plasmoid.configuration.date_font_family, font_poppins.name)
            display_time.font.family = root.resolvedFontFamily(plasmoid.configuration.time_font_family, font_poppins.name)
        }

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

            onDataChanged: {
                updateDisplay()
            }
        }

        Connections {
            target: plasmoid.configuration
            function onValueChanged(key, value) {
                if (key === "day_font_family" || key === "date_font_family" || key === "time_font_family" ||
                    key === "date_format" || key === "time_character" || key === "use_24_hour_format") {
                    updateDisplay()
                }
            }
        }

        Component.onCompleted: updateDisplay()

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
                color: plasmoid.configuration.day_font_color
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
                color: plasmoid.configuration.date_font_color
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
                color: plasmoid.configuration.time_font_color
                font.letterSpacing: plasmoid.configuration.time_letter_spacing
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
