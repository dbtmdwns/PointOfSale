import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../controlls"
import "../../styles"

Rectangle {

  width: parent.width
  height: parent.height

  Text {
    color: "white"
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Referenz: " + application.reportStore.referenzString
  }

}
