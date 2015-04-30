import QtQuick 2.0
import "../../controlls"
import "../../singleton"

StackViewItem {
    title: qsTr("Exit")
    Component.onCompleted: {
      App.wawiLogout(function(){      });
      Qt.quit();
    }
}
