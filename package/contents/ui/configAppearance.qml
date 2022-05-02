import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

Column {
    id: appearancePage
    
    // properties
    property alias cfg_day_font_size: dayFontSize.value
    property alias cfg_date_font_size: dateFontSize.value
    property alias cfg_time_font_size: timeFontSize.value
    property alias cfg_day_letter_spacing: dayLetterSpacing.value
    property alias cfg_date_letter_spacing: dateLetterSpacing.value
    property alias cfg_time_letter_spacing: timeLetterSpacing.value
    property alias cfg_font_color: colordialog.color
    property alias cfg_use_24_hour_format: use24HourFormat.checked
    property alias cfg_time_character: timeCharacter.text
    property alias cfg_date_format: dateFormat.text

    // size
    spacing: 5 
     
    Title {
        title: i18n("Day")
    }
    NumberField {
        id: dayFontSize
        label: i18n("Font Size")
    }
    NumberField {
        id: dayLetterSpacing
        label: i18n("Letter Spacing")
    }
   
    Title {
        title: i18n("Date")
    }
    NumberField {
        id: dateFontSize
        label: i18n("Font Size")
    }
    NumberField {
        id: dateLetterSpacing
        label: i18n("Letter Spacing")
    }
    RowLayout {
        Label {
            text: i18n("Date format")
        }
        TextField {
            id: dateFormat
        }
    }

    
    Title {
        title: i18n("Time")
    }
    NumberField {
        id: timeFontSize
        label: i18n("Font Size")
    }
    NumberField {
        id: timeLetterSpacing
        label: i18n("Letter Spacing")
    }
    RowLayout {
        Label {
            text: i18n("Use 24 hour format")
        }
        CheckBox {
            id: use24HourFormat
        }
    }
    RowLayout {
        Label {
            text: i18n("Style Character")
        }
        TextField {
            id: timeCharacter
            maximumLength: 1
        }
    }
    
    
    Title {
        title: i18n("Font Settings") 
    }
    RowLayout {
        Label {
            text: i18n("Font Color")
        }             
        Rectangle {
            id: colorbutton
            height: PlasmaCore.Units.gridUnit * 1.3; width: height
            border.width: 1
            border.color: "gray"
            color: cfg_font_color
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colordialog.visible=true
                }
            }
        }
    }
    ColorDialog {
        id: colordialog
        title: i18n("Select a color")
        onAccepted: {
            cfg_font_color=color
        }
    }
}
