import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../controlls"
import "../views"
import "../styles"

Rectangle {
  id: root
  color: "transparent"

  property int buttonPanelRows: 6
  property int maxRows: 10
  property bool main: true
  property double singleItemHeight: (root.height - 10) / maxRows

  property alias view: reportView
  
  Component.onCompleted: {

    if (main===true){
      application.reportStore.styles = mainStyle;
      application.reportStore.reportView = reportView;
      application.reportStore.sum();
    }
  }


  function getReportHTML() {
    console.log('ReportAndInput','line', 36,'fix me');
  }


  Column {
    id: mcol
    anchors.fill: parent
    spacing: 5

    Rectangle {
      id: reportDisplay
      color: "transparent"
      width: root.width
      height: parent.height/2
      //height: singleItemHeight * (maxRows - buttonPanelRows - application.totalDisplayRows)

      Column {
        id: rep
        anchors.fill: parent
        spacing: 5

        Rectangle {
          id: numberDisplay
          width: reportDisplay.width
          height: singleItemHeight * application.totalDisplayRows
          color: "white"
          radius: 5
          Text {
            id: reportText
            font.family: "Helvetica"
            width: numberDisplay.width - 10
            height: numberDisplay.height - 10
            anchors.centerIn: parent
            clip: true

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

            font.pointSize: numberDisplay.height * 0.4
            color: (application.reportStore.lastTotal === 0) ? "black" : "black"
            text: (application.reportStore.lastTotal === 0) ? (application.reportStore.total.toFixed(2) + " €") : ("" + application.reportStore.lastTotal.toFixed(2) + " €")
          }
        }


        Rectangle {
          radius: 5
          width: root.width
          height: reportDisplay.height - numberDisplay.height - rep.spacing
          clip: true

          ReportView{
            id: reportView
            width: parent.width
            height: parent.height
          }

        }
      }



    }

    Rectangle {
      color: "transparent"
      width: root.width
      height: parent.height/2

      ButtonPanel {
        id: reportInput
          //height: (parent.height - parent.rowSpacing )/2
      }
    }

  }
}
