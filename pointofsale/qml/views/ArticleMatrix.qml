import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"
import "../views"
import "../styles"

Grid {
     id: grid

     property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
     property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)

     property var articles

     anchors.fill: parent
     spacing: 8

     columns: App.articleColumns
     rows: App.articleRows

     move: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }
     add: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }

     Component.onCompleted:{
        console.log ('ArticleMatrix.qml','deprecated');
     }

     Repeater {

       model: columns*rows
       Rectangle {
         id: r
         property bool isHidden: (typeof articles==='undefined') || (typeof articles[index]==='undefined')
         radius: 5
         width: grid.itemWidth
         height: grid.itemHeight
         color: isHidden?"transparent":mainStyle.colors.btnBackground
         clip: true
         opacity: mouse.pressed?0.5:1
         Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 50 } }

         Text {

            font.pixelSize: mainStyle.font.size
            width: grid.itemWidth-spacing
            height: grid.itemHeight-spacing
            color: isHidden?"transparent":"white"
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            text: isHidden ? "-" : (articles[index].gruppe + "<br/>" + (articles[index].brutto.toFixed(2)+" €"+" (" + articles[index].steuersatz.toFixed(0)+"%)"))
            style: Text.Outline
            styleColor: isHidden?"transparent":"black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            clip: true
         }

         MouseArea {
           id: mouse
           anchors.fill: parent
           anchors.margins: -10
           onClicked: {
            if (typeof articles==='object'){
              if (typeof articles[index]!=='undefined'){
                  ReportStore.add( articles[index] );
              }
            }

           }
         }

       }
     }
 }
