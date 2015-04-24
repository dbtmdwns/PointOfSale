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

     property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
     property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)

     signal relationChanged(var relation)


     property var relations: []


     Component.onCompleted: {
         App.getMatrixRelations(function(res){
             var _hash = {};
             for(var i in res.data){
                 if (typeof _hash[ res.data[i].name ] === 'undefined'){
                     _hash[ res.data[i].name ] = {
                        color: App.rgb_hex_Color(res.data[i].farbe),
                        title: res.data[i].name,
                        name: res.data[i].name,
                        kundennummer: res.data[i].kundennummer,
                        kostenstelle: res.data[i].kostenstelle,
                        preiskategorie: res.data[i].preiskategorie,
                        steuerschluessel: res.data[i].steuerschluessel
                     };
                 }

             }
             var wgs = []
             for(var w in _hash){
                 wgs.push(_hash[w]);
             }

             relations = wgs;
             ReportStore.cmd("SET RELATION",wgs[0]);
         });
     }

     anchors.fill: parent
     spacing: 8
     columns: App.relationColumns
     rows: App.relationRows

     move: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }
     add: Transition {
         NumberAnimation { properties: "x,y"; easing.type: Easing.OutBounce; duration: 100 }
     }

     Repeater {
         model: columns*rows

         Rectangle {
             property bool isHidden: (typeof relations==='undefined') || (typeof relations[index]==='undefined')
             width: grid.itemWidth
             height: grid.itemHeight
             radius: 5
             color: isHidden?"transparent": relations[index].color
             opacity: mouse.pressed?0.5:1
             Behavior on opacity { OpacityAnimator{  easing.type: Easing.InCubic; duration: 50 } }



             Text {
                font.pixelSize: mainStyle.font.size
                width: grid.itemWidth-spacing
                height: grid.itemHeight-spacing
                color: isHidden?"transparent":"white"
                style: Text.Outline
                styleColor: isHidden?"transparent":"black"
                anchors.centerIn: parent
                wrapMode: Text.WordWrap
                text: isHidden ? "" : relations[index].title
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                clip: true
             }

             MouseArea {
                 id: mouse
                 anchors.fill: parent
                 //anchors.margins: -10
                 onClicked: {
                     if (typeof relations==='object'){
                         if (typeof relations[index]!=='undefined'){
                            ReportStore.cmd("SET RELATION",relations[index]);
                            articleMatrix.articles = ReportStore.getArtikel(ReportStore._warengruppe);

                            relationChanged(relations[index]);

                         }
                     }


                 }
             }
         }
     }
 }
