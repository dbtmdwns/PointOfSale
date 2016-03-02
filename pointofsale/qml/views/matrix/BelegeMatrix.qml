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
        application.logger.info((new Date()).toISOString()+" - "+'BelegeMatrix.qml deprecated');
    columns: 1
    rows: 12
}
}
