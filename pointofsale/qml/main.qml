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
  title: "----"// App.posTitle

  App {
    id: application
  }
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

  OverView {
    id: overview
  }

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




}
