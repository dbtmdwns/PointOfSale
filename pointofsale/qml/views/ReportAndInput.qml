import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"
import "../views"
import "../styles"

Rectangle {
  id: root
  color: "transparent"

  property int buttonPanelRows: 6
  property int maxRows: 10
  property double singleItemHeight: (root.height - 10) / maxRows

  Component.onCompleted: {

    application.reportStore.styles = mainStyle;
    application.reportStore.reportView = reportView;
    application.reportStore.sum();
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
      height: singleItemHeight * (maxRows - buttonPanelRows - application.totalDisplayRows)

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
            font.pixelSize: mainStyle.font.size
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
          /*
          WebView {
            id: webview
            url: "about:blank"
            width: parent.width
            height: parent.height
          }
          */

       /*
          ScrollView {
            id: webview_scroll
            width: parent.width
            height: parent.height
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            WebEngineView {
              id: webview
              url: "about:blank"
              //url: "http://google.de"
            }
          }
          */
        }
      }



    }

    Rectangle {
      color: "transparent"
      width: root.width
      height: singleItemHeight * (buttonPanelRows)

      ButtonPanel {
        id: reportInput
          //height: (parent.height - parent.rowSpacing )/2
      }
    }

  }
}
