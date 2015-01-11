import QtQuick 2.3
import QtQuick.Controls 1.2

import "./controlls"
import "./views"
import "./styles"
import "./singleton"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 800
    height: 600



    title: App.posTitle

    MainStyle{
        id: mainStyle
    }



    menuBar: MenuBar {
        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }


    Component.onCompleted: {
        appWindow.showMaximized();
        if (App.fullscreen==="1"){
            appWindow.showFullScreen();
        }

    }

    OverView{
        id: overview
    }


   StackedView{
       id: stack
       anchors.fill: parent
       initialItem: overview
       focus: true
       property string inputText: ""
       Keys.onReleased:{

           switch(event.key){
           case Qt.Key_Escape:
               if (stackView.depth > 1) {
                   stackView.pop();
                   event.accepted = true;
               }
               break;
           case Qt.Key_Enter:
           case Qt.Key_Return:
               stack.currentItem.textInput(inputText);
               inputText = "";
               event.accepted = true;
               break;
           default:
               for(var i in Qt){
                   if (i.indexOf('Key')===0){
                       if (Qt[i]===event.key){
                           console.log("main","QT KEY",i);
                       }
                   }
               }
               inputText += event.text;
               event.accepted = true;

           }


           console.log("main","input",inputText)
       }
   }




}
