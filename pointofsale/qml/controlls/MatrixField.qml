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
     property int fontPixelSize: mainStyle.font.size
     property int buttonRadius: 5
     property string displayTemplate: "{name},{test}"
     property var fields: []


     signal fieldSelected(var item)

     spacing: 8
     columns: 1
     rows: 1

     move: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }
     add: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }

     function getDisplayTitle(index){
         var template = "{name},{test}";
         var rx= /\[[^\]]+\]|\{[^}]+\}|<[^>]+>/g;
         var result = template.match(rx);
         if (result){
             for(var i=0;i<result.length;i++){
                 template = template.replace(new RegExp("/"+result[i]+"/g"),fields[index][result[i].replace('{','').replace('}','')]);
             }
         }
         return template;
     }

     Repeater {
         model: columns*rows

         Rectangle {
             property bool isHidden: (typeof fields==='undefined') || (typeof fields[index]==='undefined')
             property double backgroundOpacity: (  (typeof fields==='undefined') || (typeof fields[index]==='undefined')|| (typeof fields[index].backgroundOpacity==='undefined') ) ? 1 : fields[index].backgroundOpacity
             property double pressedOpacity: (  (typeof fields==='undefined') || (typeof fields[index]==='undefined')|| (typeof fields[index].pressedOpacity==='undefined') ) ? 0.5 : fields[index].pressedOpacity
             width: grid.itemWidth
             height: grid.itemHeight
             radius: buttonRadius
             color: isHidden ? "transparent": ( ((typeof fields[index]==='undefined')||(typeof fields[index].displayColor==='undefined'))?"transparent":fields[index].displayColor)


             opacity: mouse.pressed?pressedOpacity:backgroundOpacity
             Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 250 } }
             Text {
                font.pixelSize: fontPixelSize
                width: grid.itemWidth-spacing
                height: grid.itemHeight-spacing
                color: isHidden?"transparent":"white"
                style: Text.Outline
                styleColor: isHidden?"transparent":"black"
                anchors.centerIn: parent
                wrapMode: Text.WordWrap
                text: isHidden ? "" :  ((typeof fields[index].displayText==='undefined')?"":fields[index].displayText)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                clip: true
             }

             Image{
                 width: grid.itemWidth-spacing*3
                 height: grid.itemHeight-spacing*3
                 opacity: (((typeof fields[index]==='undefined')||(typeof fields[index].displayImage==='undefined'))?0:1)
                 source: (((typeof fields[index]==='undefined')|| (typeof fields[index].displayImage==='undefined'))?"":fields[index].displayImage)
                 fillMode: Image.PreserveAspectFit
                 anchors.centerIn: parent
                 smooth: true
             }

             MouseArea {
                 id: mouse
                 anchors.fill: parent
                 anchors.margins: -10
                 onClicked: {
                     if (typeof fields==='object'){
                         if (typeof fields[index]!=='undefined'){
                            fieldSelected( fields[index] )
                         }
                     }
                 }
             }
         }
     }

 }
