import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


Rectangle {
    id: root
    width: parent.width
    height: mainStyle.dimens.rightMargin +mainStyle.font.size +mainStyle.dimens.rightMargin

    color: "#11ffffff"

    property alias text: textitem.text
    property alias icon: texticon.text
    signal clicked

    Component.onCompleted: {
      //console.log("ok");
    }

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        //visible: mouse.pressed
    }

    Text {
        id: texticon
        color: mainStyle.colors.toolbarPrevIcon
        font.pointSize: mainStyle.font.size
        text: modelData
        font.family: mainStyle.font.iconFont.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: mainStyle.dimens.leftMargin
    }

    Text {
        id: textitem
        color:mainStyle.colors.toolbarText
        font.pointSize: mainStyle.font.size
        text: modelData
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: mainStyle.dimens.leftMargin + mainStyle.dimens.leftMargin + mainStyle.dimens.iconWidth
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: mainStyle.dimens.rightMargin
        height: 1
        color: mainStyle.colors.listDelimiter
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: mainStyle.dimens.rightMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
          root.clicked()
        }
    }
}
