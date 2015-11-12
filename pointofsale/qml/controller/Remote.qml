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
  property int reports_not_in_sync: 0
  property bool logged_in: false
  property bool syncing: false
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
    interval: 60000
    running: true
    repeat: true
    onTriggered: {

      if (application.async=='1'){
        console.log('autosync');
        doSync();
      }

    }
  }

  Timer {
    id: unSyncTimer
    interval: 30000
    running: true
    repeat: true
    onTriggered: {

      if (application.async!='0'){
        tmrUnSyncRPT();
      }

    }
  }

  function tmrUnSyncRPT(){
    unsyncReports(function(num){
      reports_not_in_sync=num;
    })
  }

  function unsyncReports(cb){
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var sql = 'select id from reports where key = \''+client+'\' ';
        var rs = tx.executeSql(sql);
        console.log('counts '+rs.rows.length);
        cb(rs.rows.length);
      }
    );
  }
  function doSync(){
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var sql = 'select * from reports where key = \''+client+'\' ';
        var rs = tx.executeSql(sql);

        syncing = true;
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
            sessionID = csession;
            ping();
            asyncList(csession,rs.rows,0,function(){
              post(url, {
                TEMPLATE: 'NO',
                cmp: 'cmp_logout',
                sid: csession
              }, function(err, res) {

                tmrUnSyncRPT();

                sessionID="";
                syncing = false;
              }, false);

            });

          }else if (res.success == false) {
            // ToDo
          }
        });

      }
    );
  }


  function asyncList(csession,list,index,cb){
    if (index<list.length){
      var json = application.remote.unEscapeResult(list[index].value);
      var xid = list[index].id
      json.id = list[index].id+' '+json.id;
      save(json,function(err,res){

        console.log('asyncList',JSON.stringify(res,null,1));

        if (res.success==true){
        }else{
        }
        if ((res.success==true) || ((res.success==false) && (res.code===1))){
          var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
          db.transaction(
            function(tx) {
              var sql = 'delete from reports where key = \''+client+'\' and  id = \''+xid+'\' ';
              tx.executeSql(sql);
              console.log('asyncList',list.length,index+1);
              asyncList(csession,list,index+1,cb);
            }
          );
        }

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
        console.log('err',err);
      }else if (res.success) {
        sessionID = res.sid;
        cb(true);
        pingTimer.start();
      }else if (res.success == false) {
        // ToDo
        displayMessage(res.msg,true)
        application.message=res.msg
        cb(false);
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
    articles(function(){ });
  }

  function config(cb) {
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      sid: sessionID,
      page: "pos_get_config_v"+application.version,
      "return": "json"
    }, function(err, res) {
      if (err) {
        // todo
        console.log('error',err.toString());
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
        }catch(e){
          console.log( e)
        }
        cb(res);
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
      page: "pos_articles_v"+application.version,
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

            tx.executeSql('DROP TABLE IF EXISTS searchablearticles');
            tx.executeSql('CREATE TABLE IF NOT EXISTS searchablearticles (
              key varchar(255),
              id integer,
              article varchar(255),
              waregroup varchar(255),
              articlenumber varchar(255),

              staffeln TEXT,
              value TEXT,
              primary key (key,id)
            )');

            tx.executeSql('CREATE INDEX IF NOT EXISTS idx_sa_article on searchablearticles(article)');
            tx.executeSql('CREATE INDEX IF NOT EXISTS idx_sa_waregroup on searchablearticles(waregroup)');
            tx.executeSql('CREATE INDEX IF NOT EXISTS idx_sa_articlenumber on searchablearticles(articlenumber)');
            var sql = 'delete from searchablearticles where key=\''+client+'\'';
            tx.executeSql(sql);

            var list = res.staffeln;
            for(var i =0;i< list.length;i++){
              var item = list[i];
              try{
                var sql = ' insert into searchablearticles
                (key,id,article,waregroup,articlenumber,staffeln,value)
                values (
                  \''+client+'\',
                  '+i+',
                  \''+item.gruppe.replace(/'/gm,"#qoute;")+'\',
                  \''+res.artikel[item.gruppe].warengruppe.replace(/'/gm,"#qoute;")+'\',
                  \''+res.artikel[item.gruppe].artikelnummer.replace(/'/gm,"#qoute;")+'\',
                  \''+escapeResult(item)+'\',
                  \''+escapeResult(res.artikel[item.gruppe])+'\'
                )
                ';
                tx.executeSql(sql);
              }catch(e){

              }
            }

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
  }// 27009


  function save(json,cb,csession){
    if (typeof csession==='undefined'){
      csession = sessionID;
    }
    post(url, {
      TEMPLATE: 'NO',
      cmp: 'cmp_mde_sync',
      page: "single_report_v"+application.version,
      sid: csession,
      json: JSON.stringify(html_encode_entities_object(json))
    }, function(err, res) {

      cb(err, res);
    }, true);
  }

  function shortPost(data, callback) {
    var pdata = {
      TEMPLATE: 'NO',
      sid: sessionID
    }
    for(var key in data){
      pdata[key] = data[key];
    }
    post(url, pdata, function(err, res) {
      callback(err, res);
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
            } catch (e) {
              callback({
                error: e,
                status: xhr.status,
                response: xhr.responseText
              }, null);
              return;
            }
            callback(null, result);


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
