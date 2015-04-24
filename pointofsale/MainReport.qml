import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"

StackViewItem {

    width: parent.width
    height: parent.height
    title: qsTr("Report")



    Waregroups{
        id: wareGroups
    }

    StackedView{
        property string title: "Warengruppe"
        id: itemChooser
        initialItem: wareGroups
        x: 0
        y: 0
        width: (parent.width-10) /2
        height: parent.height
    }

    ReportAndInput {
        id: rai
        x: itemChooser.width+itemChooser.x+10
        y: 0
        width: (parent.width-10) /2
        height: parent.height

        Text {
            anchors.centerIn: rai
            text: rai.width + 'x' + rai.height
        }
    }

}
