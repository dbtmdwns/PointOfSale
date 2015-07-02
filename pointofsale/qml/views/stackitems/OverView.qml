import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1
import "../../controlls"





StackViewItem {

    title: qsTr("Overview")

    ListModel {
        id: pageModel



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
              console.log('74',typeof application)
              application.login(function(){
                application.reportStore.loadArticles(function(){
                  stack.push(Qt.resolvedUrl(page))
                });
              });
            }else{
              stack.push(Qt.resolvedUrl(page))
            }
          }
      }
    }
}
