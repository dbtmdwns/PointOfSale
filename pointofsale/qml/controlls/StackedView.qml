import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


import "../controlls"
import "../views"
import "../styles"

Rectangle {

    property alias initialItem: stackView.initialItem
    property alias currentItem: stackView.currentItem


    function push(item,title){
        stackView.push(item);
        if (typeof title !== "undefined"){
            stackView.currentItem.title = title;
        }
    }

    function pop(item){
        stackView.pop(item);
    }


    Rectangle {
        color: mainStyle.colors.stackViewBackground
        anchors.fill: parent
    }



    Rectangle {

      opacity: 0.3//(application.message === "") ? 0 : 1
      color: "white"
      radius: 5
      width: 10 //  parent.width * 0.30
      height: 10 // parent.height * 0.30
      Behavior on opacity {
        OpacityAnimator {
          easing.type: Easing.InCubic;
          duration: 150
        }
      }
      Text {
        anchors.centerIn: parent
        clip: true
        text: application.message
      }
    }

    StackView {
        id: stackView
        y: toolbar.height
        height: parent.height - toolbar.height
        delegate: StackViewDelegate {

            function transitionFinished(properties)
            {
                properties.exitItem.opacity = 1
            }

            pushTransition: StackViewTransition {
                PropertyAnimation {
                    duration: 100
                    target: enterItem
                    property: "opacity"
                    from: 0
                    to: 1
                }
                PropertyAnimation {
                    duration: 100
                    target: exitItem
                    property: "opacity"
                    from: 1
                    to: 0
                }
            }

        }
    }

    Rectangle {
        id: toolbar
        color: mainStyle.colors.toolbarBackground
        height: mainStyle.dimens.toolbarHeight
        width: parent.width



        Rectangle {
            id: backButton
            width: opacity ? mainStyle.dimens.backButtonWidth : 0

            anchors.left: parent.left
            anchors.leftMargin: mainStyle.dimens.leftMargin
            opacity: stackView.depth > 1 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            height: mainStyle.dimens.backButtonHeight
            radius: 4
            color: backmouse.pressed ? "#222" : "transparent"
            Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }
            Text{
                text: "\uf053"
                color: mainStyle.colors.toolbarPrevIcon
                width: backButton.width
                height: backButton.height
                font.pointSize: mainStyle.font.size
                font.family: mainStyle.font.iconFont.name
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }



            MouseArea {
                id: backmouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                  stackView.pop()
                }
            }
        }

        Text {
            font.pointSize: mainStyle.font.size
            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
            x: backButton.x + backButton.width + mainStyle.dimens.leftMargin
            anchors.verticalCenter: parent.verticalCenter
            color: mainStyle.colors.toolbarText
            text: ( backButton.opacity ? (

              (

                (typeof stackView === 'object' ) &&
                (typeof stackView.currentItem === 'object' ) &&
                (stackView.currentItem !== null )

              ) ? ( title+": "+stackView.currentItem.title ) : title

            ) : title )
        }


        Rectangle {
            id: doneButton
            width: opacity ? mainStyle.dimens.nextButtonWidth : 0

            anchors.right: parent.right
            anchors.rightMargin: mainStyle.dimens.rightMargin
            opacity: ( (stackView.currentItem!==null) && (typeof stackView.currentItem.doneText==="string") && (stackView.currentItem.doneText!=="") ) ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            height: mainStyle.dimens.nextButtonHeight
            radius: 4
            color: backmouse.pressed ? mainStyle.colors.buttonPressed : "transparent"

            Behavior on opacity { NumberAnimation{  easing.type: Easing.InCubic; duration: 50 } }

            Text{
                text: ( (stackView.currentItem!==null)  && (typeof stackView.currentItem.doneText==="string"))?stackView.currentItem.doneText.substring(0,stackView.currentItem.doneText.length-1):""
                color: mainStyle.colors.toolbarNextIcon
                width: doneButton.width  - mainStyle.font.size
                height: doneButton.height
                font.pointSize: mainStyle.font.size
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }

            Text{
                text: ( (stackView.currentItem!==null)  && (typeof stackView.currentItem.doneText==="string"))?stackView.currentItem.doneText.substring(stackView.currentItem.doneText.length-1):""
                color: mainStyle.colors.toolbarNextIcon
                width: doneButton.width
                height: doneButton.height
                font.pointSize: mainStyle.font.size
                font.family: mainStyle.font.iconFont.name
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }


            MouseArea {
                property bool canClick: true
                id: donemouse
                Timer {
                  id: tmr
                  interval: 350
                  running: false
                  repeat: false
                  onTriggered: {
                     tmr.stop();
                     donemouse.canClick = true;
                  }
                }
                anchors.fill: parent
                //anchors.margins: -10
                onClicked: {

                    if (canClick){
                        canClick = false;
                        tmr.start();
                        if (typeof stackView.currentItem.onDoneClicked === "function"){
                            stackView.currentItem.onDoneClicked();
                        }
                    }
                    //stackView.pop()
                }
            }
        }

    }






}
