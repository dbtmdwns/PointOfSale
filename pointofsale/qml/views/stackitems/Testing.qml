import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../controlls"
import "../matrix"


import "../../js/Shunt.js" as Shunt
import "../../js/Template.js" as Template
import "../../js/SimpleSAX.js" as SimpleSAX



StackViewItem {
  width: parent.width
  height: parent.height
  title: qsTr("Testing")

  ScrollView {
    anchors.fill: parent

    flickableItem.interactive: true

    contentItem :  Canvas {
      id:canvas
      width: (203 * 8 /2.54)
      height: 15000

      antialiasing: true
      property bool isConverting: false
      transform: Scale {
         xScale: .5
         yScale: .5
     }

     Timer {
       id: timeoutTimer
       interval: 2000
       running: false
       repeat: false
       onTriggered: {
         timeoutTimer.stop();
         if (canvas.isConverting===false){
           canvas.isConverting=true;

           var ctx = canvas.getContext('2d');
           var imageData = ctx.getImageData(0, 0, 255, 255);
           var data = imageData.data;

           console.log(canvas.getImage());
           canvas.isConverting=false;
         }
       }
     }


      property var template: ""
      property var data: null

      Component.onCompleted: {

        timeoutTimer.start();

        template = '
        <line>
          <box fontSize="0.22" width="8" padding="0.1">
          Musterfirma
          Musterweg 1
          98765 Musterort
          </box>
        </line>

        <foreach item="positions">
          <line>
            <box fontSize="0.2" align="right" width="0.5" paddingLeft="0.1">{amount}</box>
            <box fontSize="0.15" align="left" width="0.8" paddingLeft="0.03">x {fixed(itemPriceIncludingTax)}</box>
            <box fontSize="0.2" width="5" paddingLeft="0.1">{article}</box>
            <box fontSize="0.2" align="right" width="0.8" paddingLeft="0.1">{percent(taxRate)}</box>
            <box fontSize="0.2" align="right" width="1.2" paddingLeft="0.1" paddingRight="0.1">{fixed(includingTax)}</box>
          </line>
          <if term="isNot(additionalText,\'\')">
            <line>
              <box fontSize="0.18" width="8" paddingLeft="0.2">{additionalText}</box>
            </line>
          </if>
        </foreach>
        ';
        data = {

          totalNet: 19.00 / 1.07 + 10.00 / 1.19,
          totalNetIncludingTax: 19.00 + 10.00,

          positions: [
            {
              article: "Musterbuch",
              reference: "",
              amount: 1,
              additionalText: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus.",
              tax: 19.00 - 19.00 / 1.07,
              taxRate: 7,
              net: 19.00 / 1.07 ,
              includingTax: 19.00,
              itemPrice: 19.00 / 1.07,
              itemPriceIncludingTax: 19.00
            },
            {
              article: "Postkarte",
              reference: "",
              amount: 10,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 10.00,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            },
            {
              article: "Postkarte X",
              reference: "",
              amount: 10,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 10.00,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            },
            {
              article: "Postkarte S",
              reference: "",
              amount: 1,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 10.00,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            },
            {
              article: "Postkarte M",
              reference: "",
              amount: 999,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 10.00,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            },
            {
              article: "Postkarte Y",
              reference: "",
              amount: 10,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 10.00,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            },
            {
              article: "Postkarte",
              reference: "",
              amount: 10,
              additionalText: "",
              tax: 10.00 - 10.00 / 1.19,
              taxRate: 19,
              net: 10.00 / 1.19 ,
              includingTax: 123.99,
              itemPrice: 1.00 / 1.19,
              itemPriceIncludingTax: 1.00
            }
          ],
          taxes: [
            {
              rate: 7,
              value: 19.5
            },
            {
              rate: 19,
              value: 1.5
            }
          ]
        }



      }

      function draw(context,data){

        var sax = new SimpleSAX.SimpleSAX();
        var contextOffset = 0;
        var pixelScale = 30;
        var oldY = 0;
        var newY = 0;
        var item,width,padding,paddingRight,paddingLeft,paddingTop,paddingBottom,align;

        var fontStyle = "black";
        var fontSize = 0.3;
        var fontName = "sans-serif";

        //ctx.fillStyle = "black"
        //ctx.font = "15px sans-serif";
        sax.emit = function(key,stack,tag){
          if (key==='tag'){
            item = stack[stack.length - 1];
            if (tag==='box'){
              width = 0;
              padding = 0;
              paddingLeft = padding;
              paddingTop = padding;
              paddingRight = padding;
              paddingBottom = padding;
              align = 'L';

              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.width!=='undefined')
              ){
                width = parseFloat(item.attr.width)*pixelScale
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.padding!=='undefined')
              ){
                padding = parseFloat(item.attr.padding)*pixelScale;
                paddingLeft = padding;
                paddingTop = padding;
                paddingRight = padding;
                paddingBottom = padding;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.paddingLeft!=='undefined')
              ){
                paddingLeft = parseFloat(item.attr.paddingLeft)*pixelScale;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.paddingTop!=='undefined')
              ){
                paddingTop = parseFloat(item.attr.paddingTop)*pixelScale;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.paddingRight!=='undefined')
              ){
                paddingRight = parseFloat(item.attr.paddingRight)*pixelScale;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.paddingBottom!=='undefined')
              ){
                paddingBottom = parseFloat(item.attr.paddingBottom)*pixelScale;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.align!=='undefined')
              ){
                align = item.attr.align==='right'?'R':'L';
              }


              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.fontStyle!=='undefined')
              ){
                fontStyle = item.attr.fontStyle;
              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.fontSize!=='undefined')
              ){
                fontSize = parseFloat(item.attr.fontSize);
              }


              context.fillStyle = fontStyle;
              context.font = (pixelScale*fontSize)+"px "+fontName;
              console.log((pixelScale*fontSize)+"px "+fontName);

              newY =  wrapText(context,item.value,x + paddingLeft,contextOffset + paddingTop,width - paddingLeft -paddingRight , (pixelScale*fontSize)*1.5 ,align) + paddingTop + paddingBottom ;
              oldY = Math.max(newY,oldY);
              x += width;
            }else if (tag==='line'){
              contextOffset=oldY;
              x = 0;
              oldY=0;
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.fontStyle!=='undefined')
              ){
                fontStyle = item.attr.fontStyle;
              }else{

              }
              if (
                (typeof item.attr==='object') &&
                (typeof item.attr.fontSize!=='undefined')
              ){
                fontSize = parseFloat(item.attr.fontSize);
              }else{

              }
            }
          }
        }
        sax.parse(data)
      }

      function wrapText(context, text, x, y, maxWidth, lineHeight, align) {
        var textLines = text.split("\n");
        for(var i=0;i<textLines.length;i++){
          var words = textLines[i].trim().split(' ');
          var line = '';
          for(var n = 0; n < words.length; n++) {
            var testLine = line + words[n] + ' ';
            var metrics = context.measureText(testLine);
            var testWidth = metrics.width;


            if (testWidth > maxWidth && n > 0) {

              fillTextAligned(context,line, x, y,maxWidth,align);
              line = words[n] + ' ';
              y += lineHeight;
            }
            else {
              line = testLine;
            }
          }
          fillTextAligned(context,line, x, y,maxWidth,align);
          y += lineHeight;
          //context.stroke();
        }
        return y;
      }

      function fillTextAligned(context,line, x, y,maxWidth,align){
        var xOffset = 0;
        if (align==='R'){
          var metrics = context.measureText(line);
          xOffset = maxWidth-metrics.width;
        }
        context.fillText(line,x + xOffset,y);
      }


      onPaint:{

        var tplCtx = new Shunt.Shunt.Context();
        tplCtx.def('compare',function(a,b){
          return a===b;
        });
        tplCtx.def('isNot',function(a,b){
          return a!==b;
        });
        tplCtx.def("euro", function(v) {
          return Number(v).toFixed(2) + " €"
        });
        tplCtx.def("fixed", function(v) {
          return Number(v).toFixed(2)
        });
        tplCtx.def("percent", function(v) {
          return Number(v).toFixed(0) + " %"
        });


        var tpl = new Template.Template(template,tplCtx);


        canvas.height = 15000;
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = "white";
        ctx.fillRect(0,0,5000,5000);

        ctx.scale(2,2);
        ctx.beginPath();
        ctx.fillStyle = "black"
        ctx.strokeStyle = "transparent"
        ctx.fillStyle = "black"
        ctx.font = "15px sans-serif";
        draw(ctx,tpl.render(data));

        //console.log(canvas.getImageData());

      }
    }
  }



}
