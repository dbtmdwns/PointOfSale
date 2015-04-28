import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../js/Template.js" as Template

Grid {
  id: grid

  function addItem(item){
    gridModel.append(item);
  }

  function addList(list){
    gridModel.clear();
    for(var i = 0,m=columns*rows; i < m; i++){
      addItem(prepareItem(list[i]));
    }
  }

  function prepareItem(entry){
    var item = {
      isVisible: (typeof entry !== 'undefined' && entry!==null),
      displayText: rendered(entry),
      entry: entry,
    }
    item.backgroundColor = item.isVisible ? ( (typeof entry.displayBackgroundColor==='string')?entry.displayBackgroundColor:'#ccaa00' ) : "transparent";
    item.textColor =item.isVisible ? "white" : "transparent";
    item.outlineColor =item.isVisible ? "black" : "transparent";

    return item
  }

  function rendered(item){
    var tmpl = new Template.Template(template);

    if (typeof item==='object'){
      return tmpl.render(item);
    }else{
      return ""
    }
  }

  property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
  property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)
  property int itemRadius: 5
  property int offset: 0
  property string template: "{text}"
  signal selected(var item)

  //anchors.fill: parent

  spacing: 8
  columns: 2
  rows: 2

  ListModel {
    id: gridModel

  }

  Repeater {
    model: gridModel
    Rectangle {
      radius: grid.itemRadius
      width: grid.itemWidth
      height: grid.itemHeight
      color: backgroundColor
      clip: true
      opacity: mouse.pressed?0.5: (isVisible ? 1 : 0 )
      Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 50 } }
      Text {
         font.pixelSize: mainStyle.font.size
         width: grid.itemWidth-spacing
         height: grid.itemHeight-spacing
         color: textColor
         anchors.centerIn: parent
         wrapMode: Text.WordWrap
         text: displayText
         antialiasing: true
         style: Text.Outline
         styleColor: outlineColor
         horizontalAlignment: Text.AlignHCenter
         verticalAlignment: Text.AlignVCenter
         clip: true
      }

      MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -10
        onClicked: {
          var item = gridModel.get(index);
          selected(item.entry);
        }
      }

    }
  }
}
