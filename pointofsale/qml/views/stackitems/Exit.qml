import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../controlls"

StackViewItem {
    title: qsTr("Exit")
    Component.onCompleted: {
      application.logout(function(){      });
      Qt.quit();
    }
}
