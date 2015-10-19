import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {
  property int minReportNumber: 0
  property int maxReportNumber: 0

  function articles(cb){
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var rs = tx.executeSql('SELECT key,value FROM articles');
        for (var i = 0; i < rs.rows.length; i++) {
          switch (rs.rows.item(i).key) {
          case application.remote.client:
              cb(JSON.parse(rs.rows.item(i).value));
              return;
              break;
          }
        }
        //ok we are here, so there are no articles out there
        application.remote.articles(cb);
      }
    );
  }


  function relations(cb) {
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var rs = tx.executeSql('SELECT key,value FROM relations');
        for (var i = 0; i < rs.rows.length; i++) {
          switch (rs.rows.item(i).key) {
            case application.remote.client:
              cb(JSON.parse(rs.rows.item(i).value));
              return;
              break;
          }
        }
        //ok we are here, so there are no relations out there
        application.remote.relations(cb);
      }
    );

  }

  function config(cb) {
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var rs = tx.executeSql('SELECT key,value FROM config');
        for (var i = 0; i < rs.rows.length; i++) {
          switch (rs.rows.item(i).key) {
            case application.remote.client:
              cb(JSON.parse(rs.rows.item(i).value));
              return;
              break;
          }
        }
        //ok we are here, so there are no relations out there
        application.remote.config(cb);
      }
    );

  }

  function save(json,cb){
    var db = LocalStorage.openDatabaseSync("PointOfSale", "1.0", "", application.dbsize);
    db.transaction(
      function(tx) {
        var newID = minReportNumber;
        tx.executeSql('CREATE TABLE IF NOT EXISTS reports ( key varchar(255), id integer, value TEXT, primary key (key,id) )');
        var sql = 'select max(id) + 1 newid from reports where key = \''+application.remote.client+'\' ';
        var rs = tx.executeSql(sql);
        for (var i = 0; i < rs.rows.length; i++) {
          newID = rs.rows.item(i).newid;
          newID = Math.max(newID,minReportNumber)
        }
        var cbMessage = {
          success: false,
          msg: "Ok we are here "+newID
        }
        //if ((newID>=minReportNumber) && (newID<=maxReportNumber)){
          tx.executeSql('insert into reports (key,id,value) values (\''+application.remote.client+'\','+newID+',\''+application.remote.escapeResult(json)+'\') ');
          cbMessage = {
            success: true,
            belegnummer: newID,
            msg: "Gespeichert"
          }
          minReportNumber = newID+1;
        /*}else{
          cbMessage.msg="Der Nummernkreis ist erschöpft."
        }*/

        cb(null,cbMessage);

      }
    );
  }
}
