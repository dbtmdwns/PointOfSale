import QtQuick 2.0
import "../singleton"

Item {
    property alias font: font
    property alias colors: colors
    property alias dimens: dimens



    Item{
        id: font
        property int size: App.fontSize
        property int buttonFontSize:  App.buttonFontSize

        property alias iconFont: fontAwesome
        FontLoader { id: fontAwesome; source: "../resources/fontawesome-webfont.ttf" }
    }

    Item{
        id: colors
        property string btnBackground: "#41414f"
        property string background: "#54545f"
        property string basicFontColor: "white"
        property string buttonPressed: "#212121"
        property string toolbarPrevIcon: "red"
        property string toolbarNextIcon: "green"

        property string toolbarText: "#aaaaff"
        property string stackViewBackground: "#110000"
        property string toolbarBackground: "black"
        property string buttonBackground: "#aaaaff"
    }

    Item{
        id: dimens
        property int toolbarHeight: 40
        property int backButtonWidth: toolbarHeight / 2
        property int backButtonHeight: toolbarHeight / 2
        property int nextButtonWidth: (toolbarHeight / 2)*3
        property int nextButtonHeight: toolbarHeight / 2

        property int leftMargin: 20
        property int rightMargin: 20

    }
}
