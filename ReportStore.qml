pragma Singleton
import QtQuick 2.0
import QtWebKit 3.0
import "../styles"
import "../singleton"
Item {

    property double given: 0
    property string _givenfraction: ""
    property double total: 0
    property double total_tax: 0
    property double total_without_tax: 0
    property int number: -1
    property var positions: []
    property var update
    property var styles

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


    property var _steuergruppen: []
    property string _warengruppe: ""
    property var _warengruppen: []
    property var _staffeln: []
    property var _artikel: []
    property string lastReport: ""
    property double lastTotal: 0

    property string datum;
    property string zeit;

    property string ticketHeader;
    property string ticketItem;
    property string ticketFooter;
    property string ticketTaxesPositions;
    property string ticketTaxesHeader;
    property string ticketTaxesFooter;


    property WebView reportView: null

    property var oldReportsUpdate: null
    property var oldReports: [ ]

    Timer {
      id: messageHideTimer
      interval: 1000
      running: false
      repeat: false
      onTriggered: {
        messageHideTimer.stop();
        message="";
      }
    }

    function displayMessage(msg,hold){
        if (typeof hold==='undefined'){
            hold=false;
        }
        if (hold){
            messageHideTimer.interval=30000;
        }else{
            messageHideTimer.interval=1000;
        }
        message=msg;
        messageHideTimer.start();
    }

    function loadArticles(cb){
        App.getPOSArticles(function(res){
            _steuergruppen = res.steuergruppen;
            for(var i in res.warengruppen){
                res.warengruppen[i].farbe = App.rgb_hex_Color(res.warengruppen[i].farbe);
            }

            _warengruppen = res.warengruppen;
            _staffeln = res.staffeln;
            _artikel = res.artikel;
            cb();
        });
    }

    function pushOldReport(item){


        oldReports.push(item)

        if (oldReports.length>10){
            oldReports = oldReports.slice(1);
        }
        if(typeof oldReportsUpdate==="function"){
            oldReportsUpdate();
        }
    }

    function getWarengrupen(){

        return _warengruppen;
    }



    function getArtikel(warengruppe){
        _warengruppe = warengruppe;
        var res = [];

        for(var i in _artikel){
            if (_artikel[i].warengruppe === warengruppe){
                //res.push(_artikel[i]);
                for(var s in _staffeln){
                    if (_staffeln[s].gruppe === _artikel[i].gruppe){


                        if (preiskategorie*1 === _staffeln[s].preiskategorie*1){

                            var item={};
                            item.gruppe = _staffeln[s].gruppe;

                            item.anzahl = 1;
                            //_staffeln[s].brutto = Math.round(_staffeln[s].preis * (1 + 1*_artikel[i]["steuer"+feld]/100)*100)/100;

                            item.steuersatz = 1*_artikel[i]["steuer"+feld];
                            item.bpreis = _staffeln[s].brutto;
                            item.preis = _staffeln[s].brutto / (1+item.steuersatz/100);
                            item.netto = item.preis;

                            item.brutto_preis = _staffeln[s].brutto * 1;
                            item.brutto = _staffeln[s].brutto * 1;

                            item.zusatztext =  _artikel[i].zusatztext;
                            res.push( item );

                        }
                    }
                }
            }
        }
        return res;
    }

    function cmd(cmdtype,val){
        if (cmdtype === 'PLUSMINUS'){
            if(number===-1){
                if (currentMode === 'amount'){
                    positions[positions.length-1].anzahl*=-1;
                    calcPos(positions.length-1);
                }
            }
        }

        if (cmdtype === 'SEP'){
            if(number===-1){
                if (currentMode === 'amount'){

                }else if (currentMode === 'price'){
                    if (priceModeInit){
                        positions[positions.length-1].brutto_preis=0;
                        priceModeInit = false;
                    }else{


                    }
                    positions[positions.length-1]._fraction ="";
                    fractionMode=true;
                }else if (currentMode === 'pay'){
                    if (givenModeInit){
                        given=0;
                        givenModeInit = false;
                    }else{


                    }
                    _givenfraction ="";
                    givenPModeInit=true;
                    fractionMode=true;
                }
            }
        }

        if (cmdtype === 'PAYFIT'){
            if (currentMode === 'pay'){
                given=total
                givenModeInit=true;
                givenPModeInit=true;
            }
        }

        if (cmdtype === 'CANCLEPAY'){
            currentMode='amount';
            amountModeInit = true;
        }

        if (cmdtype === 'ADDPAY'){
            if(givenPModeInit){
                given=val;
                givenPModeInit=false;
            }else{
                given+=val;
            }

            givenModeInit = true;
        }



        if (cmdtype === 'NUM'){
            if (positions.length===0){
                return;
            }

            if(number===-1){
                if (currentMode === 'amount'){
                    if (amountModeInit){
                        positions[positions.length-1].anzahl=val;
                        amountModeInit = false;
                    }else{
                        positions[positions.length-1].anzahl*=10;
                        positions[positions.length-1].anzahl+=val;
                    }
                    calcPos(positions.length-1);
                }else if (currentMode === 'price'){

                    if (priceModeInit){
                        positions[positions.length-1].brutto_preis=val;
                        priceModeInit = false;
                    }else{
                        if (typeof positions[positions.length-1]._fraction==='undefined'){
                            positions[positions.length-1]._fraction="";
                        }

                        if (fractionMode){
                            positions[positions.length-1]._fraction+=val+"";
                            var f = Math.floor(positions[positions.length-1].brutto_preis);
                            positions[positions.length-1].brutto_preis =  (f + "." +positions[positions.length-1]._fraction)*1;
                        }else{
                            positions[positions.length-1].brutto_preis*=10;
                            positions[positions.length-1].brutto_preis+=val;
                        }
                    }
                    calcPos(positions.length-1);
                }else if (currentMode === 'pay'){

                    givenPModeInit=true;

                    if (givenModeInit){
                        given=val;
                        givenModeInit = false;
                    }else{


                        if (fractionMode){
                            _givenfraction+=val+"";
                            var gf = Math.floor(given);
                            given =  (gf + "." +_givenfraction)*1;
                        }else{
                            given*=10;
                            given+=val;
                        }
                    }
                }

            }

        }

        if (cmdtype === 'AMOUNTPRICESWITCH'){
            if (currentMode === 'amount'){
                currentMode = 'price';
                priceModeInit = true;
                fractionMode=false;
            }else if (currentMode === 'price'){
                currentMode = 'amount';
                amountModeInit = true;
                fractionMode=false;
            }else if (currentMode === 'pay'){
                //currentMode = 'amount';
            }
        }


        if (cmdtype === 'CANCLE'){
            if(number===-1){
                positions = [];
            }else{
                number=-1;
                for(var i in positions){
                   positions[i].anzahl*=-1;
                   calcPos(i);
                }
            }

        }

        if (cmdtype === 'CANCLE LAST'){
            if(number===-1){
                positions.pop();
            }
        }

        if (cmdtype === 'SET RELATION'){

            feld = _steuergruppen[val.steuerschluessel].feld;
            relation = val.name;
            kundennummer = val.kundennummer;
            kostenstelle = val.kostenstelle;
            preiskategorie = val.preiskategorie;

            for(var i in positions){
               calcPos(i);
            }
        }

        if (cmdtype === 'CUT'){
            // open drawer

            App.posPrinter.cut()//.print(getHTML());
        }


        if (cmdtype === 'OPEN'){
            // open drawer

            App.posPrinter.openDrawer()//.print(getHTML());
        }

        if (cmdtype === 'PRINT'){
            App.posPrinter.allPrinters();
            //console.log(getHTML());
            App.posPrinter.print(lastReport);
        }



        if (cmdtype === 'REPORTMODE'){
            if (reportMode){
                reportMode=false;
            }else{
                reportMode=true;
            }
        }

        if (cmdtype === 'OPENREPORT'){

            positions = val.positions;
            number = val.belegnummer;
            datum = val.datum;
            zeit = val.zeit;
            kundennummer = val.kundennummer;
            kostenstelle = val.kostenstelle;
            positions = val.positionen;
        }



        if (cmdtype === 'ENTER'){

            if(total!==0){
                if(number===-1){

                    if (currentMode==='pay'){
                        if (given>=total){
                            displayMessage("Der Beleg wird gespeichert.",true);
                            currentMode='paysave';
                            App.posPrinter.openDrawer();

                            App.saveReport(kundennummer,kostenstelle,positions,given,function(err,res){
                                if (err){
                                    displayMessage(err.response);
                                    console.log(err.response);
                                }else{

                                    if (res.success){
                                        number = res.belegnummer;
                                        zeit = (new Date()).toISOString().substring(11,16);
                                        datum = (new Date()).toISOString().substring(0,10);
                                        lastReport = getHTML();
                                        var  item = {
                                            zeit: zeit,
                                            kundennummer: kundennummer,
                                            kostenstelle: kostenstelle,
                                            datum: datum,
                                            belegnummer: number,
                                            brutto: total,
                                            positionen: positions,
                                            html: lastReport,
                                            displayColor: "#41414f",
                                            displayText: ""+number+" "+zeit+" | <b>"+total.toFixed(2)+" €</b>"
                                        }
                                        pushOldReport(item);

                                        positions = [];
                                        number = -1;
                                        displayMessage( res.belegnummer+" gespeichert.");
                                        lastTotal = total;

                                        currentMode = 'amount';
                                        //App.posPrinter.openDrawer();

                                    }else{
                                        displayMessage(res.msg);
                                    }
                                    sum();
                                }

                            });
                        }
                    }else{

                        _givenfraction = "";
                        given = total;

                        givenModeInit=true;
                        givenPModeInit=true;

                        currentMode='pay';
                    }
                }else{
                    positions = [];
                    number= -1;
                }
            }

        }
        sum();
    }

    function add(item){
        if(number===-1){
            lastTotal = 0;
            var brutto_preis = item.brutto_preis;
            var brutto  = Math.round(  ( item.anzahl * brutto_preis ) *100) /100;
            var netto = brutto / (1+item.steuersatz/100);
            var item = {
                artikel: item.gruppe,
                zusatztext: item.zusatztext,
                referenz: item.referenz,
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

    function calcPos(index){

        var brutto_preis = positions[index].brutto_preis;// Math.round( positions[index].epreis*(1+positions[index].steuersatz/100) * 100) /100;

        var brutto  = Math.round(  ( positions[index].anzahl * brutto_preis ) *100) /100;

        positions[index].steuersatz =_artikel[positions[index].artikel]['steuer'+feld]*1;
        var netto = brutto / (1+  positions[index].steuersatz/100);

        positions[index].brutto_preis = brutto_preis;
        positions[index].brutto = brutto;
        positions[index].netto = netto;
        positions[index].steuer = brutto - netto;
        positions[index].epreis = brutto_preis/(1+positions[index].steuersatz/100);

    }

    function sum(){
        total=0;
        total_without_tax=0;
        for(var i=0;i<positions.length;i++){
            total+=positions[i].brutto;
            total_without_tax+=positions[i].netto;

        }
        total_tax = total - total_without_tax;
        //console.log("OK",total);
        if (typeof update==="function"){
            update();
        }
    }

    function _extractPart(template,str){
        var start = "<!--"+str+"-->";
        var end = "<!--/"+str+"-->";
        return template.substring(template.indexOf(start),template.indexOf(end)+end.length);
    }

    function getHTML(display){
        var template = App.posPrinter.readFile(App.template_file);

        ticketHeader = _extractPart(template,"HEADER");
        ticketItem = _extractPart(template,"ITEM");
        ticketFooter = _extractPart(template,"FOOTER");
        ticketTaxesPositions = _extractPart(template,"TAX_ITEM");
        ticketTaxesHeader = _extractPart(template,"TAX_HEADER");
        ticketTaxesFooter = _extractPart(template,"TAX_FOOTER");

        if (typeof styles==="object"){
            var h="<!DOCTYPE html>";
            h+=getHTMLHeader();
            for(var i=0;i<positions.length;i++){
                h+=getHTMLPosition(i);
            }
            h+=getHTMLTaxes();
            h+=getHTMLFooter();

            if (display===true){
                var extract = _extractPart(h,"HIDE ON DISPLAY");
                h = h.replace(extract,"");
            }

            return h;
        }else{
            return "";
        }
    }
    function getHTMLHeader(){
        return _hReplace(ticketHeader);
    }

    function getHTMLPosition(index){
        if (typeof positions[index]==="object"){
            var h = ticketItem;
            for (var i in positions[index]){
                switch(i){
                case "brutto":
                case "netto":
                case "epreis":
                case "brutto_preis":
                case "steuer":
                    h=h.replace("{"+i+"}",positions[index][i].toFixed(2));
                    break;
                case "steuersatz":
                    h=h.replace("{"+i+"}",positions[index][i].toFixed(0));
                    break;
                default:
                    h=h.replace("{"+i+"}",positions[index][i]);
                    break;
                }
            }
            return h;
        }else{
            return "";
        }
    }


    function getHTMLTaxes(){

        var html = _hReplace(ticketTaxesPositions);
        var h = "";
        var taxes = {};

        for (var index in positions){

            if (typeof taxes['S'+positions[index].steuersatz]==='undefined'){
                taxes['S'+positions[index].steuersatz] = 0;
            }
            ;
            taxes['S'+positions[index].steuersatz]+=positions[index].brutto -positions[index].netto

        }

        for (var tax in taxes){
            h+=html.replace("{tax}",tax.substring(1)).replace("{tax_value}",taxes[tax].toFixed(2));
        }

        return _hReplace(ticketTaxesHeader) + h + _hReplace(ticketTaxesFooter);
    }

    function getHTMLFooter(){

        return _hReplace(ticketFooter).replace("</body>","<script>window.scrollTo(0, "+App.fixview+");</script></body>");
    }

    function _hReplace(html){
        html = html.replace("{datum}", (datum.split('-')).reverse().join('.') );
        html = html.replace("{zeit}",zeit);

        html = html.replace("{belegnummer}",number);
        html = html.replace("{number}",number);
        html = html.replace("{preiskategorie}",preiskategorie);
        html = html.replace("{relation}",relation);
        html = html.replace("{total}",total.toFixed(2));
        html = html.replace("{total_tax}",total_tax.toFixed(2));
        html = html.replace("{total_without_tax}",total_without_tax.toFixed(2));
        return html;
    }

}
