import QtQuick 2.0

Rectangle {

    property string title: qsTr("***Please set the title")
    property string doneText: qsTr("")

    function textInput(text){
        //console.log(text)
    }

    Rectangle {
        color: mainStyle.colors.background
        anchors.fill: parent
    }
}
