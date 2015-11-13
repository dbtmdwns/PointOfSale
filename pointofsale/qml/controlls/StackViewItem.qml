import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

Rectangle {

    property string title: qsTr("***Please set the title")
    property string doneText: qsTr("")

    function textInput(text){

    }

    Rectangle {
        color: mainStyle.colors.background
        anchors.fill: parent
    }
}
