import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2



import "../../views"
import "../../controlls"

import "../matrix"
import "../plugins"



StackViewItem {
  id: framedView
  width: parent.width
  height: parent.height
  title: qsTr("Kasse")

  property int spacing: 8
  property int layoutWUnit: (parent.width)/12
  property int layoutHUnit: (parent.height)/12


  function keyInput(event) {

    console.log(event.key,Qt.Key_Enter,Qt.Key_Return);
    if (16777250===event.key){
      return;
    }
    switch (event.key) {

      case Qt.Key_Backspace:
        application.reportStore.cmd('BACK', '');
        break;

      case 44:
      case 46:
        application.reportStore.cmd('SEP', '');
        break;

      case 10:
      case 13:
      case 16777249:
      case Qt.Key_Enter:
      case Qt.Key_Return:
        application.reportStore.findString=application.reportStore.findString.replace(/[^0-9a-z]/gi,'')
        application.reportStore.cmd('ENTER', '');
        break;
      default:
        application.reportStore.cmd('NUM', event.text,'keyboard');
        break;
    }
  }

  function textInput(txt,enter) {

  }

  Component.onCompleted: {

    if ((typeof application.reportStore.modeReferences=='undefined') || (application.reportStore.modeReferences==null)){
      application.reportStore.modeReferences= {};
    }
    application.reportStore.modeReferences[simpleReferenz.plugin.modeText] = simpleReferenz.plugin.cmd;
    application.reportStore.modeReferences[gutscheinEinloesen.plugin.modeText] = gutscheinEinloesen.plugin.cmd;
    application.reportStore.modeReferences[gutscheinAusgabe.plugin.modeText] = gutscheinAusgabe.plugin.cmd;

  }

  function update(){
    waregroupMatrix.addList(application.reportStore.getWarengrupen());
  }



  Rectangle {
    id: waregroupChooser
    visible: ( (application.reportStore.currentMode === 'amount') || (application.reportStore.currentMode === 'price') ) ? true : false

    x: spacing+(layoutWUnit*application.matrix.waregroupX)
    y: spacing+(layoutHUnit*application.matrix.waregroupY)
    width: layoutWUnit * application.matrix.waregroupWidth -spacing
    height: layoutHUnit * application.matrix.waregroupHeight -spacing

    color: "transparent"
    Matrix {
      id: waregroupMatrix
      anchors.fill: parent
      template: "{warengruppe}"
      rows: application.waregroupRowCount
      columns: application.waregroupColCount
      Component.onCompleted: {
        waregroupMatrix.addList(application.reportStore.getWarengrupen());
      }
      onSelected: {
        articleMatrix.defaultBackgroundColor = item.displayBackgroundColor;
        application.reportStore.getArtikel(item.warengruppe,function(res){
          articleMatrix.addList(res);
        })
      }
    }

  }


  Rectangle {
    id: itemChooser
    color: "transparent"
    visible: ( (application.reportStore.currentMode === 'amount') || (application.reportStore.currentMode === 'price') ) ? true : false

    x: spacing+(layoutWUnit*application.matrix.articleX)
    y: spacing+(layoutHUnit*application.matrix.articleY)
    width: layoutWUnit * application.matrix.articleWidth -spacing
    height: layoutHUnit * application.matrix.articleHeight -spacing


    Matrix {
      id: articleMatrix
      anchors.fill: parent
      template: "{gruppe}<br/>{euro(brutto)}"
      rows: application.articleRowCount
      columns: application.articleColCount
      Component.onCompleted: {
        application.reportStore.onFind = function(str){
          application.reportStore.currentMode = 'find';
          (application.reportStore.findArticle(str,function(l){
            articleMatrix.addList(l);
            application.reportStore.currentMode = 'amount';
          }));

        }
      }
      onSelected: {
        application.reportStore.add(item);
      }
    }

  }




  Rectangle {
    id: relationChooser

    visible: ( (application.reportStore.currentMode === 'amount') || (application.reportStore.currentMode === 'price') ) ? true : false

    x: spacing+(layoutWUnit*application.matrix.relationX)
    y: spacing+(layoutHUnit*application.matrix.relationY)
    width: layoutWUnit * application.matrix.relationWidth -spacing
    height: layoutHUnit * application.matrix.relationHeight -spacing

    color: "transparent"
    Matrix {
      id: relationMatrix
      anchors.fill: parent
      template: "{name}"

      rows: application.relationRowCount
      columns: application.relationColCount

      Component.onCompleted: {

        relationMatrix.addList(application.relationList);
        application.reportStore.cmd("SET RELATION", application.relationList[0]);
      }
      onSelected: {
        application.reportStore.cmd("SET RELATION", item);
        application.reportStore.getArtikel(application.reportStore._warengruppe,function(res){
          articleMatrix.addList(res);
        })

      }
    }
  }



  ReportAndInput {
    id: rai
    x: spacing+(layoutWUnit*application.matrix.raiX)
    y: spacing+(layoutHUnit*application.matrix.raiY)
    width: layoutWUnit * application.matrix.raiWidth -spacing
    height: layoutHUnit * application.matrix.raiHeight -spacing
  }



  // +++ pay rect
  Rectangle {
    id: mFrame2
    visible: ((application.reportStore.currentMode === 'pay')) ? true : false
    color: "transparent"
    x: spacing+(layoutWUnit*application.matrix.payX)
    y: spacing+(layoutHUnit*application.matrix.payY)
    width: layoutWUnit * application.matrix.payWidth - spacing
    height: layoutHUnit * application.matrix.payHeight - spacing

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
        width: parent.width - 10
        height: parent.height - 10
        anchors.centerIn: parent
        clip: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: givenDisplay.height * 0.3
        color: (application.reportStore.given < application.reportStore.total) ? "red" : "black"
        text: "Gegeben: " + (application.reportStore.given.toFixed(2))
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
        width: parent.width - 10
        height: parent.height - 10
        anchors.centerIn: parent
        clip: true

          verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight

          font.pointSize: givebackDisplay.height * 0.3
        color: ((application.reportStore.given - application.reportStore.total) < 0) ? "red" : "black"
        text: "Rückgeld: " + ((application.reportStore.given - application.reportStore.total).toFixed(2))
      }
    }

    BezahlenMatrix {
      y: givebackDisplay.y + givebackDisplay.height + 10
      width: parent.width
      height: mFrame2.height/9 * 5
      onFieldSelected: {
        application.reportStore.cmd(item.cmd, item.val);
      }
    }
  } // --- pay rect




  //******************************************

  Rectangle {
    id: simpleReferenz
    property alias plugin: plugIn
    visible: ((application.reportStore.currentMode === 'Referenz')) ? true : false
    color: "transparent"

    x: spacing+(layoutWUnit*application.matrix.pluginX)
    y: spacing+(layoutHUnit*application.matrix.pluginY)
    width: layoutWUnit * application.matrix.pluginWidth - spacing
    height: layoutHUnit * application.matrix.pluginHeight - spacing

    ReferenzPlugin {
      id: plugIn
      y: 0
      x: 0
      width: parent.width
      height: parent.height
      color: "transparent"
    }
  }


  Rectangle {
    id: gutscheinEinloesen
    property alias plugin: gplugIn
    visible: ((application.reportStore.currentMode === "GutscheinEinloesen")) ? true : false
    color: "transparent"
    x: spacing+(layoutWUnit*application.matrix.pluginX)
    y: spacing+(layoutHUnit*application.matrix.pluginY)
    width: layoutWUnit * application.matrix.pluginWidth - spacing
    height: layoutHUnit * application.matrix.pluginHeight - spacing
    GutscheinEinloesenPlugin {
      id: gplugIn
      y: 0
      x: 0
      width: parent.width
      height: parent.height
      color: "transparent"
    }
  }

  Rectangle {
    id: gutscheinAusgabe
    property alias plugin: gaplugIn
    visible: ((application.reportStore.currentMode === "GutscheinAusgeben")) ? true : false
    color: "transparent"

    x: spacing+(layoutWUnit*application.matrix.pluginX)
    y: spacing+(layoutHUnit*application.matrix.pluginY)
    width: layoutWUnit * application.matrix.pluginWidth - spacing
    height: layoutHUnit * application.matrix.pluginHeight - spacing

    GutscheinAusgebenPlugin {
      id: gaplugIn
      y: 0
      x: 0
      width: parent.width
      height: parent.height
      color: "transparent"
    }
  }





  Rectangle {
    anchors.centerIn: parent
    visible: (application.reportStore.findString === "") ? false : true
    color: "white"
    radius: 5
    width: parent.width * 0.30
    height: parent.height * 0.10

    Text {
      anchors.centerIn: parent
      text: "Suche: "+application.reportStore.findString
    }
  }

}

