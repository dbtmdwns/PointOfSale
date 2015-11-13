import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

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
        font.pointSize: mainStyle.font.size

        anchors.centerIn: parent
        text: qsTr("Please scan your Card")
    }


}
