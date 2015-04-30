import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../../views"
import "../../controlls"
import "../../singleton"
import "../matrix"

StackViewItem {
  id: framedView
  width: parent.width
  height: parent.height
  title: qsTr("Kasse")

  property int rows: 8
  property int articleColumns: 2


  // Logo column
  Rectangle {
    id: logo
    width: parent.width * 0.25
    height: parent.height

    Image{
      anchors.fill: parent
      fillMode: Image.PreserveAspectFit
      source: App.left_logo_file
    }
  }

  Matrix{
    id: waregroupMatrix

    x: logo.left+logo.width
    width: parent.width * 0.25
    height: parent.height

    columns: 1
    rows: framedView.rows
    template: '{text}<br/>'
    Component.onCompleted: {
      addList( Configurations.getWaregroups() )
    }
    onSelected: {
      articleMatrix.addList(Configurations.getArticles(item.text))
    }
  }

  Matrix{
    id: articleMatrix

    x: waregroupMatrix.left+waregroupMatrix.width
    width: parent.width * 0.25
    height: parent.height

    columns: framedView.articleColumns
    rows: framedView.rows
  }
}
