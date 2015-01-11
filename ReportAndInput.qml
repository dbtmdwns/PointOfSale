import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtWebKit 3.0
import "../controlls"
import "../views"
import "../styles"
import "../singleton"

Rectangle {
    id: root
    color: "transparent"

    Component.onCompleted: {

        ReportStore.styles = mainStyle;
        ReportStore.reportView = webview;
        ReportStore.update = function(){
            webview.loadHtml(getReportHTML());

        }

        ReportStore.sum();
    }


    function getReportHTML(){
        return ReportStore.getHTML(true);
    }


    Column {
        id: mcol
        anchors.fill: parent
        spacing: 5

        Rectangle {
            id: reportDisplay
            color: "transparent"
            width: root.width
            height: root.height/2 - mcol.spacing

            Column {
                id: rep
                anchors.fill: parent
                spacing: 5

                Rectangle {
                    id: numberDisplay
                    width: reportDisplay.width
                    height: 80
                    color: "white"
                    radius: 5
                    Text{
                        id: reportText
                        font.family: "Helvetica"
                        font.pixelSize: mainStyle.font.size
                        width: numberDisplay.width - 10
                        height: numberDisplay.height - 10
                        anchors.centerIn: parent
                        clip: true

                        verticalAlignment:  Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight

                        font.pointSize: numberDisplay.height*0.6
                        color: (ReportStore.lastTotal===0)?"black":"black"
                        text: (ReportStore.lastTotal===0) ? (ReportStore.total.toFixed(2) +" €") : (""+ReportStore.lastTotal.toFixed(2) +" €")
                    }
                }


                Rectangle {
                    radius: 5
                    width: root.width
                    height: reportDisplay.height - numberDisplay.height - rep.spacing
                    clip: true
                    ScrollView {
                        id: webview_scroll
                        width: parent.width
                        height: parent.height
                        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
                        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                        WebView {
                            id: webview
                            url: "about:blank"

                           // width: parent.width*0.9
                           // height: parent.height*0.9

                            onLoadingChanged: {
                                if (loadRequest.status === WebView.LoadSucceededStatus){

                                }
                            }

                        }
                    }
                }
            }



        }

        Rectangle {
            color: "transparent"
            width: root.width
            height: root.height/2

            ButtonPanel{
                id: reportInput
                height: (parent.height - parent.rowSpacing )/2
            }
        }

    }
}
