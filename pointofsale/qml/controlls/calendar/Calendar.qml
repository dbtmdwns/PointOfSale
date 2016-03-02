import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

GridLayout {
    id: root
    //anchors.fill: parent
    columns: 7

    property var date: new Date()
    property int displayMonth: 1
    property int displayYear: 2014
    property var store: null
    property var list: null

    property int buttonSpacing: 8

    property var days: ['So.','Mo.','Di.','Mi.','Do.','Fr.','Sa.']
    property var months: ['Januar',
                          'Februar',
                          'März',
                          'April',
                          'Mai',
                          'Juni',
                          'Juli',
                          'August',
                          'September',
                          'Oktober',
                          'November',
                          'Dezember']

    Component.onCompleted: {
        setDate(new Date());
    }


    function prevMonth(){
        displayMonth--;
        if (displayMonth === -1){
            displayMonth = 11;
            displayYear--;
        }
        redrawMonth( displayMonth,displayYear);
    }

    function nextMonth(){
        displayMonth++;
        if (displayMonth === 12){
            displayMonth = 0;
            displayYear++;
        }
        redrawMonth( displayMonth,displayYear);
    }

    function getValue(value){
        var result = {
            amount: 0
        },
            i;

        if (store!==null){
            for(i in store){
                if ( (typeof store[i] === 'object') && (typeof store[i].date === 'string') ) {
                    if (store[i].date === value){
                        return store[i];
                    }
                }
            }
        }
        return result;
    }

    function redrawMonth(month,year){
        var useDate = new Date(),
            i = 0,
            subtract = 0,
            today = new Date();

        useDate.setMonth(month);
        useDate.setYear(year);
        useDate.setDate(1);


        subtract = useDate.getDay() * 86400000;
        monthText.text = months[month]+" "+useDate.getFullYear();

        for(i=0;i<7;i++){
            headlineRepeater.itemAt(i).text = days[i]
            headlineRepeater.itemAt(i).amount = 0;
        }

        list=[];
        useDate = new Date(useDate.getTime() - subtract);
        for(i=0;i<42;i++){
            if (month !== useDate.getMonth()){
                repeater.itemAt(i).opacity = 0.3;
            }else{
                repeater.itemAt(i).opacity = 1;
            }
            if (
                (useDate.getDate() === today.getDate() ) &&
                (useDate.getMonth() === today.getMonth() ) &&
                (useDate.getYear() === today.getYear() )
            ){
                repeater.itemAt(i).current = true;
            }else{
                repeater.itemAt(i).current = false;
            }

            if (
                (useDate.getDate() === date.getDate() ) &&
                (useDate.getMonth() === date.getMonth() ) &&
                (useDate.getYear() === date.getYear() )
            ){
                repeater.itemAt(i).checked = true;
            }else{
                repeater.itemAt(i).checked = false;
            }
            list.push(useDate);

            repeater.itemAt(i).text = useDate.getDate();
            repeater.itemAt(i).amount = getValue(useDate.toISOString().substring(0,10)).amount;
            useDate = new Date(useDate.getTime() + 86400000);
        }
    }

    function setDate(__date){
        date = __date;
        //App.debug('Calendar','setDate',date);
        displayMonth=date.getMonth();
        displayYear=date.getFullYear();
        redraw(date);
    }

    function redraw( ){
        redrawMonth(displayMonth,displayYear);
    }

    DayButton{

        width:  root.width  / 7 - buttonSpacing
        height:  root.height  / 9
        text: "<"

        amount: "0"
        onClicked: {
            prevMonth();
        }
        checkable: false
    }

    RowLayout{
        width:  root.width  / 7- buttonSpacing
        height:  root.height  / 9

        Layout.columnSpan: 5
        Text{
            id: monthText
            text: "April"
            color: "white"
            clip: true
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: (Math.min(root.width,root.height) /9   )*0.5
        }
    }

    DayButton{
        width:  root.width  / 7- buttonSpacing
        height:  root.height  / 9
        text: ">"
        amount: "0"
        onClicked: {
            nextMonth();
        }
        checkable: false
    }

    Repeater {
        id: headlineRepeater
        model: 7
        DayButton {
            width:  root.width  / 7- buttonSpacing
            height:  root.height  / 9
            checkable: false
        }

    }

    Repeater {
        id: repeater
        model: 42
        DayButton {
            width:  root.width  / 7 - buttonSpacing
            height:  root.height  / 9
            onClicked: {
              setDate(list[index]);
            }
        }

    }

}
