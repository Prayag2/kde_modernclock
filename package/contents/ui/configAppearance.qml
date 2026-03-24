import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: appearancePage
    property var activeFontField
    
    // properties
    property alias cfg_show_day: showDay.checked
    property alias cfg_show_date: showDate.checked
    property alias cfg_show_time: showTime.checked
    property alias cfg_day_font_size: dayFontSize.value
    property alias cfg_day_font_family: dayFontFamily.text
    property alias cfg_date_font_size: dateFontSize.value
    property alias cfg_date_font_family: dateFontFamily.text
    property alias cfg_time_font_size: timeFontSize.value
    property alias cfg_time_font_family: timeFontFamily.text
    property alias cfg_day_letter_spacing: dayLetterSpacing.value
    property alias cfg_day_font_color: dayFontColor.color
    property alias cfg_date_letter_spacing: dateLetterSpacing.value
    property alias cfg_time_letter_spacing: timeLetterSpacing.value
    property alias cfg_time_font_color: timeFontColor.color
    property alias cfg_use_24_hour_format: use24HourFormat.checked
    property alias cfg_time_character: timeCharacter.text
    property alias cfg_date_format: dateFormat.text
    property alias cfg_date_font_color: dateFontColor.color

    function openFontPicker(targetField, dialogTitle) {
        activeFontField = targetField
        fontPicker.title = dialogTitle
        var availableFonts = Qt.fontFamilies()
        fontFamilyCombo.model = availableFonts
        var selectedIndex = 0
        for (var i = 0; i < availableFonts.length; i++) {
            if (availableFonts[i] === targetField.text) {
                selectedIndex = i
                break
            }
        }
        fontFamilyCombo.currentIndex = selectedIndex
        fontPicker.open()
    }

    Kirigami.FormLayout {
        Title {
            title: i18n("Day")
        }
        RowLayout {
            Label {
                text: i18n("Show Day")
            }
            CheckBox {
                id: showDay
            }
        }
        NumberField {
            id: dayFontSize
            label: i18n("Font Size")
        }
        RowLayout {
            Label {
                text: i18n("Font Family")
            }
            TextField {
                id: dayFontFamily
                readOnly: true
                Layout.fillWidth: true
            }
            Button {
                text: i18n("Choose…")
                onClicked: appearancePage.openFontPicker(dayFontFamily, i18n("Select day font"))
            }
        }
        NumberField {
            id: dayLetterSpacing
            label: i18n("Letter Spacing")
        }
        ColorDial {
            id: dayFontColor
            color: cfg_day_font_color
        }
        Title {
            title: i18n("Date")
        }
        RowLayout {
            Label {
                text: i18n("Show Date")
            }
            CheckBox {
                id: showDate
            }
        }
        NumberField {
            id: dateFontSize
            label: i18n("Font Size")
        }
        RowLayout {
            Label {
                text: i18n("Font Family")
            }
            TextField {
                id: dateFontFamily
                readOnly: true
                Layout.fillWidth: true
            }
            Button {
                text: i18n("Choose…")
                onClicked: appearancePage.openFontPicker(dateFontFamily, i18n("Select date font"))
            }
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
        ColorDial {
            id: dateFontColor
            color: cfg_date_font_color
        }

        Title {
            title: i18n("Time")
        }
        RowLayout {
            Label {
                text: i18n("Show Time")
            }
            CheckBox {
                id: showTime
            }
        }
        NumberField {
            id: timeFontSize
            label: i18n("Font Size")
        }
        RowLayout {
            Label {
                text: i18n("Font Family")
            }
            TextField {
                id: timeFontFamily
                readOnly: true
                Layout.fillWidth: true
            }
            Button {
                text: i18n("Choose…")
                onClicked: appearancePage.openFontPicker(timeFontFamily, i18n("Select time font"))
            }
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
        ColorDial {
            id: timeFontColor
            color: cfg_time_font_color
        }
    }

    Dialog {
        id: fontPicker
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Label {
                text: i18n("Choose an installed font family")
            }

            ComboBox {
                id: fontFamilyCombo
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            if (activeFontField) {
                activeFontField.text = fontFamilyCombo.currentText
            }
        }
    }
}