//}
/*
    Rectangle {
      id: mmFrame
      x: spacing
      y: spacing
      color: "transparent"
      width: view.width / (8 + application.waregroupColumns + buttonPanelColumns) * (8 + application.waregroupColumns)
      height: view.height - spacing * 2
      clip: true

      Rectangle {
        id: mFrame
        opacity: ((application.reportStore.currentMode === 'amount') || (application.reportStore.currentMode === 'find')) ? 1 : 0
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
        x: ((application.reportStore.currentMode === 'amount') || (application.reportStore.currentMode === 'find')) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height


        Rectangle {
          id: waregroupChooser
          x: spacing
          y: 0 //spacing
          color: "transparent"
          width: (parent.width - (5 + application.waregroupColumns) * spacing) / (5 + application.waregroupColumns) * application.waregroupColumns
          height: mFrame.height - relationChooser.height - spacing * 2
          Matrix {
            id: waregroupMatrix
            anchors.fill: parent
            template: "{warengruppe}"
            rows: framedView.rows
            columns: application.waregroupColCount
            Component.onCompleted: {
              waregroupMatrix.addList(application.reportStore.getWarengrupen());
            }
            onSelected: {
              articleMatrix.defaultBackgroundColor = item.displayBackgroundColor;
              application.reportStore.getArtikel(item.warengruppe,function(res){
                articleMatrix.addList(res);
              })
            }
          }

        }

        Rectangle {
          id: itemChooser
          color: "transparent"
          x: waregroupChooser.width + waregroupChooser.x + spacing
          y: 0 //spacing
            //width: itemWidth*application.articleColumns
            //width: (parent.width-(application.articleColumns + application.waregroupColumns)*spacing)/(application.articleColumns + application.waregroupColumns)*application.articleColumns
          width: (parent.width - (8 + application.waregroupColumns) * spacing) / (8 + application.waregroupColumns) * 8
          height: mFrame.height - relationChooser.height - spacing * 2


          Matrix {
            id: articleMatrix
            anchors.fill: parent
            template: "{gruppe}<br/>{euro(brutto)}"
            rows: framedView.rows
            columns: application.articleColCount
            Component.onCompleted: {
              application.reportStore.onFind = function(str){
                application.reportStore.currentMode = 'find';
                (application.reportStore.findArticle(str,function(l){
                  articleMatrix.addList(l);
                  application.reportStore.currentMode = 'amount';
                }));

              }
            }
            onSelected: {
              application.reportStore.add(item);
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

              relationMatrix.addList(application.relationList);
              application.reportStore.cmd("SET RELATION", application.relationList[0]);
            }
            onSelected: {
              application.reportStore.cmd("SET RELATION", item);
              application.reportStore.getArtikel(application.reportStore._warengruppe,function(res){
                articleMatrix.addList(res);
              })

            }
          }
        }


      }

      Rectangle {
        id: mFrame2
        opacity: ((application.reportStore.currentMode === 'pay')) ? 1 : 0
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
        x: ((application.reportStore.currentMode === 'pay')) ? 0 : -1.2 * parent.width
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
            font.pointSize: mainStyle.font.size
            width: parent.width - 10
            height: parent.height - 10
            anchors.centerIn: parent
            clip: true

              verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

              font.pointSize: givenDisplay.height * 0.3
            color: (application.reportStore.given < application.reportStore.total) ? "red" : "black"
            text: "Gegeben: " + (application.reportStore.given.toFixed(2))
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
            font.pointSize: mainStyle.font.size
            width: parent.width - 10
            height: parent.height - 10
            anchors.centerIn: parent
            clip: true

              verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

              font.pointSize: givebackDisplay.height * 0.3
            color: ((application.reportStore.given - application.reportStore.total) < 0) ? "red" : "black"
            text: "Rückgeld: " + ((application.reportStore.given - application.reportStore.total).toFixed(2))
          }
        }

        BezahlenMatrix {
          y: givebackDisplay.y + givebackDisplay.height + 10
          width: parent.width
          height: mFrame2.height/9 * 5
          onFieldSelected: {
            application.reportStore.cmd(item.cmd, item.val);
          }
        }
      }





      //******************************************

      Rectangle {
        id: simpleReferenz
        property alias plugin: plugIn
        opacity: ((application.reportStore.currentMode === 'Referenz')) ? 1 : 0
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
        x: ((application.reportStore.currentMode === 'Referenz')) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height
        ReferenzPlugin {
          id: plugIn
          y: 0
          x: 0
          width: parent.width
          height: parent.height
          color: "transparent"
        }
      }


      Rectangle {
        id: gutscheinEinloesen
        property alias plugin: gplugIn
        opacity: ((application.reportStore.currentMode === "GutscheinEinloesen")) ? 1 : 0
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
        x: ((application.reportStore.currentMode === "GutscheinEinloesen")) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height
        GutscheinEinloesenPlugin {
          id: gplugIn
          y: 0
          x: 0
          width: parent.width
          height: parent.height
          color: "transparent"
        }
      }

      Rectangle {
        id: gutscheinAusgabe
        property alias plugin: gaplugIn
        opacity: ((application.reportStore.currentMode === "GutscheinAusgeben")) ? 1 : 0
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
        x: ((application.reportStore.currentMode === "GutscheinAusgeben")) ? 0 : -1.2 * parent.width
        y: 0
        width: parent.width
        height: parent.height
        GutscheinAusgebenPlugin {
          id: gaplugIn
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
      //width: view.width / (8 + application.waregroupColumns + buttonPanelColumns) * (buttonPanelColumns) - spacing * (8 + application.waregroupColumns)
      width: Screen.pixelDensity * 85
      height: view.height - spacing * 2
    }






    Rectangle {
      anchors.centerIn: view
      opacity: (application.reportStore.findString === "") ? 0 : 1
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
        text: "Suche: "+application.reportStore.findString
      }
    }
  }

  Rectangle {
    id: leftFrame
    x: application.reportStore.reportMode ? 0: -1*view.width
    width: view.width / 2 //application.reportStore.reportMode ?  : 0
    height: framedView.height
    Behavior on opacity {
      OpacityAnimator {
        easing.type: Easing.InCubic;
        duration: 500
      }
    }
    color: "black"
    opacity: application.reportStore.reportMode ? 1 : 0
    Matrix {
      id: leftFrameMatrix
      anchors.fill: parent

      columns: 1
      rows: framedView.rows
      template: "{reportnumber} {euro(total)}"

      Component.onCompleted: {
        application.reportStore.onAddedReport = function(item){
          function compare(a,b) {
            if (a.reportnumber < b.reportnumber)
               return 1;
            if (a.reportnumber > b.reportnumber)
              return -1;
            return 0;
          }
          var list = application.reportStore.oldReports.slice(0);
          leftFrameMatrix.addList(list.sort(compare).slice(0,30));
        };
      }

      onSelected: {
        application.reportStore.reportMode = false
        application.reportStore.cmd("OPENREPORT", item.reportnumber);
      }
    }
  }
*/
