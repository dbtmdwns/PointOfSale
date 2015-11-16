import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


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

  title: application.posTitle + " (" +application.version+" / "+application.versionBuild+")"
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
    application.remote.tmrUnSyncRPT();

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
        //Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }
        Text{
            text: "\uf053"
            color: mainStyle.colors.toolbarPrevIcon
            width: backButton.width
            height: backButton.height
            font.pointSize: mainStyle.font.size
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
        font.pointSize: mainStyle.font.size
        //Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
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
      id: syncButton
      //xxf021
      visible: application.async=='0'?false:true
      color: "transparent"
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: mainStyle.dimens.rightMargin*2+mainStyle.dimens.nextButtonWidth
      height: mainStyle.dimens.nextButtonHeight
      width: mainStyle.dimens.nextButtonWidth

      Text{
          text: "\uf021"
          color: application.remote.syncing?"green": ( application.async=='1'?'darkgray':'lightgray' )
          width: syncButton.width
          height: syncButton.height
          font.pointSize: mainStyle.font.size
          font.family: mainStyle.font.iconFont.name
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
      }

      Text{
          text: application.remote.reports_not_in_sync
          color: "darkgray"
          x: mainStyle.font.size
          width: syncButton.width  - mainStyle.font.size
          height: syncButton.height
          font.pointSize: mainStyle.font.size*0.8
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
      }

      MouseArea {
        id: syncmouse
        anchors.fill: parent
        onClicked: {
          if (application.async=='2'){
            if (application.remote.syncing===false){
              application.remote.doSync();
            }
          }
        }
      }

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

        //Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }

        Text{
            text: ( (stack.currentItem!==null)  && (typeof stack.currentItem.doneText==="string"))?stack.currentItem.doneText.substring(0,stack.currentItem.doneText.length-1):""
            color: mainStyle.colors.toolbarNextIcon
            width: doneButton.width  - mainStyle.font.size
            height: doneButton.height
            font.pointSize: mainStyle.font.size
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Text{
            text: ( (stack.currentItem!==null)  && (typeof stack.currentItem.doneText==="string"))?stack.currentItem.doneText.substring(stack.currentItem.doneText.length-1):""
            color: mainStyle.colors.toolbarNextIcon
            width: doneButton.width
            height: doneButton.height
            font.pointSize: mainStyle.font.size
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
    property string inputText: ""
    Keys.onReleased: {
     if (event.key === Qt.Key_Back && stack.depth > 1) {
      stack.pop();
      event.accepted = true;
     }
     if (typeof stack.currentItem.keyInput==='function'){
       stack.currentItem.keyInput(event);
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
    /*
    Behavior on opacity {
      OpacityAnimator {
        easing.type: Easing.InCubic;
        duration: 150
      }
    }
    */
    Text {
      anchors.centerIn: parent
      clip: true
      text: application.message
    }
  }

  OverView {
    id: overview
  }



}
