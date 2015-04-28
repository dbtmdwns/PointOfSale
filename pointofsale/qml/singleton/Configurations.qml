pragma Singleton
import QtQuick 2.0


Item {

  property var waregroups: [
    {
      text: "Bücher"
    },
    {
      text: "Handelsware"
    },
    {
      text: "Zeitungen"
    },
    {
      text: "Tickets"
    }
  ]

  property var articles: [
    {
      text: "Malen nach Zahlen",
      waregroup: "Bücher",
      priceWithOutTax: 8.18,
      priceWithTax: 9.99,
      tax: 7
    }
  ]

  function getWaregroups(){
    return waregroups;
  }

  function getArticles(waregroup){
    var list = [];
    for(var i=0,m=articles.length;i<m;i++){
      if (articles[i].waregroup === waregroup){
        list.push(articles[i]);
      }
    }
    return list
  }

}
