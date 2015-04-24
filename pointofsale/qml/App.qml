pragma Singleton

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {

    property string sessionID: ""
    property string url: ""

    property string aurl: ""

    property string username: "admin"
    property string password: "admin"
    property string client: ""

    property string receipt: ""
    property string department: ""
    property string reference_number: ""
    property string items_group: ""
    property string fullscreen: ""
    property string posTitle: ""

    property int leftMatrixWidth: 100
    property int rightMatrixWidth: 100
    property int fontSize: 22
    property int buttonFontSize: 22

    property int totalDisplayRows: 1


    property int leftSideColumns: 3
    property int rightSideColumns: 3

    property int waregroupColumns: 1
    property int waregroupRows: 10

    property int relationColumns: waregroupColumns + articleColumns
    property int relationRows: 1

    property int articleColumns: 8
    property int articleRows: 10

    property string template_file: ""
    property string logo_file: ""
    property string left_logo_file: ""
    property string fixview: ""

    property var __callback
    property var use_date

    property alias posPrinter: posPrinter

    PosPrinter{
        id: posPrinter
    }


    function rgb_hex_Color(str){
        var red=0;
        var green=0;
        var blue=0;
        var alpha=1;
        if (str.indexOf("rgb(")===0){
           str = str.replace("rgb(","");
           str = str.replace(")","");
           str = str.replace(";","");
           var a = str.split(",");

            if (a.length===3){
                red=a[0]/255;
                green=a[1]/255;
                blue=a[2]/255;
            }
        }
        if (str.indexOf("#")===0){

        }
        return Qt.rgba( red,  green,  blue,  alpha);
    }

    Timer {
        id: timeoutTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            __callback({response: "not connected"},null);
        }
    }


    Component.onCompleted: {
        use_date = new Date();


        url = posPrinter.getEnv("POSURL","");
        fullscreen = posPrinter.getEnv("POSFULLSCREEN","0");
        posTitle = posPrinter.getEnv("POSTITLE","Point of Sale");
        fontSize = posPrinter.getEnv("POSFONTSIZE","18")*1;
        buttonFontSize = posPrinter.getEnv("POSBUTTONFONTSIZE","24")*1;
        client = posPrinter.getEnv("POSCLIENT","");
        username = posPrinter.getEnv("POSUSER","admin");
        password = posPrinter.getEnv("POSPASSWORD","admin");
        fixview = posPrinter.getEnv("POSFIXVIEW","10000");
        template_file = posPrinter.getEnv("POSTEMPLATE","");
        logo_file = posPrinter.getEnv("POSLOGO","");
        left_logo_file = posPrinter.getEnv("POSLEFTLOGO","");

        leftMatrixWidth = posPrinter.getEnv("POSLEFTSPACERWIDTH","100")*1;
        rightMatrixWidth = posPrinter.getEnv("POSRIGHTSPACERWIDTH","100")*1;

        waregroupColumns = posPrinter.getEnv("POSWGCOLUMNS","1")*1;
        waregroupRows = posPrinter.getEnv("POSWGROWS","10")*1;


        //relationColumns = posPrinter.getEnv("POSRELCOLUMNS","5")*1;
        relationRows = posPrinter.getEnv("POSRELROWS","1")*1;


        articleColumns = posPrinter.getEnv("POSARTCOLUMNS","8")*1;
        articleRows = posPrinter.getEnv("POSARTROWS","10")*1;

    }

    function saveSettings(){

    }



    function wawiLogin(cb){
        debug('App','login - TRY',url);
        post(url, {
            username: username,
            mandant: client,
            password: password,
            "return": "json"
        },function(err,res){
            if (err){
                debug('App','login - ERROR',jsonDebug(err));
            }else if (res.success){
                sessionID = res.sid;
                cb();
            }
        });
    }


    function wawiLogout(cb){
        post(url, {
            TEMPLATE: 'NO',
            cmp: 'cmp_logout',
            sid: sessionID
        },function(err,res){
            sessionID = '';
            cb()
        },false);
    }


    function saveReport(kundennummer,kostenstelle,positions,gegeben,cb){
        var json = {};
        json.id = 'Kasse ' + (new Date()).toISOString();
        json.tabellenzusatz = 'BARVERKAUF';
        json.datum = (new Date()).toISOString().substring(0,10);
        json.liste = positions;
        json.gegeben = gegeben;

        json.kasse = "Dresden";
        json.zahlungsart = "Bar";
        json.kundennummer = kundennummer;
        json.kostenstelle = kostenstelle;

        post(url, {
            TEMPLATE: 'NO',
            cmp: 'cmp_mde_sync',
            page: 'single_report',
            sid: sessionID,
            json: JSON.stringify( html_encode_entities_object(json) )
        },function(err,res){

            cb(err,res);
        },true);
    }

    function getPOSArticles(cb){
        post(url, {
             TEMPLATE: 'NO',
             cmp: 'cmp_mde_sync',
             sid: sessionID,
             page: "pos_articles",
            "return": "json"
        },function(err,res){
            if (err){
                debug('App','articles - ERROR',jsonDebug(err));
            }else if (res.success){
                cb(res);
            }
        });
    }


    function getMatrixRelations(cb){
        post(url, {
             TEMPLATE: 'NO',
             cmp: 'cmp_mde_sync',
             sid: sessionID,
             page: "pos_relation_matrix",
            "return": "json"
        },function(err,res){
            if (err){
            }else if (res.success){
                cb(res);
            }

        });
    }

    /**
    * formating objects for console logging
    */
    function jsonDebug(res,intend){
        var s = '';
        if (typeof intend === 'undefined'){
            intend = '   ';
        }
        for(var i in res){
            s+=intend;
            if (typeof res[i]==='object'){
                s+=i+': '+ jsonDebug(res[i],intend+'   ');
            }else if (typeof res[i]==='function'){
                s+=i+': '+ '[function]';
            }else{
                s+=i+': '+ res[i];
            }
            s+="\n";
        }
        return "{\n"+s+"\n"+intend+"}";
    }


    function html_encode_entities_object(_object){
        for(var _property in _object){
            if (_object.hasOwnProperty(_property)){
                if (typeof _object[_property]==='string'){
                    _object[_property] = _object[_property].replace(/[\u00A0-\u9999<>\&]/gim, function(i) {
                        return '&#'+i.charCodeAt(0)+';';
                     });
                }
                if (typeof _object[_property]==='object'){
                    _object[_property] = html_encode_entities_object(_object[_property]);
                }
            }
        }
        return _object;
    }

    function html_decode_entities_object(_object){
        for(var _property in _object){
            if (_object.hasOwnProperty(_property)){
                if (typeof _object[_property]==='string'){
                    _object[_property] = _object[_property].replace(/&#\d+;/gm,function(s) {
                        console.log(s.match(/\d+/gm)[0]);
                        return String.fromCharCode(s.match(/\d+/gm)[0]);
                    });
                }
                if (typeof _object[_property]==='object'){
                    _object[_property] = html_decode_entities_object(_object[_property]);
                }
            }
        }
        return _object;
    }

    function debug(QMLFile,Tag,o){
        console.debug(QMLFile,Tag,o);
    }

    function post(url,data,callback,parse) {

        if (typeof parse==='undefined'){
            parse = true;
        }
        var xhr = new XMLHttpRequest();
        var send_data = "";
        for(var i in data){
            send_data +=i+"="+escape(data[i])+"&";
        }

        var http_result = "";

        __callback = callback;
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                timeoutTimer.stop()

                if(xhr.status === 200) {
                    http_result = xhr.responseText;


                    if (typeof callback!=='undefined'){
                        try{
                            if (parse===true){
                                var result = JSON.parse(http_result);

                                result._responseText = http_result;
                            }else{
                                result = http_result;
                            }
                            callback(null,result)
                        }catch(e){
                            callback({
                                 error: e,
                                 status: xhr.status,
                                 response: xhr.responseText
                             },null);
                        }
                    }
                } else {
                    callback({
                        status: xhr.status,
                        response: xhr.responseText
                    },null)
                }
            } else if (xhr.readyState === 3){
            } if( xhr.readyState === 1 ) {
                timeoutTimer.start()
            }
        }
        xhr.open("POST", url);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
        xhr.setRequestHeader("Content-Length", send_data.length);
        xhr.setRequestHeader("Connection", "close");
        xhr.send(send_data);
    }
}
