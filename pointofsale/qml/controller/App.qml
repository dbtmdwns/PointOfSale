
import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {


  property alias local: myLocal
  property alias remote: myRemote


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
  property int dbsize: 1024*1024* 20 // 20MB
  property string sessionID: ""
  property string async: "0"


  property string receipt: ""
  property string department: ""
  property string reference_number: ""
  property string items_group: ""
  property string fullscreen: ""
  property string posTitle: ""

  property int leftMatrixWidth: 100
  property int rightMatrixWidth: 100
  property int scale: 2
  property int fontSize: (density/scale) * configFontSize
  property int buttonFontSize: (density/scale) * configButtonFontSize
  property int configFontSize: 32
  property int configButtonFontSize: 32

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

  property string paperWidth: "80"
  property string paperHeight: "500"
  property string printerResolution: "180"

  property string template_file: ""
  property string template: ""
  property string logo_file: ""
  property string left_logo_file: ""
  property string fixview: ""


  property string kasse: "Göppingen"
  property string zahlart: "Bar"
  property string lager: "0"
  property string tabellenzusatz: "BARVERKAUF"


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

    use_date = new Date();
    db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", dbsize);

    myRemote.url = "https://tualoserver.de/wawi/index.php"
    myRemote.client = "admin"
    myRemote.username = "admin"
    myRemote.password = "admin"

    db.transaction(
      function(tx) {
        // Create the database if it doesn't already exist
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key varchar(255) primary key, value TEXT)');
        var rs = tx.executeSql('SELECT key,value FROM settings');
        for (var i = 0; i < rs.rows.length; i++) {
          switch (rs.rows.item(i).key) {
            case "url":
              myRemote.url = rs.rows.item(i).value;
            break;
            case "async":
              async = rs.rows.item(i).value;
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


            case "paperWidth":
              paperWidth = rs.rows.item(i).value;
              break;
            case "paperHeight":
              paperHeight = rs.rows.item(i).value;
              break;
            case "printerResolution":
              printerResolution = rs.rows.item(i).value;
              break;

          }
        }

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
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['paperWidth', paperWidth]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['paperHeight', paperHeight]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['printerResolution', printerResolution]);

        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['url', myRemote.url]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['username', myRemote.username]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['password', myRemote.password]);
        tx.executeSql('INSERT OR IGNORE INTO settings (key,value) VALUES (?, ?)', ['client', myRemote.client]);


        tx.executeSql('UPDATE settings set value = ? where key = ?', [async, 'async']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [paperWidth, 'paperWidth']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [paperHeight, 'paperHeight']);
        tx.executeSql('UPDATE settings set value = ? where key = ?', [printerResolution, 'printerResolution']);

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

    if (async=='1'){
      myLocal.save(json,cb);
    }else{
      myRemote.save(json,cb);
    }

  }

  function login(cb) {
    var cbx = function(){
      config(function() {
        relations(cb);
      }.bind(this));
    }.bind(this)

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
      Local.config(function(res){
        async = (res.async)?async:'0';
        kasse = res.kasse;
        lager = res.lager;
        zahlart = res.zahlart;
        tabellenzusatz = res.tabellenzusatz;
        cb();
      });
    }else{
      myRemote.config(function(res){

        if (template_file === "") {
          template = res.template
        }
        if (left_logo_file === "") {
          left_logo_file = res.left_logo
        }

        async = (res.async)?async:'0';
        kasse = res.kasse;
        lager = res.lager;
        zahlart = res.zahlart;
        tabellenzusatz = res.tabellenzusatz;
        cb();
      });
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
