import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../../controlls"

StackViewItem {

    width: parent.width
    height: parent.height
    title: qsTr("About")

    ScrollView {
        anchors.fill: parent

        flickableItem.interactive: true

        contentItem :    Text {
            x: mainStyle.dimens.leftMargin
            width: root.width - mainStyle.dimens.leftMargin -mainStyle.dimens.rightMargin
            font.pixelSize: mainStyle.font.size
            color: mainStyle.colors.basicFontColor
            wrapMode: Text.WordWrap
            text: [
                "tualo solutions GmbH",
                "Im Maierhof 19",
                "72379 Hechingen",
                "",
                "http://tualo.de",
                "",
                "Lizenz",
                "======",
                "Dieses Programm ist unter GPLv3 lizensiert. Es darf weitergeben und verändert werden, solange jedem neuen Nutzer das gleiche Recht, bzw. die gleiche Lizenz, eingräumt wird.",
                "",
                "Mehr zu dieser Lizenz erfahren Sie unter:",
                "",
                " * http://www.gnu.org/licenses/gpl.html",
                "",
                "Quellcode",
                "======",
                "Den Quellcode zu dieser Anwendung erhalten Sie unter:",
                "",
                " * https://github.com/tualo/PointOfSale",
                "",
                "",
                "Datenschutz",
                "======",
                "Dieses Programm verarbeitet und übermittelt Daten, die gegebenenfalls personenbezogene Daten enthalten. Diese Daten werden nur während der Verarbeitung erhoben und an die angegebene URL übermittelt. Die Daten werden nicht in diesem Programm gespeichert. Der weitere Datenschutz obliegt somit beim Betreiber der URL.",
                "",
                "",
                ""

                "Weiter Lizenzen:",

                "(c) 2012 - 2015 Petr Kutalek: png2pos",

                "Licensed under the MIT License:",

                "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:",

                "- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.",

                "- THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
                
            ].join("\n")
        }
    }
}
