import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../controlls"
import "../../views"
import "../../styles"

MatrixField{

    property var articles: []
    fields: articles
    columns: application.articleColumns
    rows: application.articleRows
    onFieldSelected:{
        application.reportStore.add( item[index] );
    }
}
