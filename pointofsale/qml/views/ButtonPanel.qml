import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../controlls"
import "../views"
import "../styles"

Grid {
     id: grid

     property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
     property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)

     anchors.fill: parent

     spacing: 8

     columns: 5
     rows: 6

     property var buttons: [

         {
             text: (application.reportStore.currentMode!=='pay')?"St. Alles.":"Zurück",
             cmd: (application.reportStore.currentMode!=='pay')?"CANCLE":"CANCLEPAY", val:".",
             hidden: false,//(application.reportStore.number===-1)?false:true ,
             color: (application.reportStore.currentMode!=='pay')?"#f33":"3f9"
         },
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: "\uf115", cmd: "OPEN",val:"", hidden: false , color: "#8f8"},


         {
             text: (application.reportStore.currentMode!=='pay')?"St. Pos.":"Pas.",
             cmd: (application.reportStore.currentMode!=='pay')?"CANCLE LAST":"PAYFIT", val:".",
             hidden: (application.reportStore.number===-1)?false:true ,
             color: (application.reportStore.currentMode!=='pay')?"#f33":"3f9"
         },
         { text: "7", cmd: "NUM", val: 7 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "8", cmd: "NUM", val: 8 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "9", cmd: "NUM", val: 9 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "\uf115", cmd: "CUT",val:"", hidden: true , color: "#ff8"},



         { text: "PR", cmd: "AMOUNTPRICESWITCH", val:"", hidden: (application.reportStore.number===-1&&application.reportStore.currentMode!=='pay')?false:true , color: ((application.reportStore.currentMode==='amount')? "#9aa": "#955") },
         { text: "4", cmd: "NUM", val: 4 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "5", cmd: "NUM", val: 5 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "6", cmd: "NUM", val: 6 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "\uf02f", cmd: "PRINT", val:"", hidden: false , color: "#88f"},


         { text: ".", cmd: ".", val:"", hidden: true , color: "#faa"},
         { text: "1", cmd: "NUM", val: 1 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "2", cmd: "NUM", val: 2 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "3", cmd: "NUM", val: 3 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".", val:"", hidden: true , color: "#afa"},


         { text: "B", cmd: "REPORTMODE", val:"", hidden: (application.reportStore.currentMode!=='pay')?false:true , color: "#133"},
         { text: "+/-", cmd: "PLUSMINUS", val: "" , hidden: (application.reportStore.number===-1)?false:true , color: "#aad"},
         { text: "0", cmd: "NUM", val: 0 , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: ",", cmd: "SEP", val: "" , hidden: (application.reportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "\uf00c", cmd: "ENTER", val:"", hidden: false , color: "#3f3"},

         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground}



     ]

     move: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }
     add: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }

     Repeater {

         model: 25

         Rectangle {

             property bool isHidden: ( (typeof buttons[index]==='undefined') || (buttons[index].hidden) )
             property bool enabled: true
             id: btn
             width: grid.itemWidth
             height: grid.itemHeight
             radius: 5
             color: isHidden?"transparent": buttons[index].color

             opacity: mouse.pressed?0.5:1
             Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 50 } }

             Text {

                font.family: mainStyle.font.iconFont.name
                font.pointSize: mainStyle.font.buttonFontSize

                width: grid.itemWidth - spacing
                height: grid.itemHeight - spacing
                color: isHidden? "transparent" : "white"
                style: Text.Outline
                styleColor: isHidden?"transparent":"black"
                anchors.centerIn: parent
                wrapMode: Text.WordWrap
                text: isHidden ? "" : buttons[index].text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                clip: true

             }

             Timer {
               id: tmr
               interval: 150
               running: false
               repeat: false
               onTriggered: {
                  tmr.stop();
                  btn.enabled = true;
               }
             }

             MouseArea {
                 id: mouse
                 anchors.fill: parent
                 anchors.margins: -10
                 onClicked: {

                     if (typeof buttons[index]==='object'){
                         if (btn.enabled){
                             btn.enabled = false;
                             console.log(buttons[index].cmd);
                             application.reportStore.cmd(buttons[index].cmd,buttons[index].val);
                             tmr.start();
                         }
                     }



                     /*
                     if (typeof waregroups==='object'){
                         if (typeof waregroups[index]!=='undefined'){
                            waregroupChanged(waregroups[index].articles);
                         }
                     }

                    */
                 }
             }
         }
     }
 }
