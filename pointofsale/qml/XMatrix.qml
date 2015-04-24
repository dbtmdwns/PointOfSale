import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../controlls"
import "../views"
import "../styles"
import "../singleton"

Grid {
     id: grid
     property var fields: []
     signal fieldSelected(var item)
     spacing: 8
     columns: 1
     rows: 1
     Repeater {

         model: columns*rows
         Rectangle {


             property bool isHidden: (typeof fields==='undefined') || (typeof fields[index]==='undefined') || (typeof fields[index].isHidden)



             MouseArea {
                 id: mouse
                 anchors.fill: parent
                 anchors.margins: -10
                 onClicked: {
                     if (typeof fields==='object'){
                         if (typeof fields[index]!=='undefined'){
                            fieldSelected( fields[index] )
                         }
                     }
                 }
             }

         }
     }

 }
