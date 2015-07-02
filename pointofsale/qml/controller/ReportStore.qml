import QtQuick 2.0
import "../styles"
import "../controlls"

Item {

  property double given: 0
  property string _givenfraction: ""
  property double total: 0
  property double total_tax: 0
  property double total_without_tax: 0
  property int number: -1
  property var positions: []

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

  property string message: ""
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
  property string lastReport: ""
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

  Timer {
    id: clearFindString
    interval: 3000
    running: false
    repeat: false
    onTriggered: {
      currentMode = 'amount';
      clearFindString.stop();
      var l = findArticle(findString);
      if (l.length==1){
        add(l[0]);
      }
      findString = "";

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
      _kombiartikel = res.kombiartikel;
      cb();
    });
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

  function findArticle(find){
    var res = [];

    for (var i in _artikel) {
      if (
        (_artikel[i].artikelnummer.toLowerCase().indexOf(find.toLowerCase())>=0) ||
        (_artikel[i].gruppe.toLowerCase().indexOf(find.toLowerCase())>=0)
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
              res.push(item);
            }
          }
        }
      }
    }
    return res;
  }


  function singleArticle(name){
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
  }

  function getArtikel(warengruppe) {
    _warengruppe = warengruppe;
    var res = [];

    for (var i in _artikel) {
      if (_artikel[i].warengruppe === warengruppe) {
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
              res.push(item);
            }
          }
        }
      }
    }
    return res;
  }

  function cmd(cmdtype, val, input) {

    if (typeof input==='undefined'){
      input='numpad';
    }

    if (cmdtype === 'PLUSMINUS') {
      if (number === -1) {
        if (currentMode === 'amount') {
          positions[positions.length - 1].anzahl *= -1;
          calcPos(positions.length - 1);
        }
      }
    }

    if (cmdtype === 'BACK') {
      if (currentMode === 'Referenz') {
        if (referenzString.length > 0) {
          referenzString = referenzString.substring(0, referenzString.length - 1);
        }
        return;
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

        if (currentMode === 'Referenz') {
          referenzString += val + ""
          return;
        }



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

          if (positions[positions.length - 1].kombiartikel===true){
            displayMessage("Preisänderung ist bei Kombiartikeln nicht erlaubt");
            return;
          }
          val *=1;
          if (priceModeInit) {
            positions[positions.length - 1].brutto_preis = val;
            priceModeInit = false;
          } else {
            if (typeof positions[positions.length - 1]._fraction === 'undefined') {
              positions[positions.length - 1]._fraction = "";
            }

            if (fractionMode) {
              positions[positions.length - 1]._fraction += val + "";
              var f = Math.floor(positions[positions.length - 1].brutto_preis);
              positions[positions.length - 1].brutto_preis = (f + "." + positions[positions.length - 1]._fraction) * 1;
            } else {
              positions[positions.length - 1].brutto_preis *= 10;
              positions[positions.length - 1].brutto_preis += val;
            }
          }
          calcPos(positions.length - 1);
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

    if (cmdtype === 'CANCLE LAST') {
      if (number === -1) {

        while ((positions.length>0) && (positions[positions.length - 1].kombiartikel===true)){
          positions.pop();
        }
        positions.pop();
      }
    }

    if (cmdtype === 'SET RELATION') {

      feld = _steuergruppen[val.steuerschluessel].feld;
      relation = val.name;
      kundennummer = val.kundennummer;
      kostenstelle = val.kostenstelle;
      preiskategorie = val.preiskategorie;

      for (var i in positions) {
        calcPos(i);
      }
    }

    if (cmdtype === 'CUT') {
      // open drawer

      application.posPrinter.cut() //.print(getHTML());
    }


    if (cmdtype === 'OPEN') {
      // open drawer

      application.posPrinter.openDrawer() //.print(getHTML());
    }

    if (cmdtype === 'PRINT') {
      application.posPrinter.allPrinters();

      application.posPrinter.setup( application.printerResolution*1, application.paperWidth*1, application.paperHeight*1)

      application.posPrinter.print(lastReport);
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
        if (val == oldReports[i].belegnummer) {
          positions = oldReports[i].positions;
          number = oldReports[i].belegnummer;
          datum = oldReports[i].datum;
          zeit = oldReports[i].zeit;
          kundennummer = oldReports[i].kundennummer;
          kostenstelle = oldReports[i].kostenstelle;
          positions = oldReports[i].positionen;
          total = oldReports[i].brutto;
          lastReport = oldReports[i].html;
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

      if (currentMode === 'Referenz') {
        refItem.referenz = referenzString;
        currentMode = 'amount';
        add(refItem, true);
        return;
      }

      if (total !== 0) {
        if (number === -1) {

          if (currentMode === 'pay') {
            if (given >= total) {
              displayMessage("Der Beleg wird gespeichert.", true);
              currentMode = 'paysave';
              application.posPrinter.openDrawer();

              application.saveReport(kundennummer, kostenstelle, positions, given, function(err, res) {

      
                if (err) {
                  displayMessage(err.response,true);
                  console.log('saveReport error',err.response);
                } else {

                  if (res.success) {
                    number = res.belegnummer;
                    zeit = (new Date()).toISOString().substring(11, 16);
                    datum = (new Date()).toISOString().substring(0, 10);
                    //lastReport = getHTML();
                    var item = {
                      zeit: zeit,
                      kundennummer: kundennummer,
                      kostenstelle: kostenstelle,
                      datum: datum,
                      belegnummer: number,
                      brutto: total,
                      positionen: application.html_decode_entities_object(positions),
                      //html: lastReport,
                      displayBackgroundColor: "#41414f",
                      //displayText: ""+number+" "+zeit+" | <b>"+total.toFixed(2)+" €</b>"
                    }
                    try {
                      pushOldReport(item);
                    } catch (e) {
                      console.log(e);
                    }
                    positions = [];
                    number = -1;
                    displayMessage(res.belegnummer + " gespeichert.");
                    lastTotal = total;

                    currentMode = 'amount';
                    //application.posPrinter.openDrawer();

                  } else {
                    displayMessage(res.msg);
                  }
                  sum();
                }

              });
            }
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

    if (typeof  _kombiartikel[item.gruppe] !== 'undefined'){
      if (number === -1) {
        lastTotal = 0;
        var brutto_preis = item.brutto_preis;
        var brutto = Math.round((item.anzahl * brutto_preis) * 100) / 100;
        var netto = brutto / (1 + item.steuersatz / 100);
        var item = {
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
        var kombi_liste = _kombiartikel[item.artikel];
        positions.push(item);
        for(var ki=0;ki<kombi_liste.length;ki++){
          var nitem = singleArticle(kombi_liste[ki].resultartikel);
          nitem.artikel = nitem.gruppe;
          nitem.referenz = (typeof nitem.referenz === 'string') ? nitem.referenz : '',
          nitem.anzahl =  nitem.anzahl * kombi_liste[ki].resultfaktor;
          nitem.epreis =  nitem.preis * kombi_liste[ki].resultpfaktor;
          nitem.brutto_preis =  nitem.brutto_preis * kombi_liste[ki].resultpfaktor;
          nitem.brutto =  nitem.brutto * kombi_liste[ki].resultpfaktor;
          nitem.netto =  nitem.netto * kombi_liste[ki].resultpfaktor;
          nitem.kombiartikel = true;
          positions.push(nitem);
        }
        currentMode = 'amount';
        amountModeInit = true;
        sum();
      }
    }else if ((item.plugin === 'Ext.plugin.Referenz') && (noPlugin !== true)) {
      currentMode = 'Referenz';
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
        var item = {
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
        positions.push(item);
        currentMode = 'amount';
        amountModeInit = true;
        sum();
      }
    }

  }

  function calcPos(index) {
    if (number === -1) {
      var brutto_preis = positions[index].brutto_preis; // Math.round( positions[index].epreis*(1+positions[index].steuersatz/100) * 100) /100;

      var brutto = Math.round((positions[index].anzahl * brutto_preis) * 100) / 100;

      positions[index].steuersatz = _artikel[positions[index].artikel]['steuer' + feld] * 1;
      var netto = brutto / (1 + positions[index].steuersatz / 100);

      positions[index].brutto_preis = brutto_preis;
      positions[index].brutto = brutto;
      positions[index].netto = netto;
      positions[index].steuer = brutto - netto;
      positions[index].epreis = brutto_preis / (1 + positions[index].steuersatz / 100);
    }
  }

  function sum() {
    total = 0;
    total_without_tax = 0;

    var data = {
      totalNet: 19.00 / 1.07 + 10.00 / 1.19,
      totalNetIncludingTax: 19.00 + 10.00,
      positions: [

      ],
      taxes: [
        /*{
          rate: 7,
          value: 19.5
        },
        {
          rate: 19,
          value: 1.5
        }*/
      ]
    };
    for (var i = 0; i < positions.length; i++) {
      var item = positions[i];


      data.positions.push({
        article: item.artikel,
        reference: item.referenz,
        amount: item.anzahl,
        additionalText: item.zusatztext,
        tax: item.brutto - item.netto,
        taxRate: item.steuersatz,
        net: item.netto,
        includingTax: item.brutto,
        itemPrice: item.epreis,
        itemPriceIncludingTax: item.epreis*(1+item.steuersatz/100)
      })


      total += positions[i].brutto;
      total_without_tax += positions[i].netto;

    }

    total_tax = total - total_without_tax;

    data.totalNet = total_without_tax;
    data.totalNetIncludingTax = total;
    //reportData = data;

    //reportView.loadHtml(getHTML(true));
    console.log('ReportStore.qml #709','enable them')
    if ((typeof reportView!=='undefined')&&(reportView!==null)){
      reportView.refresh(data);
    }

  }




}
