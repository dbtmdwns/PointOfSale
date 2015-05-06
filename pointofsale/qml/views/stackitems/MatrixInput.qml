import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../../views"
import "../../controlls"
import "../../singleton"
import "../matrix"
import "../plugins"
import ".."

StackViewItem {
  id: framedView
  width: parent.width
  height: parent.height
  title: qsTr("Kasse")

  property int spacing: 8
  property int buttonPanelColumns: 5
  property int rows: 10
  property int maxColumns: 8 + App.waregroupColumns + buttonPanelColumns + App.leftSideColumns + App.rightSideColumns
  property int itemWidth: (framedView.width - spacing * maxColumns) / maxColumns

  function keyInput(event) {
    //console.log(event.key,Qt.Key_Enter,Qt.Key_Return);
    if (16777250===event.key){
      return;
    }
    switch (event.key) {

      case Qt.Key_Backspace:
        ReportStore.cmd('BACK', '');
        break;
      case Qt.Key_Enter:
      case Qt.Key_Return:
        ReportStore.cmd('ENTER', '');
        break;
      default:
        ReportStore.cmd('NUM', event.text,'keyboard');
        break;
    }
  }

  function textInput(txt) {

  }

  Component.onCompleted: {

  }

  Rectangle {
    id: rightFrame
    width: framedView.itemWidth * App.leftSideColumns
    height: framedView.height

      color: "transparent"
    Image {
      width: parent.width
        //anchors.fill: parent
      fillMode: Image.PreserveAspectFit
      source: App.left_logo_file
      Component.onCompleted: {}
    }
  }

  Rectangle {
    id: view
    clip: true
    color: "transparent"
    width: framedView.width - rightFrame.width - leftFrame.width
    height: rightFrame.height
    x: rightFrame.width
    y: 0



    Rectangle {
      id: mmFrame
      x: spacing
      y: spacing
      color: "transparent"
      width: view.width / (8 + App.waregroupColumns + buttonPanelColumns) * (8 + App.waregroupColumns)
      height: view.height - spacing * 2
      clip: true

      Rectangle {
        id: mFrame
        opacity: ((ReportStore.currentMode === 'amount') || (ReportStore.currentMode === 'find')) ? 1 : 0
        Behavior on opacity {
          OpacityAnimator {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        Behavior on x {
          NumberAnimation {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        color: "transparent"
        x: ((ReportStore.currentMode === 'amount') || (ReportStore.currentMode === 'find')) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height


        Rectangle {
          id: waregroupChooser
          x: spacing
          y: 0 //spacing
          color: "transparent"
          width: (parent.width - (5 + App.waregroupColumns) * spacing) / (5 + App.waregroupColumns) * App.waregroupColumns
          height: mFrame.height - relationChooser.height - spacing * 2
          Matrix {
            id: waregroupMatrix
            anchors.fill: parent
            template: "{warengruppe}"
            rows: framedView.rows
            columns: 1
            Component.onCompleted: {
              waregroupMatrix.addList(ReportStore.getWarengrupen());
            }
            onSelected: {
              articleMatrix.defaultBackgroundColor = item.displayBackgroundColor;
              articleMatrix.addList(ReportStore.getArtikel(item.warengruppe));
            }
          }

        }

        Rectangle {
          id: itemChooser
          color: "transparent"
          x: waregroupChooser.width + waregroupChooser.x + spacing
          y: 0 //spacing
            //width: itemWidth*App.articleColumns
            //width: (parent.width-(App.articleColumns + App.waregroupColumns)*spacing)/(App.articleColumns + App.waregroupColumns)*App.articleColumns
          width: (parent.width - (8 + App.waregroupColumns) * spacing) / (8 + App.waregroupColumns) * 8
          height: mFrame.height - relationChooser.height - spacing * 2


          Matrix {
            id: articleMatrix
            anchors.fill: parent
            template: "{gruppe}<br/>{euro(brutto)}"
            rows: framedView.rows
            columns: 2
            Component.onCompleted: {
              ReportStore.onFind = function(str){
                ReportStore.currentMode = 'find';
                var l = (ReportStore.findArticle(str));
                articleMatrix.addList(l);
              }
            }
            onSelected: {
              ReportStore.add(item);
            }
          }

        }


        Rectangle {
          id: relationChooser
          color: "transparent"
          x: spacing
          y: itemChooser.y + itemChooser.height + spacing
          width: (mFrame.width - spacing * 2)
          height: mFrame.height * 0.15

          Matrix {
            id: relationMatrix
            anchors.fill: parent
            template: "{name}"
            columns: 4
            Component.onCompleted: {
              relationMatrix.addList(App.relations);
              ReportStore.cmd("SET RELATION", App.relations[0]);
            }
            onSelected: {
              ReportStore.cmd("SET RELATION", item);
              articleMatrix.addList(ReportStore.getArtikel(ReportStore._warengruppe));

            }
          }
        }


      }

      Rectangle {
        id: mFrame2
        opacity: ((ReportStore.currentMode === 'pay')) ? 1 : 0
        Behavior on opacity {
          OpacityAnimator {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        Behavior on x {
          NumberAnimation {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        color: "transparent"
        x: ((ReportStore.currentMode === 'pay')) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height

        Rectangle {
          id: givenDisplay
          width: parent.width
          y: 10
          height: mFrame2.height/9
          color: "white"
          radius: 5
          Text {
            id: givenText
            font.family: "Helvetica"
            font.pixelSize: mainStyle.font.size
            width: parent.width - 10
            height: parent.height - 10
            anchors.centerIn: parent
            clip: true

              verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

              font.pointSize: givenDisplay.height * 0.3
            color: (ReportStore.given < ReportStore.total) ? "red" : "black"
            text: "Gegeben: " + (ReportStore.given.toFixed(2))
          }
        }

        Rectangle {
          id: givebackDisplay
          y: givenDisplay.y + givenDisplay.height + 10
          width: parent.width
          height: mFrame2.height/9
          color: "white"
          radius: 5
          Text {
            id: givebackText
            font.family: "Helvetica"
            font.pixelSize: mainStyle.font.size
            width: parent.width - 10
            height: parent.height - 10
            anchors.centerIn: parent
            clip: true

              verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

              font.pointSize: givebackDisplay.height * 0.3
            color: ((ReportStore.given - ReportStore.total) < 0) ? "red" : "black"
            text: "Rückgeld: " + ((ReportStore.given - ReportStore.total).toFixed(2))
          }
        }

        BezahlenMatrix {
          y: givebackDisplay.y + givebackDisplay.height + 10
          width: parent.width
          height: mFrame2.height/9 * 5
          onFieldSelected: {
            ReportStore.cmd(item.cmd, item.val);
          }
        }
      }




      Rectangle {
        id: simpleReferenz
        opacity: ((ReportStore.currentMode === 'Referenz')) ? 1 : 0
        Behavior on opacity {
          OpacityAnimator {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        Behavior on x {
          NumberAnimation {
            easing.type: Easing.InCubic;
            duration: 250
          }
        }
        color: "transparent"
        x: ((ReportStore.currentMode === 'Referenz')) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height
        ReferenzPlugin {
          y: 0
          x: 0
          width: parent.width
          height: parent.height
          color: "transparent"
        }
      }
    }

    ReportAndInput {
      id: rai
      x: mmFrame.width + mmFrame.x + spacing
      y: spacing
      width: view.width / (8 + App.waregroupColumns + buttonPanelColumns) * (buttonPanelColumns) - spacing * (8 + App.waregroupColumns)
      height: view.height - spacing * 2
    }





    Rectangle {
      anchors.centerIn: view
      opacity: (ReportStore.message === "") ? 0 : 1
      color: "white"
      radius: 5
      width: view.width * 0.30
      height: view.height * 0.10
      Behavior on opacity {
        OpacityAnimator {
          easing.type: Easing.InCubic;
          duration: 150
        }
      }
      Text {
        anchors.centerIn: parent
        text: ReportStore.message
      }
    }
    Rectangle {
      anchors.centerIn: view
      opacity: (ReportStore.findString === "") ? 0 : 1
      color: "white"
      radius: 5
      width: view.width * 0.30
      height: view.height * 0.10
      Behavior on opacity {
        OpacityAnimator {
          easing.type: Easing.InCubic;
          duration: 150
        }
      }
      Text {
        anchors.centerIn: parent
        text: "Suche: "+ReportStore.findString
      }
    }
  }
/*

  BelegeMatrix {
    id: leftFrame
    x: view.width + rightFrame.width
    width: itemWidth * App.rightSideColumns
    height: framedView.height
    //color: "transparent"
    anchors.margins: spacing
    Behavior on opacity {
      OpacityAnimator {
        easing.type: Easing.InCubic;
        duration: 500
      }
    }
    opacity: ReportStore.reportMode ? 1 : 0
      //anchors.fill: parent
      //anchors.margins: spacing
    onFieldSelected: {
      ReportStore.cmd("OPENREPORT", item);
    }
  }
  */
  Rectangle {
    id: leftFrame
    x: view.width + rightFrame.width
    width: ReportStore.reportMode ? ( framedView.itemWidth * App.rightSideColumns) : 0
    height: framedView.height
    Behavior on opacity {
      OpacityAnimator {
        easing.type: Easing.InCubic;
        duration: 500
      }
    }
    color: "transparent"
    opacity: ReportStore.reportMode ? 1 : 0
    Matrix {
      id: leftFrameMatrix
      anchors.fill: parent

      columns: 1
      rows: framedView.rows
      template: "{belegnummer} {euro(brutto)}"

      Component.onCompleted: {
        ReportStore.onAddedReport = function(item){
          function compare(a,b) {
            if (a.belegnummer < b.belegnummer)
               return 1;
            if (a.belegnummer > b.belegnummer)
              return -1;
            return 0;
          }
          leftFrameMatrix.addList(ReportStore.oldReports.sort(compare).slice(0,30));
        };
      }

      onSelected: {
        ReportStore.cmd("OPENREPORT", item.belegnummer);
      }
    }
  }

}
