import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Button{
    property alias amount: amountText.text
    property bool current: false
    property int notifySize: height / 5
    style: touchStyle
    checked: false
    checkable: true

    Rectangle{
        radius: notifySize
        x: parent.width - notifySize/3 - amountText.text.length * notifySize
        y: notifySize/3
        width: amountText.text.length * notifySize
        height: notifySize
        color: "red"
        border.color: "white"
        border.width: 1
        antialiasing: true
        opacity: (amountText.text === "0" )?0:1

        Text{
            id: amountText
            text: "."
            color: "white"
            font.pixelSize: parent.height*0.8
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

        }
    }

    Component {
        id: touchStyle
        ButtonStyle {
            background: Rectangle{
                implicitWidth: control.width
                implicitHeight: control.height
                border.color: current?(control.pressed ? "#d55" : "#d66"):(control.pressed ? "#555" : "#666")
                border.width: 1
                radius: 5
                gradient: Gradient {
                    GradientStop { position: 0 ; color: control.checked?(control.pressed ? "#00a" : "#11a"):(control.pressed ? "#000" : "#111") }
                    GradientStop { position: 1 ; color: control.checked?(control.pressed ? "#11a" : "#22a"):(control.pressed ? "#111" : "#222") }
                }
            }
            label: Text {
                clip: true
                text: control.text
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 23
                renderType: Text.NativeRendering
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

        }
    }
}
