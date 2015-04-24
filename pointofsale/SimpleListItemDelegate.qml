import QtQuick 2.1

Item {
    id: root
    width: parent.width
    height: mainStyle.dimens.rightMargin +mainStyle.font.size +mainStyle.dimens.rightMargin


    property alias text: textitem.text
    property alias icon: texticon.text
    signal clicked

    Component.onCompleted: {

    }

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        id: texticon
        color: mainStyle.colors.toolbarPrevIcon
        font.pixelSize: mainStyle.font.size
        text: modelData
        font.family: mainStyle.font.iconFont.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: mainStyle.dimens.leftMargin
    }

    Text {
        id: textitem
        color:mainStyle.colors.toolbarText
        font.pixelSize: mainStyle.font.size
        text: modelData
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: mainStyle.dimens.leftMargin + mainStyle.dimens.leftMargin + texticon.width
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: mainStyle.dimens.rightMargin
        height: 1
        color: "#424246"
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: mainStyle.dimens.rightMargin
        anchors.verticalCenter: parent.verticalCenter
        //source: "../images/navigation_next_item.png"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: root.clicked()

    }
}
