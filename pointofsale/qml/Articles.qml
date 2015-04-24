import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../controlls"
import "../singleton"

StackViewItem {

    width: parent.width
    height: parent.height

    title: qsTr("Waregroup")

    ListModel {
        id: pageModel


        ListElement {
            iconText: "\uf0c0"
            title: "Article 1"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Article 2"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Article 3"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Article 4"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Article 5"
            doneText: ""
            page: "Articles.qml"
        }

        ListElement {
            iconText: "\uf0c0"
            title: "Article 5"
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
                //itemChooser.push(Qt.resolvedUrl(page))
                ReportStore.add(title,text,"",1,7,1,"xref");
            }
        }
    }

}
