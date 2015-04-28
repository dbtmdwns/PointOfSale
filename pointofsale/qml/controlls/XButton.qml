import QtQuick 2.3
import "../views"
import "../styles"

Item {
    width: 25
    height: 25

    signal onClicked

    property alias text: txt.text
    property bool canClick: true
    property Component style: null

    Timer {
      id: tmr
      interval: 50
      running: false
      repeat: false
      onTriggered: {
         tmr.stop();
         canClick = true;
      }
    }


    MouseArea.onReleased: {
        if (canClick){
            canClick = false;
            tmr.start();
            onClicked()
        }
    }
    Rectangle{
        anchors.fill: parent
        //color: mainStyle.colors.buttonBackground
    }

    Text{
        id: txt
        anchors.centerIn: parent
    }
}
