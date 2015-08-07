import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../controlls"
import "../../styles"

Rectangle {
  property string modeText: 'GutscheinAusgeben'
  width: parent.width
  height: parent.height
  function cmd(cmdtype, val, input) {
    console.log(cmdtype, val, input);
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

      application.remote.shortPost({
        cmp: 'cmp_gutscheine',
        page: 'ajax/ausgabegutschein/plugin'
      }, function(err,res){
        if (err){
          application.displayMessage("Der Code kann nicht geprüft werden");
        }else{
          if (res.success === true){

            application.reportStore.currentMode = 'price';
            application.reportStore.refItem.referenz = res.data.id;
            application.reportStore.refItem.referenzphp = '/cmp/cmp_gutscheine/plugins/ausgabegutschein/save.php';

            application.reportStore.add(application.reportStore.refItem, true);

          }else if (typeof res.message==='string') {
            application.displayMessage(res.message);
          }else if (typeof res.msg==='string') {
            application.displayMessage(res.msg);
          }

        }
        //console.log(JSON.stringify(err,null,2));
        console.log(JSON.stringify(res,null,2));
      });
    }

    if (cmdtype === 'NUM') {
      if (application.reportStore.number === -1) {
        //application.reportStore.referenzString += val + ""
        return;
      }
    }
  }

  Text {
    color: "white"
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Gutschein ausgeben<br>Klicken Sie auf Enter, um den Gutschein zu erzeugen"
  }

}
