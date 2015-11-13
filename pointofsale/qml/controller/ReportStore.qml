import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import QtQuick.LocalStorage 2.0
import "../styles"
import "../controlls"

Item {

  property double given: 0
  property string _givenfraction: ""
  property double total: 0
  property double total_tax: 0
  property double total_without_tax: 0
  property double number: -1
  property var positions: []
  property var printCommands: []

  property var styles
  property var refItem
  property var reportListView
  property bool reportMode: false
  property string currentMode: 'amount'
  property bool amountModeInit: true
  property bool fractionMode: false
  property bool priceModeInit: true
  property bool givenModeInit: true
  property bool givenPModeInit: true


  property string steuerschluessel: "innen"
  property int preiskategorie: 1
  property string relation: "Normal - innen"
  property int kundennummer: 1
  property int kostenstelle: 1
  property string feld: ""

  property string referenzString: ""


  property var _steuergruppen: []
  property string _warengruppe: ""
  property var _warengruppen: []
  property var _staffeln: []
  property var _artikel: []
  property var _kombiartikel: []

  property double lastTotal: 0
  property string datum;
  property string zeit;
  property string findString;
  property string ticketHeader;
  property string ticketItem;
  property string ticketFooter;
  property string ticketTaxesPositions;
  property string ticketTaxesHeader;
  property string ticketTaxesFooter;

  property var oldReportsUpdate: null
  property var oldReports: []
  property ReportView reportView: null
  property var onAddedReport: null
  property var onFind: null

  property var modeReferences: null




  Timer {
    id: clearFindString
    interval: 3000
    running: false
    repeat: false
    onTriggered: {
      currentMode = 'amount';
      clearFindString.stop();
      findArticle(findString,function(l){
        if (l.length==1){
          add(l[0]);
        }
        findString = "";
      });

    }
  }


  function loadArticles(cb) {
    application.articles(function(res) {
      _steuergruppen = res.steuergruppen;
      for (var i in res.warengruppen) {
        res.warengruppen[i].f = res.warengruppen[i].farbe;
        res.warengruppen[i].farbe = application.rgb_hex_Color(res.warengruppen[i].farbe);
        res.warengruppen[i].displayBackgroundColor = res.warengruppen[i].farbe;
      }

      _warengruppen = res.warengruppen;
      _staffeln = res.staffeln;
      _artikel = res.artikel;
      _kombiartikel = application.html_decode_entities_object(res.kombiartikel);

      cb();
    });
  }

  function comp(a,b){
      if (a.reportnumber > b.reportnumber){
          return 1;
      }else if (a.reportnumber < b.reportnumber){
          return -1;
      }else{
          return 0;
      }
  }
  function getOldReport(number){
    oldReports.sort(comp);
    if (number===-1){
      return oldReports[oldReports.length-1];
    }else{
      for(var i=0,m=oldReports.length;i<m;i++){
        if (oldReports[i].reportnumber===number){
            return oldReports[i];
        }
      }
    }
  }

  function pushOldReport(item) {
    oldReports.push(item);
    if (typeof onAddedReport === 'function') {
      onAddedReport(item);
    }
  }

  function getWarengrupen() {

    return _warengruppen;
  }

  function findArticle(find,cb){
    var res = [];

    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var sql = 'SELECT * FROM searchablearticles
        where key=\''+application.remote.client+'\'
        and (
          lower(article) like \'%'+find.toLowerCase()+'%\' or
          lower(articlenumber) like \'%'+find.toLowerCase()+'%\'
        )
        ';
        var rs = tx.executeSql(sql);
        for (var i = 0; i < rs.rows.length; i++) {
          var item = {};
          var staffeln = application.remote.unEscapeResult(rs.rows.item(i).staffeln);
          var artikel = application.remote.unEscapeResult(rs.rows.item(i).value);

          if (preiskategorie * 1 === staffeln.preiskategorie * 1) {
            item.gruppe = staffeln.gruppe;
            item.plugin = artikel.plugin;
            item.anzahl = 1;
            item.steuersatz = 1 * artikel["steuer" + feld];
            item.bpreis = staffeln.brutto;
            item.preis = staffeln.brutto / (1 + item.steuersatz / 100);
            item.netto = item.preis;
            item.brutto_preis = staffeln.brutto * 1;
            item.brutto = staffeln.brutto * 1;
            item.zusatztext = artikel.zusatztext;
            res.push(item);

          }

        }
        cb(res);
      }
    );

  }


  function singleArticle(name,cb){

    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var sql = 'SELECT * FROM searchablearticles
        where key=\''+application.remote.client+'\'
        and lower(article) like \''+name.toLowerCase()+'%\'
        ';
        var rs = tx.executeSql(sql);
        for (var i = 0; i < 1; i++) {
          var item = {};
          var staffeln = application.remote.unEscapeResult(rs.rows.item(i).staffeln);
          var artikel = application.remote.unEscapeResult(rs.rows.item(i).value);

          if (preiskategorie * 1 === staffeln.preiskategorie * 1) {
            item.gruppe = staffeln.gruppe;
            item.plugin = artikel.plugin;
            item.anzahl = 1;
            item.steuersatz = 1 * artikel["steuer" + feld];
            item.bpreis = staffeln.brutto;
            item.preis = staffeln.brutto / (1 + item.steuersatz / 100);
            item.netto = item.preis;
            item.brutto_preis = staffeln.brutto * 1;
            item.brutto = staffeln.brutto * 1;
            item.zusatztext = artikel.zusatztext;
            //res.push(item);
            cb(item);
          }

        }

      }
    );
    /*
    for (var i in _artikel) {
      if (
        (_artikel[i].gruppe.toLowerCase().indexOf(name.toLowerCase())>=0)
      ){
        for (var s in _staffeln) {
          if (_staffeln[s].gruppe === _artikel[i].gruppe) {
            if (preiskategorie * 1 === _staffeln[s].preiskategorie * 1) {
              var item = {};
              item.gruppe = _staffeln[s].gruppe;
              item.plugin = _artikel[i].plugin;
              item.anzahl = 1;
              item.steuersatz = 1 * _artikel[i]["steuer" + feld];
              item.bpreis = _staffeln[s].brutto;
              item.preis = _staffeln[s].brutto / (1 + item.steuersatz / 100);
              item.netto = item.preis;
              item.brutto_preis = _staffeln[s].brutto * 1;
              item.brutto = _staffeln[s].brutto * 1;
              item.zusatztext = _artikel[i].zusatztext;
              return item;
            }
          }
        }
      }
    }
    return res;
    */
  }

  function getArtikel(warengruppe,cb) {
    _warengruppe = warengruppe;
    var res = [];

    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var sql = 'SELECT * FROM searchablearticles where key=\''+application.remote.client+'\' and waregroup=\''+_warengruppe.replace(/'/gm,"#qoute;")+'\'';
        var rs = tx.executeSql(sql);
        //console.log(sql,JSON.stringify(rs,null,2),rs.rows.length);
        for (var i = 0; i < rs.rows.length; i++) {
          var item = {};
          var staffeln = application.remote.unEscapeResult(rs.rows.item(i).staffeln);
          var artikel = application.remote.unEscapeResult(rs.rows.item(i).value);

          if (preiskategorie * 1 === staffeln.preiskategorie * 1) {
            item.gruppe = staffeln.gruppe;
            item.plugin = artikel.plugin;
            item.anzahl = 1;
            item.steuersatz = 1 * artikel["steuer" + feld];
            item.bpreis = staffeln.brutto;
            item.preis = staffeln.brutto / (1 + item.steuersatz / 100);
            item.netto = item.preis;
            item.brutto_preis = staffeln.brutto * 1;
            item.brutto = staffeln.brutto * 1;
            item.zusatztext = artikel.zusatztext;
            res.push(item);
          }

        }
        cb(res);
      }
    )


  }

  function cmd(cmdtype, val, input) {

    if (typeof input==='undefined'){
      input='numpad';
    }


    if (modeReferences!=null){
      if (typeof modeReferences[currentMode]==='function'){
        modeReferences[currentMode](cmdtype, val, input);
      }
    }

    if (cmdtype === 'ESC') {
      findString = ""
      if (currentMode === 'pay') {
        currentMode = 'amount';
      }
    }

    if (cmdtype === 'PLUSMINUS') {
      if (number === -1) {
        if (currentMode === 'amount') {
          positions[positions.length - 1].anzahl *= -1;
          calcPos(positions.length - 1);
        }
      }
    }


    if (cmdtype === 'SEP') {
      if (number === -1) {
        if (currentMode === 'amount') {

        } else if (currentMode === 'price') {
          if (priceModeInit) {
            positions[positions.length - 1].brutto_preis = 0;
            priceModeInit = false;
          } else {


          }
          positions[positions.length - 1]._fraction = "";
          fractionMode = true;
        } else if (currentMode === 'pay') {
          if (givenModeInit) {
            given = 0;
            givenModeInit = false;
          } else {


          }
          _givenfraction = "";
          givenPModeInit = true;
          fractionMode = true;
        }
      }
    }

    if (cmdtype === 'PAYFIT') {
      if (currentMode === 'pay') {
        given = total
        givenModeInit = true;
        givenPModeInit = true;
      }
    }

    if (cmdtype === 'CANCLEPAY') {
      currentMode = 'amount';
      amountModeInit = true;
    }

    if (cmdtype === 'ADDPAY') {
      if (givenPModeInit) {
        given = val;
        givenPModeInit = false;
      } else {
        given += val;
      }

      givenModeInit = true;
    }



    if (cmdtype === 'NUM') {

      if (number === -1) {





        if ( ((currentMode === 'amount') || (currentMode === 'find')) && (input === 'keyboard') ) {
          findString += val + "";
          clearFindString.stop();
          clearFindString.start();
          if (typeof onFind === 'function') {
            onFind(findString);
          }
        }


        if (positions.length === 0) {
          return;
        }

        if ( (currentMode === 'amount') && (input === 'numpad') ) {
          val *=1;
          var ix_init = false;
          if (amountModeInit) {
            positions[positions.length - 1].anzahl = val;
            ix_init = true;
            amountModeInit = false;
          } else {
            positions[positions.length - 1].anzahl *= 10;
            positions[positions.length - 1].anzahl += val;
          }
          calcPos(positions.length - 1);
          if (positions[positions.length - 1].kombiartikel===true){
            var ix = positions.length - 2;
            while(positions[ix].kombiartikel===true){
              if (ix_init) {
                positions[ix].anzahl = val;
              } else {
                positions[ix].anzahl *= 10;
                positions[ix].anzahl += val;
              }
              calcPos(ix);
              ix--;
            }

            if (ix_init) {
              positions[ix].anzahl = val;
            } else {
              positions[ix].anzahl *= 10;
              positions[ix].anzahl += val;
            }
            calcPos(ix);

          }
        } else if (currentMode === 'price') {

          var chPos = positions.length - 1;
          console.log(JSON.stringify(positions,null,1));
          while((positions[chPos].kombiartikel===true)){
            chPos--;
            if (chPos==-1){
              return;
            }
          }
          console.log(chPos);
          /*
          if (positions[chPos].kombiartikel===true){
            application.displayMessage("Preisänderung ist bei Kombiartikeln nicht erlaubt");
            return;

          }
          */


          val *=1;
          if (priceModeInit) {
            positions[chPos].brutto_preis = val;
            priceModeInit = false;
          } else {
            if (typeof positions[chPos]._fraction === 'undefined') {
              positions[chPos]._fraction = "";
            }

            if (fractionMode) {
              positions[chPos]._fraction += val + "";
              var f = Math.floor(positions[chPos].brutto_preis);
              positions[chPos].brutto_preis = (f + "." + positions[chPos]._fraction) * 1;
            } else {
              positions[chPos].brutto_preis *= 10;
              positions[chPos].brutto_preis += val;
            }
          }
          calcPos(chPos);
        } else if (currentMode === 'pay') {

          givenPModeInit = true;

          if (givenModeInit) {
            given = val;
            givenModeInit = false;
          } else {


            if (fractionMode) {
              _givenfraction += val + "";
              var gf = Math.floor(given);
              given = (gf + "." + _givenfraction) * 1;
            } else {
              given *= 10;
              given += val;
            }
          }
        }

      }

    }

    if (cmdtype === 'AMOUNTPRICESWITCH') {
      if (currentMode === 'amount') {
        currentMode = 'price';
        priceModeInit = true;
        fractionMode = false;
      } else if (currentMode === 'price') {
        currentMode = 'amount';
        amountModeInit = true;
        fractionMode = false;
      } else if (currentMode === 'pay') {
        //currentMode = 'amount';
      }
    }


    if (cmdtype === 'CANCLE') {
      if (number === -1) {
        positions = [];
      } else {
        number = -1;
        for (var i in positions) {
          positions[i].anzahl *= -1;
          calcPos(i);
        }
      }

    }
    if (cmdtype === 'SUM') {
      sum();
    }

    if (cmdtype === 'CANCLE LAST') {

      if (number === -1) {

        while ((positions.length>0) && (positions[positions.length - 1].kombiartikel===true)){
          positions.pop();
        }
        positions.pop();
      }
    }

    if (cmdtype === 'SET RELATION') {
      if (typeof val==='object'){
        console.log('val.steuerschluessel',val.steuerschluessel,JSON.stringify(_steuergruppen,null,2));
        if (_steuergruppen[val.steuerschluessel]){
          feld = _steuergruppen[val.steuerschluessel].feld;
        }else{
          feld = '';
        }
        relation = val.name;
        kundennummer = val.kundennummer;
        kostenstelle = val.kostenstelle;
        preiskategorie = val.preiskategorie;

        for (var i in positions) {
          calcPos(i);
        }
      }
    }

    if (cmdtype === 'CUT') {
      // open drawer

      application.posPrinter.cut(application.printerName);

    }


    if (cmdtype === 'OPEN') {
      // open drawer
      application.posPrinter.open(application.printerName)
    }

    if (cmdtype === 'PRINT') {
      //application.posPrinter.allPrinters();
      //application.posPrinter.setup( application.printerResolution*1, application.paperWidth*1, application.paperHeight*1)

      if (application.usePOSPrinter===true){
        application.posPrinter.open(application.printerName);
      }

      if (oldReports.length>0){
        printReport( getOldReport(number) ) // printimage
      }


      return;
    }



    if (cmdtype === 'REPORTMODE') {
      if (reportMode) {
        reportMode = false;
      } else {
        reportMode = true;
      }
    }

    if (cmdtype === 'OPENREPORT') {

      for (var i = 0; i < oldReports.length; i++) {

        if (val == oldReports[i].reportnumber) {
          positions = oldReports[i].positions;
          number = oldReports[i].reportnumber;
          datum = oldReports[i].date;
          zeit = oldReports[i].time;
          kundennummer = oldReports[i].customerno;
          kostenstelle = oldReports[i].costcenter;
          total = oldReports[i].total;
        }
      }
    }



    if (cmdtype === 'ENTER') {

      if (currentMode === 'find') {
        currentMode = 'amount';
        clearFindString.stop();
        var l = findArticle(findString);
        if (l.length==1){
          add(l[0]);
        }
        findString = "";
        return;
      }



      if (total !== 0) {
        if (number === -1) {

          if (currentMode === 'pay') {
            if (given >= total) {
              application.displayMessage("Der Beleg wird gespeichert.", true);
              currentMode = 'paysave';
              if (application.usePOSPrinter===true){
                application.posPrinter.open(application.printerName);
              }

              application.saveReport(kundennummer, kostenstelle, positions, given, function(err, res) {

                console.log('saveReport',JSON.stringify(err,null,1));
                console.log('saveReport',JSON.stringify(res,null,1));
                if (err) {
                  application.displayMessage(err.response);
                  console.log('saveReport error',err.response);

                } else {

                  if (res.success) {
                    /*
                    for(var pn = printCommands.length-1;pn>=0;pn--){
                      ;
                    }
                    */
                    while(printCommands.length>0){
                      var pfn = printCommands.pop();
                      pfn(positions,function(){ });
                    }
                    //return;

                    number = res.belegnummer;
                    zeit = (new Date()).toISOString().substring(11, 16);
                    datum = (new Date()).toISOString().substring(0, 10);
                    var item = {
                      time: zeit,
                      customerno: kundennummer,
                      costcenter: kostenstelle,
                      date: datum,
                      reportnumber: number,
                      total: total,
                      positions: positions,
                      displayBackgroundColor: "#41414f"
                    }
                    try {
                      pushOldReport(application.html_decode_entities_object(item));
                    } catch (e) {
                      console.log(e);
                    }
                    positions = [];
                    application.displayMessage(number + " gespeichert.");
                    number = -1;
                    lastTotal = total;
                    currentMode = 'amount';
                  } else {
                    application.displayMessage(res.msg);
                  }
                  currentMode = 'amount';
                  sum();
                }

              });
            }
          } else if (currentMode == 'price'){

            currentMode = 'amount';
            amountModeInit = true;

          } else {

            _givenfraction = "";
            given = total;

            givenModeInit = true;
            givenPModeInit = true;

            currentMode = 'pay';
          }
        } else {
          positions = [];
          number = -1;
        }
      }

    }
    sum();
  }

  function add(item, noPlugin) {
    findString = "";


    if (typeof  _kombiartikel[item.gruppe.replace(/'/gm,"#qoute;")] !== 'undefined'){
      if (number === -1) {
        lastTotal = 0;
        var brutto_preis = item.brutto_preis;
        var brutto = Math.round((item.anzahl * brutto_preis) * 100) / 100;
        var netto = brutto / (1 + item.steuersatz / 100);
        var xitem = {
          artikel: item.gruppe,
          zusatztext: (typeof item.zusatztext === 'string') ? item.zusatztext : '',
          referenz: (typeof item.referenz === 'string') ? item.referenz : '',
          steuersatz: item.steuersatz,
          anzahl: item.anzahl,
          xref: item.xref,
          epreis: item.preis,
          brutto_preis: brutto_preis,
          brutto: brutto,
          netto: netto
        }
        var kombi_liste = _kombiartikel[xitem.artikel.replace(/'/gm,"#qoute;")];
        positions.push(xitem);
        for(var ki=0;ki<kombi_liste.length;ki++){
          singleArticle(kombi_liste[ki].resultartikel.replace(/#qoute;/gm,"'"),function(nitem){
            console.log(JSON.stringify(nitem,null,1));
            nitem.artikel = nitem.gruppe;
            nitem.referenz = (typeof nitem.referenz === 'string') ? nitem.referenz : '';
            nitem.anzahl =  nitem.anzahl * kombi_liste[ki].resultfaktor;
            nitem.epreis =  nitem.preis * kombi_liste[ki].resultpfaktor;
            nitem.brutto_preis =  nitem.brutto_preis * kombi_liste[ki].resultpfaktor;
            nitem.brutto =  nitem.brutto * kombi_liste[ki].resultpfaktor;
            nitem.netto =  nitem.netto * kombi_liste[ki].resultpfaktor;
            nitem.kombiartikel = true;
            positions.push(nitem);
            sum();
          });
        }
        currentMode = 'amount';
        amountModeInit = true;
        sum();
      }
    }else if (
      (
        (item.plugin === 'Ext.plugin.Referenz') ||
        (item.plugin === 'reportplugin.referenz')
      ) && (noPlugin !== true)
    ) {

      currentMode = 'Referenz';
      referenzString = '';
      refItem = item;
      refItem.referenz = '';
      refItem.anzahl = 1;

    }else if (
      (
        (item.plugin === 'Ext.plugin.Gutschein') ||
        (item.plugin === 'reportplugin.gutschein')
      ) && (noPlugin !== true)
    ) {

      currentMode = 'GutscheinEinloesen';
      referenzString = '';
      refItem = item;
      refItem.referenz = '';
      refItem.anzahl = 1;

    }else if (
      (
        (item.plugin === 'Ext.plugin.Gutscheinausgabe') ||
        (item.plugin === 'reportplugin.gutscheinausgabe')
      ) && (noPlugin !== true)
    ) {

      currentMode = 'GutscheinAusgeben';
      referenzString = '';
      refItem = item;
      refItem.referenz = '';
      refItem.anzahl = 1;

    } else {
      if (number === -1) {
        lastTotal = 0;
        var brutto_preis = item.brutto_preis;
        var brutto = Math.round((item.anzahl * brutto_preis) * 100) / 100;
        var netto = brutto / (1 + item.steuersatz / 100);
        var yitem = {
          artikel: item.gruppe,
          zusatztext: (typeof item.zusatztext === 'string') ? item.zusatztext : '',
          referenz: (typeof item.referenz !== 'undefined') ? item.referenz : '',
          referenzphp: (typeof item.referenzphp !== 'undefined') ? item.referenzphp : '',
          steuersatz: item.steuersatz,
          anzahl: item.anzahl,
          xref: item.xref,
          epreis: item.preis,
          brutto_preis: brutto_preis,
          brutto: brutto,
          netto: netto
        }
        positions.push(yitem);
        currentMode = 'amount';
        amountModeInit = true;
        sum();
      }
    }
    return positions.length - 1;
  }

  function calcPos(index) {
    if (typeof index==='undefined'){
      index = positions.length-1;
    }
    if (number === -1) {
      var brutto_preis = positions[index].brutto_preis; // Math.round( positions[index].epreis*(1+positions[index].steuersatz/100) * 100) /100;

      var brutto = Math.round((positions[index].anzahl * brutto_preis) * 100) / 100;
      console.log(positions[index].artikel);
      positions[index].steuersatz = _artikel[positions[index].artikel.replace(/'/gm,"#qoute;")]['steuer' + feld] * 1;
      var netto = brutto / (1 + positions[index].steuersatz / 100);

      positions[index].brutto_preis = brutto_preis;
      positions[index].brutto = brutto;
      positions[index].netto = netto;
      positions[index].steuer = brutto - netto;
      positions[index].epreis = brutto_preis / (1 + positions[index].steuersatz / 100);
    }
  }



  function sum(print) {
    total = 0;
    total_without_tax = 0;
    for (var i = 0; i < positions.length; i++) {
      total += positions[i].brutto;
      total_without_tax += positions[i].netto;
    }
    var item = {
      time: zeit,
      customerno: kundennummer,
      costcenter: kostenstelle,
      date: datum,
      reportnumber: number,
      total: total,
      positions: positions
    }
    if ((typeof reportView!=='undefined')&&(reportView!==null)){
      reportView.refresh( toData(item) , false);
    }
  }

  function toData(item){
    var taxIndexHash = {}
    var stotal_without_tax=0;
    var stotal = 0;
    var positions = item.positions;
      var l1=[ ];
      var l2=[ ];

    var data = {
      time: item.time,
      customerno: item.customerno,
      costcenter: item.costcenter,
      date: item.date,
      reportnumber: item.reportnumber,
      totalNet: 19.00 / 1.07 + 10.00 / 1.19,
      totalNetIncludingTax: 19.00 + 10.00,
      positions: l1,
      taxes: l2
    };
    for (var i = 0; i < positions.length; i++) {
      var xitem = positions[i];
      data.positions.push({
        article: xitem.artikel,
        reference: xitem.referenz,
        amount: xitem.anzahl,
        additionalText: xitem.zusatztext,
        tax: xitem.brutto - xitem.netto,
        taxRate: xitem.steuersatz,
        net: xitem.netto,
        includingTax: xitem.brutto,
        itemPrice: xitem.epreis,
        itemPriceIncludingTax: xitem.epreis*(1+xitem.steuersatz/100)
      })
      if (typeof taxIndexHash['S'+xitem.steuersatz]=='undefined'){
        taxIndexHash['S'+xitem.steuersatz]= data.taxes.length;
        data.taxes.push({
          rate: xitem.steuersatz,
          value: 0
        });
      }
      data.taxes[ taxIndexHash['S'+xitem.steuersatz] ].value += xitem.brutto - xitem.netto;
      stotal += positions[i].brutto;
      stotal_without_tax += positions[i].netto;
    }
    data.totalNet = stotal_without_tax;
    data.totalTax = stotal - stotal_without_tax;
    data.totalNetIncludingTax = stotal;
    return data;
  }

  function printReport(positions) {
    if ((typeof reportView!=='undefined')&&(reportView!==null)){
      reportView.refresh( toData(positions) , true);
    }
  }



}
