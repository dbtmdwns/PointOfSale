import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../views"
import "../../controlls"

import "../matrix"
import "../plugins"




StackViewItem {
    title: qsTr("Kassenabschluss")

    width: parent.width
    height: parent.height

    property int spacing: 8
    property int layoutWUnit: (parent.width)/12
    property int layoutHUnit: (parent.height)/12

    property int listWidth: 6
    property int listHeight: 10
    property int listX: 0
    property int listY: 1

    property int viewWidth: 6
    property int viewHeight: 11
    property int viewX: 6
    property int viewY: 0

    Component.onCompleted: {
    }
    Rectangle {
      id: rssaldo

      x: spacing+(layoutWUnit*(listX))
      y: spacing+(layoutHUnit*(0))
      width: layoutWUnit * listWidth - spacing
      height: layoutHUnit * 1 - spacing

      color: "transparent"
      Matrix {
        id: ssaldo
        anchors.fill: parent
        template: "{euro(total)}"
        rows: 1
        columns: 1
        Component.onCompleted: {
        }
        onSelected: {

        }
      }
    }

    Rectangle {
      id: resaldo

      x: spacing+(layoutWUnit*(listX))
      y: spacing+(layoutHUnit*(listHeight+1))
      width: layoutWUnit * listWidth - spacing
      height: layoutHUnit * 1 - spacing

      color: "transparent"
      Matrix {
        id: esaldo
        anchors.fill: parent
        template: "<b>{euro(total)}</b>"
        rows: 1
        columns: 1
        Component.onCompleted: {
        }
        onSelected: {

        }
      }
    }

    Rectangle {
      id: list


      x: spacing+(layoutWUnit*listX)
      y: spacing+(layoutHUnit*listY)
      width: layoutWUnit * listWidth - spacing
      height: layoutHUnit * listHeight - spacing

      color: "transparent"
      Matrix {
        id: listMatrix
        anchors.fill: parent
        template: "<table width='100%'><tr><td width='20%'>{date}</td><td width='20%'>{time}</td><td width='30%'>{reportnumber}</td><td  width='30%' align='right'>{euro(total)}</td></tr></table>"
        rows: 15
        columns: 1
        Component.onCompleted: {
          application.remote.getCashBox(function(liste,start,ende,kasse){
            listMatrix.addList(liste);

            ssaldo.addList([{
              total: start,
              displayBackgroundColor: '#112211'
            }]);

            esaldo.addList([{
              total: ende,
              displayBackgroundColor: '#113311'
            }]);

            dme.addList([{
              total: "",
              displayBackgroundColor: '#11aa11'
            }]);
            refreshView(liste,start,ende,kasse,false);
          });

        }
        onSelected: {

        }
      }

    }

    function refreshView(liste,start,ende,kasse,print){
      var tpl = [
      '<line><box fontSize="0.6" width="8" padding="0.01"></box>',
      '</line>',
      '<line><box fontSize="0.6" width="8" padding="0.01"></box>',
      '</line>',

      '<line>',
      '<box fontSize="0.6" width="8" padding="0.01">',
      'Kassenabschluss</box>',
      '</line>',

      '<line>',
      '<box fontSize="0.5" width="8" padding="0.01">',
      'Kasse: '+kasse+'</box>',
      '</line>',


      '<line>',
      '<box fontSize="0.3" width="8" padding="0.01">Datum/Zeit: {date}/ {time}</box>',
      '</line>',
      '<line><box fontSize="0.6" width="8" padding="0.01"></box>',
      '</line>',
      '<line>',
      '<box fontSize="0.5"  align="right" width="8" padding="0.01">Anfangsbestand: {euro(start)}</box>',
      '</line>',

      '<foreach item="list">',
        '<line>',
          '<box fontSize="0.3" width="2" align="left" paddingLeft="0">{reportnumber}</box>',
          '<box fontSize="0.3" width="2" align="left" paddingLeft="0">{date}</box>',
          '<box fontSize="0.3" width="2" align="left" paddingLeft="0">{time}</box>',
          '<box fontSize="0.3" width="2.0" align="right" paddingLeft="0.01">{euro(total)}</box>',
        '</line>',
      '</foreach>',
      '<line><box fontSize="0.6" width="8" padding="0.01"></box>',
      '</line>',

      '<line>',
      '<box fontSize="0.5"  align="right" width="8" padding="0.01">Endbestand: {euro(stop)}</box>',
      '</line>',

      '<line><box fontSize="0.3" width="8" padding="0.01">Name/ Unterschrift</box>',
      '</line>',
      '<line><box fontSize="0.3" width="8" padding="0.01">____________________</box>',
      '</line>',
      '<line><box fontSize="0.3" width="8" padding="0.01">____________________</box>',
      '</line>',

      ].join("\n");
      var zeit = (new Date()).toISOString().substring(11, 16);
      var datum = (new Date()).toISOString().substring(0, 10);
      var data = {
        date: datum,
        time: zeit,
        start: start,
        stop: ende,
        list: liste
      };
      view.refresh( data , print, tpl);
    }


    Rectangle {
      radius: 5
      x: spacing+(layoutWUnit*viewX)
      y: spacing+(layoutHUnit*viewY)
      width: layoutWUnit * viewWidth - spacing
      height: layoutHUnit * viewHeight - spacing
      //clip: true
      ReportView{
        id: view
        width: parent.width
        height: parent.height
      }

    }


    Rectangle {
      id: done

      x: spacing+(layoutWUnit*(viewX))
      y: spacing+(layoutHUnit*(viewHeight))
      width: layoutWUnit * viewWidth - spacing
      height: layoutHUnit * 1 - spacing

      color: "transparent"
      Matrix {
        id: dme
        anchors.fill: parent
        template: "<b>Abschliessen</b>"
        rows: 1
        columns: 1
        Component.onCompleted: {

        }
        onSelected: {


          application.remote.getCashBox(function(liste,start,ende,kasse){
            refreshView(liste,start,ende,kasse,true);
            application.remote.closeCashBox(function(){
              application.remote.getCashBox(function(liste,start,ende,kasse){
                refreshView(liste,start,ende,kasse,false);
              });
            });
          });


        }
      }
    }


}
