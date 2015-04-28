import QtQuick 2.0
import QtQuick.Layouts 1.1
import "../controlls"
import "../views/matrix"
import "../singleton"



StackViewItem {
  title: qsTr("Testing")
  Matrix{
    anchors.fill: parent
    template: "{text}<br/>{price}"
    Component.onCompleted: {
      var list = [];

      list.push({
        text: 'item 1',
        price: 1.23
      })

      list.push({text: 'item 2',price: 2.23})
      list.push({text: 'item 3',price: 3.23})
      list.push({text: 'item 4',price: 4.23})
      list.push({text: 'item 5',price: 5.23})
      addList(list);
    }
  }
}
