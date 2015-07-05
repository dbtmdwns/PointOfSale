import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {
  property string url: ""
  property string username: "admin"
  property string password: "admin"
  property string client: ""
  property string sessionID: ""
  property bool logged_in: false
  property var __callback;

  Timer {
    id: timeoutTimer
    interval: 10000
    running: false
    repeat: false
    onTriggered: {
      __callback({
        response: "not connected"
      }, null);
    }
  }

  Timer {
    id: pingTimer
    interval: 60000
    running: false
    repeat: true
    onTriggered: {
      ping()
    }
  }


  Timer {
    id: asyncTimer
    interval: 15000
    running: true
    repeat: true
    onTriggered: {
      console.log('asyncTimer','triggered')
      if (application.async=='1'){
        var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
        db.transaction(
          function(tx) {
            var sql = 'select * from reports where key = \''+client+'\' ';
            var rs = tx.executeSql(sql);
            console.log('asyncTimer','reports for submission',rs.rows.length)

            post(url, {
              username: username,
              mandant: client,
              password: password,
              "return": "json"
            }, function(err, res) {

              if (err){
                // ToDo
              }else if (res.success) {
                var csession = res.sid;

                asyncList(csession,rs.rows,0,function(){
                  post(url, {
                    TEMPLATE: 'NO',
                    cmp: 'cmp_logout',
                    sid: csession
                  }, function(err, res) {
                  }, false);

                });

              }else if (res.success == false) {
                // ToDo
              }
            });

          }
        );
      }
    }
  }

  function asyncList(csession,list,index,cb){
    if (index<list.length){
      var json = application.remote.unEscapeResult(list[0].value);
      json.id = list[0].id+' '+json.id;
      save(json,function(err,res){
        console.log(err,res);
        if (res.success==true){
          console.log('asyncList','save',res.belegnummer,'id',json.id);
        }else{
          console.log('asyncList','save error',res.msg);
        }
        asyncList(csession,list,index+1,cb);
      },csession);

    }else{
      cb();
    }
  }


  function login(cb){
    post(url, {
      username: username,
      mandant: client,
      password: password,
      "return": "json"
    }, function(err, res) {

      if (err){
        // ToDo
      }else if (res.success) {
        sessionID = res.sid;
        cb();
        pingTimer.start();
      }else if (res.success == false) {
        // ToDo
      }
    });
  }

  function logout(cb) {
    sessionID = '';
    pingTimer.stop();
    cb();
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_logout',
      sid: sessionID
    }, function(err, res) {
    }, false);
  }

  function ping(){
    config(application.processConfig)
  }

  function config(cb) {
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      sid: sessionID,
      page: "pos_get_config",
      "return": "json"
    }, function(err, res) {
      if (err) {
        // todo
        console.log('error',err);
      } else if (res.success) {
        try{
          var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
          db.transaction(
            function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS config (key varchar(255) primary key, value TEXT)');
              tx.executeSql('delete from config where key = \''+client+'\' ');
              var sql = 'insert into config (key,value) values (\''+client+'\',\''+escapeResult(res)+'\')';
              tx.executeSql(sql);
            }
          );
          cb(res);
        }catch(e){
          console.log( e)
        }
        //cb(res);
      } else if (res.success==false) {
        //todo
        console.log('error false',err);
      }
    });
  }

  function articles(cb){
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      sid: sessionID,
      page: "pos_articles",
      "return": "json"
    }, function(err, res) {
      if (err) {
        //todo
      } else if (res.success) {
        var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
        db.transaction(
          function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS articles (key varchar(255) primary key, value TEXT)');
            tx.executeSql('delete from articles where key = \''+client+'\' ');
            tx.executeSql('insert into articles (key,value) values (\''+client+'\',\''+escapeResult(res)+'\') ');
          }
        );
        cb(res);
      } else if (res.success==false) {
        //todo
      }
    });
  }


  function relations(cb) {
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      sid: sessionID,
      page: "pos_relation_matrix",
      "return": "json"
    }, function(err, res) {
      if (err) {

      } else if (res.success) {

        var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
        db.transaction(
          function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS relations (key varchar(255) primary key, value TEXT)');
            tx.executeSql('delete from relations where key = \''+client+'\' ');
            tx.executeSql('insert into relations (key,value) values (\''+client+'\',\''+escapeResult(res)+'\') ');
          }
        );
        cb(res);

      }
    });
  }


  function save(json,cb,csession){
    if (typeof csession==='undefined'){
      csession = sessionID;
    }
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      page: 'single_report',
      sid: csession,
      json: JSON.stringify(html_encode_entities_object(json))
    }, function(err, res) {

      cb(err, res);
    }, true);
  }

  function post(url, data, callback, parse) {
    if (typeof parse === 'undefined') {
      parse = true;
    }
    var xhr = new XMLHttpRequest();
    var send_data = "";
    for (var i in data) {
      send_data += i + "=" + escape(data[i]) + "&";
    }
    var http_result = "";
    __callback = callback;
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        timeoutTimer.stop()
        if (xhr.status === 200) {
          http_result = xhr.responseText;

          if (typeof callback !== 'undefined') {
            try {
              if (parse === true) {
                var result = JSON.parse(http_result);
                result._responseText = http_result;
              } else {
                result = http_result;
              }
              callback(null, result);

            } catch (e) {
              console.log(xhr.responseText);
              console.log('catched error',e.toString());
              callback({
                error: e,
                status: xhr.status,
                response: xhr.responseText
              }, null);
            }
          }
        } else {
          callback({
            status: xhr.status,
            response: xhr.responseText
          }, null)
        }
      } else if (xhr.readyState === 3) {}
      if (xhr.readyState === 1) {
        timeoutTimer.start()
      }
    }

    xhr.open("POST", url);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
    xhr.setRequestHeader("Content-Length", send_data.length);
    xhr.setRequestHeader("Connection", "close");
    xhr.send(send_data);


  }

  function escapeResult(res){
    return JSON.stringify(res,null,0).replace(/'/gm,"#qoute;");
  }

  function unEscapeResult(res){
    return JSON.parse(res.replace(/#qoute;/gm,"'"));
  }
}
