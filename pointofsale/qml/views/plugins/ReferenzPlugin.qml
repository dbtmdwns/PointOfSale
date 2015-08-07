import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../controlls"
import "../../styles"

Rectangle {
  property string modeText: 'Referenz'
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
      application.reportStore.refItem.referenz = application.reportStore.referenzString;
      application.reportStore.currentMode = 'amount';
      application.reportStore.add(application.reportStore.refItem, true);
    }

    if (cmdtype === 'NUM') {
      if (application.reportStore.number === -1) {
        application.reportStore.referenzString += val + ""
        return;
      }
    }
  }

  Text {
    color: "white"
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Referenz: " + application.reportStore.referenzString
  }

}
