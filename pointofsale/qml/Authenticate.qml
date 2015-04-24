import QtQuick 2.0
import "../controlls"

StackViewItem {

    width: parent.width
    height: parent.height

    title: qsTr("Authenticate")

    function textInput(text){
        authText.text=text;
    }

    Text{
        id: authText
        color: "white"
        font.pixelSize: mainStyle.font.size

        anchors.centerIn: parent
        text: qsTr("Please scan your Card")
    }


}
