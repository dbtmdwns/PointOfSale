import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

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
