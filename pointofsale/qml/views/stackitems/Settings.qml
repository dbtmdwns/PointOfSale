import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import "../../controlls"
import "../../styles"

StackViewItem {
    id: root
    title: "Einstellungen"

    property int _labelWidth: 300
    doneText: qsTr("Fertig") + "\uf00c"

    function onDoneClicked(){
        //application.debug('Settings','onDoneClicked', url.text)
        application.remote.url = url.text;
        //application.aurl = aurl.text;
        application.remote.client = client.text;
        application.remote.username = username.text;
        application.remote.password = password.text;

        application.printerResolution = printerResolution.text;
        application.paperWidth = paperWidth.text;
        application.paperHeight = paperHeight.text;

        //application.department = department.text;
        //application.receipt = receipt.text;
        //application.items_group = items_group.text;

        application.saveSettings();
        stackView.pop();
    }

    Component.onCompleted: {
        url.text = application.remote.url;
        //aurl.text = application.aurl;
        client.text = application.remote.client;
        username.text = application.remote.username;
        password.text = application.remote.password;

        printerResolution.text = application.printerResolution;
        paperWidth.text = application.paperWidth;
        paperHeight.text = application.paperHeight;
        //department.text = application.department;
        //receipt.text = application.receipt;
        //items_group.text = application.items_group;
    }


    ScrollView {

        anchors.fill: parent
        flickableItem.interactive: true
        contentItem : Rectangle {
            id: frame

            width: root.width -40
            height: 80 * 8
            color: "transparent"



            Rectangle {
                id: line0
                width: frame.width
                height: url.height


                LabeledTextField {
                    id: url
                    width: parent.width
                    label: qsTr("URL")
                    text: ""
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }

            Rectangle {
                id: line1
                y: 80 * 1
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: client
                    width: parent.width
                    label: qsTr("Client")
                    text: ""
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }


            Rectangle {
                id: line2
                y: 80 * 2
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: username
                    width: parent.width
                    label: qsTr("Login")
                    text: ""
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }




            Rectangle {
                id: line3
                y: 80 * 3
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: password
                    width: parent.width
                    label: qsTr("Password")
                    text: ""
                    echoMode: TextInput.Password
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }




            Rectangle {
                id: line4
                y: 80 * 4
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: printerResolution
                    width: parent.width
                    label: qsTr("Drucker-Auflösung")
                    text: "180"
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }

            Rectangle {
                id: line5
                y: 80 * 5
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: paperWidth
                    width: parent.width
                    label: qsTr("Bon-Breite")
                    text: "80"
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }

            Rectangle {
                id: line6
                y: 80 * 6
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: paperHeight
                    width: parent.width
                    label: qsTr("max. Bon-Länge")
                    text: "500"
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }


/*
            Rectangle {
                id: line7
                y: 80 * 7
                width: parent.width
                height: client.height


                Rectangle {
                    id: prnBtn
                    width: parent.width - _labelWidth
                    x: _labelWidth
                    color: "gray"

                    Text{
                      color: "white"
                      text: "Test-Druck"
                    }

                    MouseArea {
                      id: mouse
                      anchors.fill: parent
                      anchors.margins: -10
                      onClicked: {
                        application.posPrinter.setup( paperHeight.text*1, paperWidth.text*1, paperHeight.text*1)
                        application.posPrinter.print("<html><body>Test Text</body></html>");
                      }
                    }
                }
            }

*/
/*
            Rectangle {
                id: line4
                y: 80 * 4
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: department
                    width: parent.width
                    label: qsTr("Office")
                    text: ""
                    style: touchStyle
                    labelLeftSpace: 40
                    labelWidth: _labelWidth
                }
            }

            Rectangle {
                id: line5
                y: 80 * 5
                width: parent.width
                height: client.height



                LabeledTextField {
                    id: receipt
                    width: parent.width
                    label: qsTr("Report")
                    text: ""
                    style: touchStyle
                    labelLeftSpace: 40
                    labelWidth: _labelWidth
                }
            }


            Rectangle {
                id: line6
                y: 80 * 6
                width: parent.width
                height: client.height


                LabeledTextField {
                    id: items_group
                    width: parent.width
                    label: qsTr("Article group")
                    text: ""
                    style: touchStyle
                    labelLeftSpace: 40
                    labelWidth: _labelWidth
                }
            }

            Rectangle {
                id: line7

                y: 80 * 7

                width: frame.width
                height: aurl.height

                LabeledTextField {
                    id: aurl
                    width: parent.width
                    label: qsTr("Auth-URL")
                    text: ""
                    style: touchStyle
                    labelWidth: _labelWidth
                    labelLeftSpace: 40
                }
            }
            */
        }

    }

    Component {
        id: touchStyle

        TextFieldStyle {
            textColor: "white"
            font.pixelSize: 28
            property int borderWidth: 2
            background: Item {
                implicitHeight: 50
                implicitWidth: parent.width

                Rectangle{
                    height: parent.height
                    color: "#212126"
                    border.color: "#09c"
                    border.width: borderWidth
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Rectangle{
                    height: parent.height - borderWidth*2
                    color: "#212126"
                    border.width: 0
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }
    }
}
