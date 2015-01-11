import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"
import "../singleton"
import "../views/matrix"

StackViewItem {
    id: framedView
    width: parent.width
    height: parent.height
    title: qsTr("Kasse")

    property int spacing: 8


    Component.onCompleted: {

    }

    Rectangle{
        id: rightFrame
        width: App.leftMatrixWidth

        height: framedView.height

        color: "transparent"
        Image{
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: App.left_logo_file
            Component.onCompleted: {
                console.log( App.left_logo_file );
            }
        }
    }

    Rectangle{
        id: view
        color: "transparent"
        width: framedView.width - rightFrame.width - leftFrame.width
        height: rightFrame.height
        x: rightFrame.width
        y:0


        Rectangle{
            id: mmFrame
            x: spacing
            y: spacing
            color: "transparent"
            width: (view.width-spacing*2) * 0.75
            height: view.height -spacing*2

            clip: true

            Rectangle{
                id: mFrame
                opacity: ( (ReportStore.currentMode==='pay') )?0:1
                Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 250 } }
                Behavior on x { NumberAnimation{  easing.type: Easing.InCubic; duration: 250 } }
                color: "transparent"
                x: ( (ReportStore.currentMode==='pay') )?-1.2*parent.width:0
                y: 0
                width: parent.width
                height: parent.height


                Rectangle{
                    id: waregroupChooser
                    x: spacing
                    y: spacing
                    color: "transparent"
                    width: (mFrame.width - spacing*5 ) * 0.10
                    height: mFrame.height -relationChooser.height - spacing*2

                    WaregroupMatrix{
                        anchors.fill: parent
                        onWaregroupChanged: {
                            articleMatrix.articles = articles
                        }
                    }
                    /*
                    WarengruppenMatrix{
                        anchors.fill: parent
                        fields: ReportStore._warengruppen
                        onFieldSelected:{
                            articleMatrix.fields = ReportStore.getArtikel(item.warengruppe)
                            ReportStore.add( item );
                        }
                    }
                    */
                }

                Rectangle{
                    id: itemChooser
                    color: "transparent"
                    x: waregroupChooser.width+waregroupChooser.x+spacing
                    y: spacing
                    width: (mFrame.width-spacing*5) * 0.90
                    height: mFrame.height -relationChooser.height -spacing*2


                    ArticleMatrix{
                        id: articleMatrix
                        anchors.fill: parent
                    }
                    /*
                    ArtikelMatrix{
                        id: articleMatrix
                        anchors.fill: parent

                    }
                    */

                }


                Rectangle{
                    id: relationChooser
                    color: "transparent"
                    x: spacing
                    y: itemChooser.y+itemChooser.height+spacing
                    width: (mFrame.width-spacing*2)
                    height: mFrame.height*0.05


                    RelationMatrix{
                        id: relationMatrix
                        anchors.fill: parent
                    }
                }


            }

            Rectangle{
                id: mFrame2
                opacity: ( (ReportStore.currentMode==='pay') )?1:0
                Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 250 } }
                Behavior on x { NumberAnimation{  easing.type: Easing.InCubic; duration: 250 } }
                color: "transparent"
                x: ( (ReportStore.currentMode!=='pay') )?-1.2*parent.width:0
                y: 0
                width: parent.width
                height: parent.height

                Rectangle {
                    id: givenDisplay
                    width: parent.width
                    y: 10
                    height: 80
                    color: "white"
                    radius: 5
                    Text{
                        id: givenText
                        font.family: "Helvetica"
                        font.pixelSize: mainStyle.font.size
                        width: parent.width - 10
                        height: parent.height - 10
                        anchors.centerIn: parent
                        clip: true

                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight

                        font.pointSize: givenDisplay.height*0.5
                        color: (ReportStore.given<ReportStore.total)?"red":"black"
                        text: "Gegeben: "+( ReportStore.given.toFixed(2) )
                    }
                }

                Rectangle {
                    id: givebackDisplay
                    y: givenDisplay.y+givenDisplay.height+10
                    width: parent.width
                    height: 80
                    color: "white"
                    radius: 5
                    Text{
                        id: givebackText
                        font.family: "Helvetica"
                        font.pixelSize: mainStyle.font.size
                        width: parent.width - 10
                        height: parent.height - 10
                        anchors.centerIn: parent
                        clip: true

                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight

                        font.pointSize: givebackDisplay.height*0.5
                        color: (( ReportStore.given - ReportStore.total )<0)?"red":"black"
                        text: "Rückgeld: "+( ( ReportStore.given - ReportStore.total ).toFixed(2) )
                    }
                }

                BezahlenMatrix{
                    y: givebackDisplay.y+givebackDisplay.height+10
                    width:  parent.width
                    height: 80*5
                    onFieldSelected: {
                        ReportStore.cmd(item.cmd,item.val);
                    }

                }
            }
        }

        ReportAndInput {
            id: rai
            x: mmFrame.width+mmFrame.x+spacing
            y: spacing
            width: (view.width-spacing*2) * 0.25
            height: view.height-spacing*2
            /*

            */
        }





        Rectangle{
            anchors.centerIn: view
            opacity: (ReportStore.message==="")?0:1
            color: "white"
            radius: 5
            width: view.width*0.30
            height: view.height*0.10
            Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: ReportStore.message
            }
        }
    }


    Rectangle{
        id: leftFrame

        x: view.width+rightFrame.width
        width: App.rightMatrixWidth
        height: framedView.height

        color: "transparent"

        BelegeMatrix{
            Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 500 } }
            opacity: ReportStore.reportMode?1:0
            anchors.fill: parent
            anchors.margins: spacing
            onFieldSelected:{
                ReportStore.cmd("OPENREPORT",item);
            }
        }

    }


}
