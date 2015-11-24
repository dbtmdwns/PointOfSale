import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../controlls"





StackViewItem {
    title: qsTr("Overview")
    property var configs: ['name','name2']
    property alias model: pageModel;
    ListModel {
        id: pageModel

        /*
        ListElement {
          iconText: "\uf073"
          title: config[0]
          doneText: ""
          page: "MatrixInput.qml"
        }

        ListElement {
          iconText: "\uf073"
          title: config[1].name
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
        */

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
      id: list
      model: pageModel
      anchors.fill: parent
      delegate: SimpleListItemDelegate {

          //anchors.fill: parent
          //color: "green"

          text: title
          icon: iconText

          onClicked: {
            if (
              (page==='MatrixInput.qml')
            ){
              var me = application;
              var stk = stack;
              var p = page;

              if (me.setConfigs(configIndex)){

                var screen = stack.push(Qt.resolvedUrl(page));
                //me.message="Bitte warten";

                me.login(function(success){
                  me.reportStore.loadArticles(function(){
                    me.message=""
                    screen.update();
                  } );
                });

              }


            }else if ( (page==='CloseCashBox.qml') ){
              var me = application;
              var stk = stack;
              var p = page;
              if (me.setConfigs(configIndex)){
                stack.push(Qt.resolvedUrl(page));
              }
            }else{
              stack.push(Qt.resolvedUrl(page));
            }
          }
      }
    }
}
