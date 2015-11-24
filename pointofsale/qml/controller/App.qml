
import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {

  property string version: "1.0.0"
  property string versionBuild: "007"
  property string message: ""
  property var configs: []
  property alias local: myLocal
  property alias remote: myRemote
  property alias logger: myLogger

  Logger{
    id: myLogger

  }

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

  property alias matrix : layoutProperties
  Item {
    id: layoutProperties

    property int raiX: 9
    property int raiY: 0
    property int raiWidth: 3
    property int raiHeight: 12

    property int waregroupX: 0
    property int waregroupY: 0
    property int waregroupWidth: 1
    property int waregroupHeight: 11

    property int articleX: 1
    property int articleY: 0
    property int articleWidth: 8
    property int articleHeight: 11

    property int relationX: 0
    property int relationY: 11
    property int relationWidth: 8
    property int relationHeight: 1

    property int payX: 0
    property int payY: 0
    property int payWidth: 8
    property int payHeight: 11

    property int pluginX: 0
    property int pluginY: 0
    property int pluginWidth: 8
    property int pluginHeight: 11
  }


  property double reportViewScale: 0.5
  property double reportPrintScale: 0.2
  property string basicFontColor: "#ccccff"
  property string basicStyleColor: "#212121"
  property int dpi: 72
  property double density: 1
  property int dbsize: 1024*1024* 50 // 50MB
  property string sessionID: ""
  property string async: "0"

  property bool usePOSPrinter: true
  property bool autoAddArticles: true
  property bool showLastTotal: true

  property string receipt: ""
  property string department: ""
  property string reference_number: ""
  property string items_group: ""
  property string fullscreen: ""
  property string posTitle: "tualo POS"

  property int leftMatrixWidth: 100
  property int rightMatrixWidth: 100
  property int scale: 2
  property int fontSize: configFontSize //(dpi/109) * configFontSize
  property int buttonFontSize: configButtonFontSize //(dpi/109) * configButtonFontSize
  property int configFontSize: 14
  property int configButtonFontSize: 14

  property int totalDisplayRows: 1

  property int windowWidth: 800;

  property int leftSideColumns: 3
  property int rightSideColumns: 3

  property int waregroupColumns: 1
  property int waregroupColCount: 1
  property int waregroupRowCount: 8
  property int waregroupRows: 10

  property int relationRowCount: 1
  property int relationColCount: 6
  property int relationColumns: waregroupColumns + articleColumns
  property int relationRows: 1

  property int articleColCount: 2
  property int articleRowCount: 8
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
  property var customCMDList: [];

  property alias posPrinter: posPrinter

  PosPrinter {
    id: posPrinter
  }

  function ratio(nDPI){
    if(typeof nDPI=='undefined'){
      nDPI = Screen.pixelDensity  * 24.5;
    }
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
    application.logger.debug("started "+(new Date()).toISOString());

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

    use_date = new Date();
    db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", dbsize);

    myRemote.url = "https://tualoserver.de/ts/index.php"
    myRemote.client = "admin"
    myRemote.username = "admin"
    myRemote.password = "admin"


    myReportStore.customFunctions={};

/*
    myReportStore.customFunctions['Pfandrueckgabe'] = [
      ['FILTERWG','Pfand'],
      ['NEGAMOUNT','-']
    ];
*/
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

        myLocal.config(function(result){
          processConfig(result);

        });
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
    if (async!='0'){
      myLocal.save(json,cb);
    }else{
      myRemote.save(json,cb);
    }

  }

  function login(cb) {
    var cbx = function(){
      config(function() {
        relations(cb);
      });
    };
    if (async!='0'){
      cbx();
    }else{
      myRemote.login(cbx);
    }
  }

  function logout(cb) {
    myRemote.logout(cb);
  }

  function articles(cb) {
    if (async!='0'){
      myLocal.articles(cb);
    }else{
      myRemote.articles(cb);
    }
  }

  function relations(cb) {
    processRelations(relationList,cb);

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
      application.logger.error((new Date()).toISOString()+" - "+e.toString()+"\n"+JSON.stringify(res.data,null,0));
    }
    var wgs = []
    for (var w in _hash) {
      wgs.push(_hash[w]);
    }
    relationList = wgs;


    cb();
  }


  function config(cb){
    if (async!='0'){
      myLocal.config(function(res){
        processConfig(res);
        cb();
      });
    }else{
      myRemote.config(function(res){
        processConfig(res);
        cb();
        saveSettings();
      });
    }
  }

  function setConfigs(index){

    if (typeof configs[index]=='object'){
      var res = configs[index];
      async = res.async||'0';
      myLocal.maxReportNumber = res.maxReportNumber;
      myLocal.minReportNumber = res.minReportNumber;
      kasse = res.kasse;
      relationList = res.relations;

      application.logger.debug((new Date()).toISOString()+" - "+'res.relations '+JSON.stringify(res.relations,null,2));
      lager = res.lager;
      zahlart = res.zahlart;
      tabellenzusatz = res.tabellenzusatz;
      if (typeof res.posTitle==='string'){
        posTitle = res.posTitle;
      }else{
        posTitle = res.name;
      }

      if (typeof res.template==='string'){
        template = res.template.replace(/#qoute;/gm,"'");
      }

      if ( (typeof res.left_logo_file === "string") && (res.left_logo_file !== "")) {
        left_logo_file = res.left_logo
      }
      return true;
    }else{
      return false;
    }

  }

  function processConfig(result){

    var model = overview.model;

    model.clear();
    configs=[];
    if (result && result.cnf){
      if (result.fontsize){
        configFontSize = result.fontsize*1;
        configButtonFontSize = result.fontsize*1;
      }
      if (result.waregroupColCount){
        waregroupColCount = result.waregroupColCount*1;
      }
      if (result.articleColCount){
        articleColCount = result.articleColCount*1;
      }
      if (result.waregroupColumns){
        waregroupColumns = result.waregroupColumns*1;
      }
      if (result.articleColumns){
        articleColumns = result.articleColumns*1;
      }


      if (result.reportViewScale){
        reportViewScale = result.reportViewScale*1;
      }

      if (result.basicFontColor){
        basicFontColor = result.basicFontColor;
      }
      if (result.basicStyleColor){
        basicStyleColor = result.basicStyleColor;
      }

      if (result.usePOSPrinter){
        usePOSPrinter = result.usePOSPrinter==='1';
      }
      if (result.autoAddArticles){
        autoAddArticles = result.autoAddArticles==='1';
      }
      if (result.showLastTotal){
        showLastTotal = result.showLastTotal==='1';
      }

      if (result.customCMDList){
        try{
          customCMDList = JSON.parse(result.customCMDList);
        }catch(e){
          console.log(e);
        }
      }

      if (result.layout){

        if (result.layout.raiX){
          layoutProperties.raiX = result.layout.raiX*1;
        }else{
          layoutProperties.raiX = 9;
        }
        if (result.layout.raiY){
          layoutProperties.raiY = result.layout.raiY*1;
        }else{
          layoutProperties.raiY = 0;
        }
        if (result.layout.raiWidth){
          layoutProperties.raiWidth = result.layout.raiWidth*1;
        }else{
          layoutProperties.raiWidth = 3;
        }
        if (result.layout.raiHeight){
          layoutProperties.raiHeight = result.layout.raiHeight*1;
        }else{
          layoutProperties.raiHeight = 12;
        }


        if (result.layout.waregroupX){
          layoutProperties.waregroupX = result.layout.waregroupX*1;
        }else{
          layoutProperties.waregroupX = 0;
        }
        if (result.layout.waregroupY){
          layoutProperties.waregroupY = result.layout.waregroupY*1;
        }else{
          layoutProperties.waregroupY = 0;
        }
        if (result.layout.waregroupWidth){
          layoutProperties.waregroupWidth = result.layout.waregroupWidth*1;
        }else{
          layoutProperties.waregroupWidth = 2;
        }
        if (result.layout.waregroupHeight){
          layoutProperties.waregroupHeight = result.layout.waregroupHeight*1;
        }else{
          layoutProperties.waregroupHeight = 11;
        }


        if (result.layout.articleX){
          layoutProperties.articleX = result.layout.articleX*1;
        }else{
          layoutProperties.articleX = 2;
        }
        if (result.layout.articleY){
          layoutProperties.articleY = result.layout.articleY*1;
        }else{
          layoutProperties.articleY = 0;
        }
        if (result.layout.articleWidth){
          layoutProperties.articleWidth = result.layout.articleWidth*1;
        }else{
          layoutProperties.articleWidth = 2;
        }
        if (result.layout.articleHeight){
          layoutProperties.articleHeight = result.layout.articleHeight*1;
        }else{
          layoutProperties.articleHeight = 11;
        }


        if (result.layout.relationX){
          layoutProperties.relationX = result.layout.relationX*1;
        }else{
          layoutProperties.relationX = 0;
        }
        if (result.layout.relationY){
          layoutProperties.relationY = result.layout.relationY*1;
        }else{
          layoutProperties.relationY = 11;
        }
        if (result.layout.relationWidth){
          layoutProperties.relationWidth = result.layout.relationWidth*1;
        }else{
          layoutProperties.relationWidth = 8;
        }
        if (result.layout.relationHeight){
          layoutProperties.relationHeight = result.layout.relationHeight*1;
        }else{
          layoutProperties.relationHeight = 1;
        }


        if (result.layout.payX){
          layoutProperties.payX = result.layout.payX*1;
        }else{
          layoutProperties.payX = 0;
        }
        if (result.layout.payY){
          layoutProperties.payY = result.layout.payY*1;
        }else{
          layoutProperties.payY = 0;
        }
        if (result.layout.payWidth){
          layoutProperties.payWidth = result.layout.payWidth*1;
        }else{
          layoutProperties.payWidth = 8;
        }
        if (result.layout.payHeight){
          layoutProperties.payHeight = result.layout.payHeight*1;
        }else{
          layoutProperties.payHeight = 11;
        }


        if (result.layout.pluginX){
          layoutProperties.pluginX = result.layout.pluginX*1;
        }else{
          layoutProperties.pluginX = 0;
        }
        if (result.layout.pluginY){
          layoutProperties.pluginY = result.layout.pluginY*1;
        }else{
          layoutProperties.pluginY = 0;
        }
        if (result.layout.pluginWidth){
          layoutProperties.pluginWidth = result.layout.pluginWidth*1;
        }else{
          layoutProperties.pluginWidth = 8;
        }
        if (result.layout.pluginHeight){
          layoutProperties.pluginHeight = result.layout.pluginHeight*1;
        }else{
          layoutProperties.pluginHeight = 11;
        }


      }
      var kassenHash = {};
      for(var i=0;i<result.cnf.length;i++){
        var item = {};
        var res = result.cnf[i];

        item.async = res.async||'0';
        item.maxReportNumber = res.maxReportNumber;
        item.minReportNumber = res.minReportNumber;
        item.kasse = res.kasse;
        kassenHash[item.kasse] = i;
        item.lager = res.lager;
        item.zahlart = res.zahlart;
        item.relations = res.relations;
        item.tabellenzusatz = res.tabellenzusatz;
        if (typeof res.posTitle==='string'){
          item.posTitle = res.posTitle;
        }
        if (typeof res.template==='string'){
          item.template = res.template.replace(/#qoute;/gm,"'");
        }
        if (left_logo_file === "") {
          item.left_logo_file = res.left_logo
        }
        item.name = res.name;

        model.append({
          iconText: "\uf073",
          title: res.name,
          doneText: "",
          page: "MatrixInput.qml",
          configIndex: i
        });

        configs.push(item);
      }
    }


    for(i in kassenHash){
      if (kassenHash.hasOwnProperty(i)){
        if (i!=""){
          model.append({
            iconText: "\uf00c",
            title:  "Abschluss "+i,
            doneText: "",
            page: "CloseCashBox.qml",
            configIndex: kassenHash[i]
          });
        }
      }
    }



    model.append({
      iconText: "\uf0f6",
      title: "About",
      doneText: "",
      page: "About.qml"
    })

    model.append({
      iconText: "\uf0f6",
      title: "Logging",
      doneText: "",
      page: "Logging.qml"
    })

    model.append({
      iconText: "\uf085",
      title:  "Settings",
      doneText: "\uf00c Fertig",
      page: "Settings.qml"
    })

    model.append({
      iconText: "\uf08b",
      title: "Exit",
      doneText: "",
      page: "Exit.qml"
    })


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
          _object[_property] = _object[_property].replace(/&#quote;/gm,"'").replace(/&#\d+;/gm, function(s) {
            return String.fromCharCode(s.match(/\d+/gm)[0]);
          });
        }else if (typeof _object[_property] === 'object') {
          _object[_property] = html_decode_entities_object(_object[_property]);
        }else{
          _object[_property] = _object[_property];
        }
      }
    }

    return _object;
  }

  function debug(QMLFile, Tag, o) {
    console.debug(QMLFile, Tag, o);
  }


}
