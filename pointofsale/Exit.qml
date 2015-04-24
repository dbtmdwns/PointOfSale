import QtQuick 2.0
import "../controlls"

StackViewItem {
    title: qsTr("Exit")
    Component.onCompleted: {
        //App.logout(function(){
            Qt.quit();
        //});
    }
}
