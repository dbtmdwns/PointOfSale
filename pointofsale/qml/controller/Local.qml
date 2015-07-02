import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.LocalStorage 2.0
import com.tualo 1.0

Item {

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


  function relation(cb) {
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

  }
}
