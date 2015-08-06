import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.Controls 1.2

import "./controlls"
import "./styles"
import "./views/stackitems"
import "./controller"

// import "./views"


ApplicationWindow {
  id: appWindow
  visible: true
  width: 800
  height: 600
  //title: "tualo"// App.posTitle

  App {
    id: application
  }

  title: application.posTitle
  /*

  ReportStore {
    id: reportStore
  }
  Remote {
    id: local
  }
  Local {
    id: remote
  }
  */




  MainStyle {
    id: mainStyle
  }

  Component.onCompleted: {
    appWindow.showMaximized();

    if (application.fullscreen === "1") {
      appWindow.showFullScreen();
    }
    /*
    application.windowWidth = width;
    application.dpi = Screen.pixelDensity * 25.4
    application.density = Screen.pixelDensity
    */
  }


  toolBar: Rectangle {
    color: mainStyle.colors.toolbarBackground
    height: mainStyle.dimens.toolbarHeight
    width: parent.width

    //opacity: 0.5

    Rectangle {
        id: backButton
        width: opacity ? mainStyle.dimens.backButtonWidth : 0

        anchors.left: parent.left
        anchors.leftMargin: mainStyle.dimens.leftMargin
        opacity: stack.depth > 1 ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        height: mainStyle.dimens.backButtonHeight
        radius: 4
        color: backmouse.pressed ? "#222" : "transparent"
        Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }
        Text{
            text: "\uf053"
            color: mainStyle.colors.toolbarPrevIcon
            width: backButton.width
            height: backButton.height
            font.pixelSize: mainStyle.font.size
            font.family: mainStyle.font.iconFont.name
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }



        MouseArea {
            id: backmouse
            anchors.fill: parent
            anchors.margins: -10
            onClicked: {
              stack.pop()
            }
        }
    }

    Text {
        font.pixelSize: mainStyle.font.size
        Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
        x: backButton.x + backButton.width + mainStyle.dimens.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        color: mainStyle.colors.toolbarText
        text: ( backButton.opacity ? (

          (

            (typeof stack === 'object' ) &&
            (typeof stack.currentItem === 'object' ) &&
            (stack.currentItem !== null )

          ) ? ( title+": "+stack.currentItem.title ) : title

        ) : title )
    }


    Rectangle {
        id: doneButton
        width: opacity ? mainStyle.dimens.nextButtonWidth : 0

        anchors.right: parent.right
        anchors.rightMargin: mainStyle.dimens.rightMargin
        opacity: ( (stack.currentItem!==null) && (typeof stack.currentItem.doneText==="string") && (stack.currentItem.doneText!=="") ) ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        height: mainStyle.dimens.nextButtonHeight
        radius: 4
        color: backmouse.pressed ? mainStyle.colors.buttonPressed : "transparent"

        Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }

        Text{
            text: ( (stack.currentItem!==null)  && (typeof stack.currentItem.doneText==="string"))?stack.currentItem.doneText.substring(0,stack.currentItem.doneText.length-1):""
            color: mainStyle.colors.toolbarNextIcon
            width: doneButton.width  - mainStyle.font.size
            height: doneButton.height
            font.pixelSize: mainStyle.font.size
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Text{
            text: ( (stack.currentItem!==null)  && (typeof stack.currentItem.doneText==="string"))?stack.currentItem.doneText.substring(stack.currentItem.doneText.length-1):""
            color: mainStyle.colors.toolbarNextIcon
            width: doneButton.width
            height: doneButton.height
            font.pixelSize: mainStyle.font.size
            font.family: mainStyle.font.iconFont.name
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }


        MouseArea {
            property bool canClick: true
            id: donemouse
            Timer {
              id: tmr
              interval: 350
              running: false
              repeat: false
              onTriggered: {
                 tmr.stop();
                 donemouse.canClick = true;
              }
            }
            anchors.fill: parent
            //anchors.margins: -10
            onClicked: {

                if (canClick){
                    canClick = false;
                    tmr.start();
                    if (typeof stack.currentItem.onDoneClicked === "function"){
                        stack.currentItem.onDoneClicked();
                    }
                }
                //stackView.pop()
            }
        }
    }

  }

  StackView {
    id: stack
    anchors.fill: parent
    // Implements back key navigation
    focus: true
    Keys.onReleased: {
      if (event.key === Qt.Key_Back && stack.depth > 1) {
         stack.pop();
         event.accepted = true;
     }
   }
   initialItem: overview
  }

  Rectangle {

    anchors.centerIn: parent
    opacity: (application.message === "") ? 0 : 1
    color: "white"
    radius: 5
    width: parent.width * 0.30
    height: parent.height * 0.30
    Behavior on opacity {
      OpacityAnimator {
        easing.type: Easing.InCubic;
        duration: 150
      }
    }
    Text {
      anchors.centerIn: parent
      clip: true
      text: application.message
    }
  }

  /*
  StackedView {
    id: stack
    anchors.fill: parent
    initialItem: overview
    focus: true
    property string inputText: ""
    Keys.onReleased: {
      if (typeof stack.currentItem.keyInput === 'function') {
        stack.currentItem.keyInput(event);
      }
      switch (event.key) {
        case Qt.Key_Escape:
          if (stackView.depth > 1) {
            stackView.pop();
            event.accepted = true;
          }
          break;
        case Qt.Key_Backspace:
          if (inputText.length > 0)
            inputText = inputText.substring(0, inputText.length - 1);
          event.accepted = true;
          break;
        case Qt.Key_Enter:
        case Qt.Key_Return:
          stack.currentItem.textInput(inputText);
          inputText = "";
          event.accepted = true;
          break;
        default:
          for (var i in Qt) {
            if (i.indexOf('Key') === 0) {
              if (Qt[i] === event.key) {
                //console.log("main","QT KEY",i);
              }
            }
          }
          inputText += event.text;
          event.accepted = true;

      }
      //console.log("main","input",inputText)
    }


  }
  */

  OverView {
    id: overview
  }



}
