import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


import "../../controlls"
import "../matrix"


import "../../js/Shunt.js" as Shunt
import "../../js/Template.js" as Template
import "../../js/SimpleSAX.js" as SimpleSAX



StackViewItem {
  title: qsTr("Logging")

  width: parent.width
  height: parent.height

  property int spacing: 8
  property int layoutWUnit: (parent.width)/12
  property int layoutHUnit: (parent.height)/12

  property int listWidth: 12
  property int listHeight: 11
  property int listX: 0
  property int listY: 1

  Rectangle {
    id: rclist
    x: spacing+(layoutWUnit*(0))
    y: spacing+(layoutHUnit*(0))
    width: layoutWUnit * listWidth - spacing
    height: layoutHUnit * 1 - spacing

    color: "transparent"
    Matrix {
      id: clist
      anchors.fill: parent
      template: "{text}"
      rows: 1
      columns: 4
      Component.onCompleted: {
        var appendList = [];
        appendList.push({
          text: 'Fehler',
          fn: 'getError',
          displayBackgroundColor: '#ee9999'
        });
        appendList.push({
          text: 'Warnungen',
          fn: 'getWarn',
          displayBackgroundColor: '#eeee99'
        });
        appendList.push({
          text: 'Informationen',
          fn: 'getInfo',
          displayBackgroundColor: '#99ee99'
        });
        appendList.push({
          text: 'Debug',
          fn: 'getDebug',
          displayBackgroundColor: '#9999ee'
        });

        clist.addList(appendList);
      }
      onSelected: {

        var listItems = application.logger[item.fn]();
        var appendList = [];
        for(var i=0;i<listItems.length;i++){
          appendList.push({
            text: listItems[i]
          });
        }
        list.addList(appendList);
      }
    }
  }

  Rectangle {
    id: rlist

    x: spacing+(layoutWUnit*(listX))
    y: spacing+(layoutHUnit*(listY))
    width: layoutWUnit * listWidth - spacing
    height: layoutHUnit * listHeight - spacing

    color: "transparent"
    Matrix {
      id: list
      anchors.fill: parent
      template: "{text}"
      rows: 20
      columns: 1
      Component.onCompleted: {
        var listItems = application.logger.getError();
        var appendList = [];
        for(var i=0;i<listItems.length;i++){
          appendList.push({
            text: listItems[i]
          });
        }
        list.addList(appendList);
      }
      onSelected: {

      }
    }
  }
}
