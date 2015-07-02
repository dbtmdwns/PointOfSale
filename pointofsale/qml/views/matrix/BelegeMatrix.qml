import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../../controlls"
import "../../views"
import "../../styles"

MatrixField{
    Component.onCompleted: {
        application.reportStore.oldReportsUpdate = function(){
            fields = application.reportStore.oldReports;
        }
        console.log ('BelegeMatrix.qml','deprecated');
    }
//displayTemplate:"<table><tr><td>{belegnummer}<br/>{zeit}</td><td valign='top'><b>{brutto} €</b></td></tr>"
    columns: 1
    rows: 12
}
