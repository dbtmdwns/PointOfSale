import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../../controlls"
import "../../views"
import "../../styles"
import "../../singleton"

MatrixField{

    property var articles: []
    fields: articles
    columns: App.articleColumns
    rows: App.articleRows
    onFieldSelected:{
        ReportStore.add( item[index] );
    }
}
