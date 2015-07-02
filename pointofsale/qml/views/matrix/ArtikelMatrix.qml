import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
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
