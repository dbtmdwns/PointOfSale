import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../controlls"

StackViewItem {
  id: framedView
  width: parent.width
  height: parent.height
  title: qsTr("Kasse -> Kalendar")

  property int spacing: 8
  property int layoutWUnit: (parent.width)/12
  property int layoutHUnit: (parent.height)/12

  Calendar {
  
    width: parent.width
    height: parent.height

  }
}
