import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2


import "../js/Shunt.js" as Shunt
import "../js/Template.js" as Template
import "../js/SimpleSAX.js" as SimpleSAX


ScrollView {
  //anchors.fill: parent
  flickableItem.interactive: true
  function refresh(dt){
    canvas.refresh(dt);
    canvas.requestPaint();
  }
  id: scrollView
  contentItem :  Canvas {

    id:canvas

    width: (Screen.pixelDensity * 80 * 2)
    height: 15000

    antialiasing: true
    property bool isConverting: false
    transform: Scale {
       xScale: 0.5
       yScale: 0.5
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
         //console.log(canvas.getImage());
         canvas.isConverting=false;
       }
     }
   }


    property var template: ""
    property var data: null

    Component.onCompleted: {

    }


    function refresh(dt){
      data = dt
      timeoutTimer.start();
      template = '
      <line>
        <box fontSize="0.22" width="8" padding="0.01">
        Musterfirma
        Musterweg 1
        98765 Musterort
        </box>
      </line>

      <foreach item="positions">
        <line>
          <box fontSize="0.2" width="0.5" align="right" paddingLeft="0">{amount}x</box>
          <box fontSize="0.2" width="1.0" align="right" paddingLeft="0.01"> {fixedZero(itemPriceIncludingTax)}</box>
          <box fontSize="0.3" width="4" paddingLeft="0.01">{article}</box>
          <box fontSize="0.2" width="0.5" align="right" paddingLeft="0.01">{percent(taxRate)}</box>
          <box fontSize="0.3" width="1.3" align="right" paddingLeft="0.01" paddingRight="0.1">{fixed(includingTax)}</box>
        </line>
        <if term="isNot(additionalText,\'\')">
          <line>
            <box fontSize="0.22" width="7.6" paddingLeft="0.2">{additionalText}</box>
          </line>
        </if>
      </foreach>
      ';


    }


    function draw(context,data){


      var sax = new SimpleSAX.SimpleSAX();
      var contextOffset = 0;

      var pixelPerMM = Screen.pixelDensity;
      var pixelScale = pixelPerMM*10;

      var oldY = 0;
      var newY = 0;
      var maxWidth = 0;
      var lineHeight = 0;
      var item,width,padding,paddingRight,paddingLeft,paddingTop,paddingBottom,align;

      var fontStyle = "black";
      var fontSize = 0.22;

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

            var fontPixelSize = pixelScale*fontSize
            if (fontPixelSize <1){
              fontPixelSize = 1
            }

            context.font = fontPixelSize+"px "+fontName;
            //console.log(fontPixelSize+"px "+fontName);
            lineHeight = Math.max(lineHeight,fontPixelSize * 1.5);
            newY =  wrapText(
              context,
              item.value,
              x + paddingLeft,
              contextOffset + paddingTop,
              width - paddingLeft - paddingRight ,
              fontPixelSize * 1.5 ,
              align
            ) + paddingTop + paddingBottom ;
            oldY = Math.max(newY,oldY);
            x += width;
            maxWidth = Math.max(width,maxWidth);
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
      try{
        scrollView.__verticalScrollBar.value = newY - scrollView.height *0.6
      }catch(e){

      }
      return {
        h: newY + lineHeight * 5,
        w: maxWidth
      };
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
          if ( ((testWidth ) > maxWidth) && (n > 0) ) {
            fillTextAligned(context,line, x, y,maxWidth,align);
            line = words[n] + ' ';
            y += lineHeight;
          } else {
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
      tplCtx.def("fixedZero", function(v) {
        return Number(v).toFixed(0)
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
      var metrics = draw(ctx,tpl.render(data));
      ctx.scale(0.5,0.5);

      //console.log(JSON.stringify(metrics,null,0));
      //canvas.height = metrics.h*2;
      //canvas.width = metrics.w*2;
      /*
      var sourceX = 0;
      var sourceY = 0;
      var sourceWidth = 150;
      var sourceHeight = 150;
      var destWidth = sourceWidth;
      var destHeight = sourceHeight;
      var destX = 0;
      var destY = 0;

      context.drawImage(imageObj, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)
      */

      //console.log(canvas.getImageData());

    }
  }
}