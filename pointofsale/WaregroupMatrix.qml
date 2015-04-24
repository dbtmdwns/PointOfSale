import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"
import "../views"
import "../styles"
import "../singleton"

Grid {
     id: grid

     property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
     property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)

     signal waregroupChanged(var articles)
     property var waregroups: []


     Component.onCompleted: {
        waregroups = ReportStore.getWarengrupen();
     }

     anchors.fill: parent
     spacing: 8
     columns: App.waregroupColumns
     rows: App.waregroupRows

     move: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }
     add: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }

     Repeater {
         model: columns*rows

         Rectangle {
             property bool isHidden: (typeof waregroups==='undefined') || (typeof waregroups[index]==='undefined')
             width: grid.itemWidth
             height: grid.itemHeight
             radius: 5
             color: isHidden?"transparent": waregroups[index].farbe
             opacity: mouse.pressed?0.5:1
             Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 50 } }



             Text {
                font.pixelSize: mainStyle.font.size
                width: grid.itemWidth-spacing
                height: grid.itemHeight-spacing
                color: isHidden?"transparent":"white"
                style: Text.Outline
                styleColor: isHidden?"transparent":"black"
                anchors.centerIn: parent
                wrapMode: Text.WordWrap
                text: isHidden ? "" : waregroups[index].warengruppe
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                clip: true
             }

             MouseArea {
                 id: mouse
                 anchors.fill: parent
                 anchors.margins: -10
                 onClicked: {
                     if (typeof waregroups==='object'){
                         if (typeof waregroups[index]!=='undefined'){
                            waregroupChanged(ReportStore.getArtikel(waregroups[index].warengruppe))
                         }
                     }
                 }
             }
         }
     }

 }
