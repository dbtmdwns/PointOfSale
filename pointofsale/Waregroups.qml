import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../controlls"

StackViewItem {

    title: qsTr("Waregroup")

    ListModel {
        id: pageModel


        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 1"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 2"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 3"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 4"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 5"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Waregroup 5"
            doneText: ""
            page: "Articles.qml"
        }

    }

    ListView {
        model: pageModel
        anchors.fill: parent
        delegate: SimpleListItemDelegate {
            text: title
            icon: iconText
            onClicked: {
                var item = Qt.resolvedUrl(page)
                //console.log(item)
                //item.title = title
                itemChooser.push(item,title)
            }
        }
    }

}
