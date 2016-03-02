import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import "../../controlls"
import "../../styles"

import "../matrix"

Rectangle {
  id: root
  property string modeText: 'Rabatt'
  width: parent.width
  height: parent.height
  color: "blue"

  function refresh(){
    var list = [];
    application.reportStore.sum();
    console.log('rabatt','on complete',JSON.stringify(application.reportStore.positions,null,1));
    //console.log('rabatt list',app.reportStore.total);
    list.push({text: "5%",qoute:0.95,total:application.reportStore.total*(0.95),displayBackgroundColor: "#ddddff"});
    list.push({text: "10%",qoute:0.90,total:application.reportStore.total*(0.90)});
    list.push({text: "15%",qoute:0.85,total:application.reportStore.total*(0.85)});
    list.push({text: "20%",qoute:0.80,total:application.reportStore.total*(0.80)});
    list.push({text: "25%",qoute:0.75,total:application.reportStore.total*(0.75)});
    list.push({text: "30%",qoute:0.70,total:application.reportStore.total*(0.70)});

    list.push({text: "Abbruch",total:application.reportStore.total,displayBackgroundColor: "#ff1111"});
    console.log('rabatt list',JSON.stringify(list,null,1));
    rabattMatrix.addList(list);
  }


  function cmd(cmdtype, val, input) {

    if (cmdtype === 'BACK') {
      if (application.reportStore.referenzString.length > 0) {
        application.reportStore.referenzString = application.reportStore.referenzString.substring(0, application.reportStore.referenzString.length - 1);
      }
      return;
    }

    if (cmdtype === 'CANCLE LAST') {
      application.reportStore.currentMode = 'amount';
    }

    if (cmdtype === 'ENTER') {
      application.reportStore.refItem.referenz = application.reportStore.referenzString;
      application.reportStore.currentMode = 'amount';

      //console.log(JSON.stringify(application.reportStore.refItem,null,1));

      //application.reportStore.refItem.anzahl = 1;

      application.reportStore.add(application.reportStore.refItem, true);
    }

    if (cmdtype === 'NUM') {
      if (application.reportStore.number === -1) {
        application.reportStore.referenzString += val + ""
        return;
      }
    }
  }


  Matrix {
    id: rabattMatrix
    anchors.fill: parent

    columns: 1
    rows: 12
    template: "{text} {euro(total)}"

    Component.onCompleted: {

      if (application.plugins===null){
        application.plugins={};
      }

      application.plugins['reportplugin.rabatt'] = root;
      refresh()

    }

    onSelected: {
      if (item.total===application.reportStore.total){
        application.reportStore.currentMode = 'amount';
        return;
      }else{
        var rabatt = Math.abs(Math.round((item.total-application.reportStore.total)*100)/100);
        var last;
        var quote=1;

        for(var i=0;i<application.reportStore.positions.length;i++){

        }
        for(var i=0;i<application.reportStore.positions.length;i++){
          if (application.reportStore.positions[i].artikel.indexOf("Pfand")>0){

          }else{
            last = application.reportStore.positions[i];
            application.reportStore.positions[i].brutto_preis*=item.quote;
            application.reportStore.calcPos(i);

          }
        }
      }
    }
  }

}
