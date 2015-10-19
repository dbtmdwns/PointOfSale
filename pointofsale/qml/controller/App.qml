
import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {

  property string message: ""
  property alias local: myLocal
  property alias remote: myRemote

  Timer {
    id: messageHideTimer
    interval: 1000
    running: false
    repeat: false
    onTriggered: {
      messageHideTimer.stop();
      message = "";
    }
  }

  function displayMessage(msg, hold) {
    if (typeof hold === 'undefined') {
      hold = false;
    }
    if (hold) {
      messageHideTimer.interval = 30000;
    } else {
      messageHideTimer.interval = 1000;
    }
    message = msg;
    console.log(message);
    messageHideTimer.start();
  }


  Local {
    id: myLocal
  }

  property alias reportStore : myReportStore
  ReportStore {
    id: myReportStore
  }


  Remote {
    id: myRemote
  }

  property int dpi: 72
  property double density: 1
  property int dbsize: 1024*1024* 50 // 50MB
  property string sessionID: ""
  property string async: "0"

  property bool usePOSPrinter: true

  property string receipt: ""
  property string department: ""
  property string reference_number: ""
  property string items_group: ""
  property string fullscreen: ""
  property string posTitle: "tualo POS"

  property int leftMatrixWidth: 100
  property int rightMatrixWidth: 100
  property int scale: 2
  property int fontSize: (dpi/109) * configFontSize
  property int buttonFontSize: (dpi/109) * configButtonFontSize
  property int configFontSize: 14
  property int configButtonFontSize: 14

  property int totalDisplayRows: 1

  property int windowWidth: 800;

  property int leftSideColumns: 3
  property int rightSideColumns: 3

  property int waregroupColumns: 1
  property int waregroupRows: 10

  property int relationColumns: waregroupColumns + articleColumns
  property int relationRows: 1

  property int articleColumns: 8
  property int articleRows: 10



  property string template_file: ""
  property string template: ""
  property string logo_file: ""
  property string left_logo_file: ""
  property string fixview: ""


  property string kasse: ""
  property string zahlart: ""
  property string lager: "0"
  property string tabellenzusatz: "BARVERKAUF"
  property string printerName: "EPSON_TM_T88V"


  property var use_date
  property var relationList;
  property var db;

  property alias posPrinter: posPrinter

  PosPrinter {
    id: posPrinter
  }

  function ratio(nDPI){
    if(typeof nDPI=='undefined'){
      nDPI = Screen.pixelDensity  * 24.5;
    }
    console.log('nDPI',nDPI);
    return nDPI/72;
  }

  function rgb_hex_Color(str) {
    var red = 0;
    var green = 0;
    var blue = 0;
    var alpha = 1;
    if (typeof str==='undefined'){
      str='rgb(100,100,100)';
    }
    if (str.indexOf("rgb(") === 0) {
      str = str.replace("rgb(", "");
      str = str.replace(")", "");
      str = str.replace(";", "");
      var a = str.split(",");

      if (a.length === 3) {
        red = a[0]; // /255;
        green = a[1]; // /255;
        blue = a[2]; // /255;
      }
    }
    if (str.indexOf("#") === 0) {

    }
    var r = Number(red).toString(16);
    var g = Number(green).toString(16);
    var b = Number(blue).toString(16);
    if (r.length < 2) {
      r = '0' + r;
    }
    if (g.length < 2) {
      g = '0' + g;
    }
    if (b.length < 2) {
      b = '0' + b;
    }
    //return Qt.rgba( red,  green,  blue,  alpha);
    return '#' + r + g + b
  }




  Component.onCompleted: {

    template = '
    <line>
      <box fontSize="0.22" width="8" padding="0.01">
      Musterfirma
      Musterweg 1
      98765 Musterort
      </box>
    </line>

    <foreach item="positions">
      <line>
        <box fontSize="0.2" width="0.5" align="right" paddingLeft="0">
          {amount}x
        </box>
        <box fontSize="0.2" width="1.0" align="right" paddingLeft="0.01">
          {fixed(itemPriceIncludingTax)}
        </box>
        <box fontSize="0.3" width="4" paddingLeft="0.01">{article}
        </box>
        <box fontSize="0.2" width="0.5" align="right" paddingLeft="0.01">
          {percent(taxRate)}
        </box>
        <box fontSize="0.3" width="1.3" align="right" paddingLeft="0.01" paddingRight="0.1">{fixed(includingTax)}</box>
      </line>
      <if term="isNot(additionalText,\'\')">
        <line>
          <box fontSize="0.22" width="7.6" paddingLeft="0.2">{additionalText}</box>
        </line>
      </if>
    </foreach>
    <foreach item="taxes">
      <line>
        <box fontSize="0.3" width="6" align="right" paddingLeft="0">
          Steuersatz:
        </box>
        <box fontSize="0.3" width="0.6" align="right" paddingLeft="0">
          {fixed(rate)}
        </box>
        <box fontSize="0.3" width="1" align="right" paddingLeft="0.2">
          {fixed(value)}
        </box>
      </line>
    </foreach>
    ';

    /*

    */
    //    property int dpi: 72
    //    property double density: 1
    dpi = Screen.pixelDensity * 24.5
    console.log('App',Screen.pixelDensity * 24.5);

    use_date = new Date();
    db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", dbsize);

    myRemote.url = "https://tualoserver.de/ts/index.php"
    myRemote.client = "admin"
    myRemote.username = "admin"
    myRemote.password = "admin"

    db.transaction(
      function(tx) {
        // Create the database if it doesn't already exist
      tx.executeSql('CREATE TABLE IF NOT EXISTS config (key varchar(255) primary key, value TEXT)');
          tx.executeSql('CREATE TABLE IF NOT EXISTS reports ( key varchar(255), id integer, value TEXT, primary key (key,id) )');
          tx.executeSql('CREATE TABLE IF NOT EXISTS articles (key varchar(255) primary key, value TEXT)');
          tx.executeSql('CREATE TABLE IF NOT EXISTS relations (key varchar(255) primary key, value TEXT)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key varchar(255) primary key, value TEXT)');
        var rs = tx.executeSql('SELECT key,value FROM settings');
        for (var i = 0; i < rs.rows.length; i++) {
          switch (rs.rows.item(i).key) {
            case "url":
              myRemote.url = rs.rows.item(i).value;
            break;
            case "async":
              async = rs.rows.item(i).value;
              console.log( 'DB',async);
              break;
            case "client":
              myRemote.client = rs.rows.item(i).value;
              break;
            case "username":
              myRemote.username = rs.rows.item(i).value;
              break;
            case "password":
              myRemote.password = rs.rows.item(i).value;
              break;

            case "printerName":
              printerName = rs.rows.item(i).value;
              break;

          }
        }
        console.log('App.qml','complete',async);
        console.log('App.qml','complete',printerName);
        console.log('App.qml','complete',myRemote.client);
        console.log('App.qml','complete',myRemote.username);
      }
    )
  }



  function saveSettings() {
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", dbsize);
    db.transaction(
      function(tx) {
        // Create the database if it doesn't already exist
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key varchar(255) primary key, value TEXT)');

        // Add (another) greeting row
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['async', async]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['printerName', printerName]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['url', myRemote.url]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['username', myRemote.username]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['password', myRemote.password]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['client', myRemote.client]);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [async, 'async']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [printerName, 'printerName']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [myRemote.url, 'url']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [myRemote.client, 'client']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [myRemote.username, 'username']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [myRemote.password, 'password']);



      }
    )
  }








  function saveReport(kundennummer, kostenstelle, positions, gegeben, cb) {


    var json = {};
    json.id = 'Kasse ' + (new Date()).toISOString();
    json.tabellenzusatz = tabellenzusatz;
    json.datum = (new Date()).toISOString().substring(0, 10);
    json.liste = positions;
    json.gegeben = gegeben;

    json.kasse = kasse;
    json.lager = lager;
    json.zahlungsart = zahlart;
    json.kundennummer = kundennummer;
    json.kostenstelle = kostenstelle;

    console.log('App.qml','using async',async)
    if (async=='1'){
      myLocal.save(json,cb);
    }else{
      myRemote.save(json,cb);
    }

  }

  function login(cb) {
    async=0;
    console.log('App.qml','login',async);


    var cbx = function(){
      console.log('App.qml','query config',async);

      config(function() {

        console.log('App.qml','login2',async,JSON.stringify(cb,null,3));
        relations(cb);

      }.bind(this));
    }.bind(this)

    console.log('App.qml','loginx',async);
    if (async=='1'){
      cbx();
    }else{
      myRemote.login(cbx);
    }
  }

  function logout(cb) {
    myRemote.logout(cb);
  }

  function articles(cb) {
    if (async=='1'){
      myLocal.articles(cb);
    }else{
      myRemote.articles(cb);
    }
  }

  function relations(cb) {
    var cbx = function(res){
      processRelations(res,cb);
    }
    if (async=='1'){
      myLocal.relations(cbx);
    }else{
      myRemote.relations(cbx);
    }
  }

  function processRelations(res,cb){
    try{
      var _hash = {};
      for (var i in res.data) {
        if (typeof _hash[res.data[i].name] === 'undefined') {
          _hash[res.data[i].name] = {
            displayBackgroundColor: rgb_hex_Color(res.data[i].farbe),
            name: res.data[i].name,
            kundennummer: res.data[i].kundennummer,
            kostenstelle: res.data[i].kostenstelle,
            preiskategorie: res.data[i].preiskategorie,
            steuerschluessel: res.data[i].steuerschluessel
          };
        }
      }
    }catch(e){
      console.log(e.toString(),JSON.stringify(res.data,null,0))
    }
    var wgs = []
    for (var w in _hash) {
      wgs.push(_hash[w]);
    }
    relationList = wgs;
    console.log(JSON.stringify(relationList,null,0))
    cb();
  }


  function config(cb){
    if (async=='1'){
      myLocal.config(function(res){
        processConfig(res);
        cb();
      });
    }else{
      console.log('app.qml', 'myRemote config');
      myRemote.config(function(res){
        console.log('app.qml', 'myRemote config res',JSON.stringify(res,null,1));
        processConfig(res);
        console.log('app.qml', 'myRemote calling cb ***********');
        cb();
        saveSettings();
      });
    }
  }

  function processConfig(res){
    async = res.async||'0';
    
    myLocal.maxReportNumber = res.maxReportNumber;
    myLocal.minReportNumber = res.minReportNumber;
    kasse = res.kasse;
    lager = res.lager;
    zahlart = res.zahlart;
    tabellenzusatz = res.tabellenzusatz;
    if (typeof res.posTitle==='string'){
      posTitle = res.posTitle;
    }
    if (typeof res.template==='string'){
      template = res.template.replace(/#qoute;/gm,"'");
    }
    if (left_logo_file === "") {
      left_logo_file = res.left_logo
    }
  }

  /**
   * formating objects for console logging
   */
  function jsonDebug(res, intend) {
    var s = '';
    if (typeof intend === 'undefined') {
      intend = '   ';
    }
    for (var i in res) {
      s += intend;
      if (typeof res[i] === 'object') {
        s += i + ': ' + jsonDebug(res[i], intend + '   ');
      } else if (typeof res[i] === 'function') {
        s += i + ': ' + '[function]';
      } else {
        s += i + ': ' + res[i];
      }
      s += "\n";
    }
    return "{\n" + s + "\n" + intend + "}";
  }


  function html_encode_entities_object(_object) {

    for (var _property in _object) {
      if (_object.hasOwnProperty(_property)) {
        if (typeof _object[_property] === 'string') {
          _object[_property] = _object[_property].replace(/[\u00A0-\u9999<>\&]/gim, function(i) {
            return '&#' + i.charCodeAt(0) + ';';
          });
        }
        if (typeof _object[_property] === 'object') {
          _object[_property] = html_encode_entities_object(_object[_property]);
        }
      }
    }

    return _object;
  }

  function html_decode_entities_object(_object) {

    for (var _property in _object) {
      if (_object.hasOwnProperty(_property)) {
        if (typeof _object[_property] === 'string') {
          _object[_property] = _object[_property].replace(/&#\d+;/gm, function(s) {
            console.log(s.match(/\d+/gm)[0]);
            return String.fromCharCode(s.match(/\d+/gm)[0]);
          });
        }
        if (typeof _object[_property] === 'object') {
          _object[_property] = html_decode_entities_object(_object[_property]);
        }
      }
    }

    return _object;
  }

  function debug(QMLFile, Tag, o) {
    console.debug(QMLFile, Tag, o);
  }


}
