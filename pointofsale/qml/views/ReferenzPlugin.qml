import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../controlls"
import "../styles"
import "../singleton"

Rectangle {

  width: parent.width
  height: parent.height

  Text {
    color: "white"
    text: "Referenz: " + ReportStore.referenzString
  }

}
