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

     anchors.fill: parent

     spacing: 8

     columns: 5
     rows: 6

     property var buttons: [

         {
             text: (ReportStore.currentMode!=='pay')?"St. Alles.":"Zurück",
             cmd: (ReportStore.currentMode!=='pay')?"CANCLE":"CANCLEPAY", val:".",
             hidden: (ReportStore.number===-1)?false:true ,
             color: (ReportStore.currentMode!=='pay')?"#f33":"3f9"
         },
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".",val:"", hidden: true , color: mainStyle.colors.btnBackground},
         { text: "\uf115", cmd: "OPEN",val:"", hidden: false , color: "#8f8"},


         { text: ".", cmd: ".", val:"", hidden: true , color: "#faa"},
         { text: "7", cmd: "NUM", val: 7 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "8", cmd: "NUM", val: 8 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "9", cmd: "NUM", val: 9 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "\uf115", cmd: "CUT",val:"", hidden: false , color: "#ff8"},


         {
             text: (ReportStore.currentMode!=='pay')?"St. Pos.":"Pas.",
             cmd: (ReportStore.currentMode!=='pay')?"CANCLE LAST":"PAYFIT", val:".",
             hidden: (ReportStore.number===-1)?false:true ,
             color: (ReportStore.currentMode!=='pay')?"#f33":"3f9"
         },
         { text: "4", cmd: "NUM", val: 4 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "5", cmd: "NUM", val: 5 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "6", cmd: "NUM", val: 6 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "\uf02f", cmd: "PRINT", val:"", hidden: false , color: "#88f"},


         { text: "PR", cmd: "AMOUNTPRICESWITCH", val:"", hidden: (ReportStore.number===-1&&ReportStore.currentMode!=='pay')?false:true , color: ((ReportStore.currentMode==='amount')? "#9aa": "#955") },
         { text: "1", cmd: "NUM", val: 1 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "2", cmd: "NUM", val: 2 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: "3", cmd: "NUM", val: 3 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: ".", cmd: ".", val:"", hidden: true , color: "#afa"},


         { text: "B", cmd: "REPORTMODE", val:"", hidden: (ReportStore.currentMode!=='pay')?false:true , color: "#133"},
         { text: "+/-", cmd: "PLUSMINUS", val: "" , hidden: (ReportStore.number===-1)?false:true , color: "#aad"},
         { text: "0", cmd: "NUM", val: 0 , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
         { text: ",", cmd: "SEP", val: "" , hidden: (ReportStore.number===-1)?false:true , color: mainStyle.colors.btnBackground},
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
                font.pixelSize: mainStyle.font.buttonFontSize

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
                             ReportStore.cmd(buttons[index].cmd,buttons[index].val);
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

