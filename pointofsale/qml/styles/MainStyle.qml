import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


Item {
  property alias font: font
  property alias colors: colors
  property alias dimens: dimens



  Item {
    id: font
    property int size: application.fontSize
    property int buttonFontSize: application.buttonFontSize

      property alias iconFont: fontAwesome
    FontLoader {
      id: fontAwesome;source: "../fontawesome-webfont.ttf"
    }
  }

  Item {
    id: colors
    property string btnBackground: "#41414f"
    property string background: "#54545f"

    property string basicFontColor: application.basicFontColor
    property string basicStyleColor: application.basicStyleColor

    property string buttonPressed: "#212121"
    property string toolbarPrevIcon: "#eeffffff"
    property string toolbarNextIcon: "green"

    property string toolbarText: "#aaaaff"
    property string stackViewBackground: "#110000"
    property string toolbarBackground: "black"
    property string buttonBackground: "#aaaaff"
    property string listDelimiter: "#4242a6"
  }

  Item {
    id: dimens
    property int toolbarHeight: (application.dpi/113) * 40
    property int backButtonWidth: toolbarHeight / 2
    property int backButtonHeight: toolbarHeight / 2
    property int nextButtonWidth: (toolbarHeight / 2) * 3
    property int nextButtonHeight: toolbarHeight / 2
    property int iconWidth: 30
    property int leftMargin: (application.dpi/113) * 20
    property int rightMargin: (application.dpi/113) * 20

  }
}
