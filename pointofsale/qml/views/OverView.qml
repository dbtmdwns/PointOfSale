import QtQuick 2.0
import QtQuick.Layouts 1.1
import "../controlls"
import "../singleton"
import "./stackitems"


StackViewItem {

    title: qsTr("Overview")

    ListModel {
        id: pageModel

        /*
        ListElement {
            iconText: "\uf0c0"
            title: "Login"
            doneText: ""
            page: "Authenticate.qml"
        }

        ListElement {
            iconText: "\uf073"
            title: "Test"
            doneText: ""
            page: "MainReport.qml"
        }
        */

        ListElement {
          iconText: "\uf073"
          title: "Kasse"
          doneText: ""
          page: "MatrixInput.qml"
        }

        ListElement {
            iconText: "\uf0f6"
            title: "About"
            doneText: ""
            page: "About.qml"
        }


        ListElement {
            iconText: "\uf085"
            title:  "Settings"
            doneText: "\uf00c Fertig"
            page: "Settings.qml"
        }


        ListElement {
            iconText: "\uf08b"
            title: "Exit"
            doneText: ""
            page: "Exit.qml"
        }


        ListElement {
            iconText: "\uf08b"
            title: "Testing"
            doneText: ""
            page: "stackitems/Main.qml"
        }


    }

    width: parent.width
    height: parent.height
    Image {
        id: bgLogo
        fillMode: Image.PreserveAspectFit
        width: parent.width
        height: parent.height
        opacity: 0.1
        source: "qrc:/resources/image_source/logo.svg";
    }
    ListView {
        model: pageModel
        anchors.fill: parent
        delegate: SimpleListItemDelegate {
            text: title
            icon: iconText
            onClicked: {
                if (
                  (page==='MatrixInput.qml') 
                ){
                    App.wawiLogin(function(){
                        ReportStore.loadArticles(function(){
                          stack.push(Qt.resolvedUrl(page))
                          //stack.push(Qt.resolvedUrl('views/MatrixInput.qml'));
                        });
                    });
                }else{
                    stack.push(Qt.resolvedUrl(page))
                }


            }
        }
    }
}
