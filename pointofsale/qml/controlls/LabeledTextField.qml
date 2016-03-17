import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2


Rectangle {
    property int labelWidth: 100
    property alias label: label.text
    property alias text: textFld.text
    property alias inputFLD: textFld
    property alias echoMode: textFld.echoMode
    /*property alias style: textFld.style*/
    property alias labelLeftSpace: label.x
    property color labelColor: "white"
    property int labelFontPixelSize: mainStyle.font.size

    signal changed(string content)
    signal done()



    Label {
        id: label
        opacity: 0.5
        text: "LBL"
        width: labelWidth
        height: textFld.height
        verticalAlignment: Text.AlignVCenter
        color: labelColor
        font.pointSize: labelFontPixelSize
    }

    
    TextInput {
        x: labelWidth + label.x
        id: textFld
        width: parent.width - labelWidth - 2*label.x
        text: "Text input"

        onTextChanged: {
           //changed(text);

        }
        onAccepted:{
            done();
        }

    }

}
