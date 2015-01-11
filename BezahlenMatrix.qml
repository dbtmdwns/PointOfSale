import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import "../../controlls"
import "../../views"
import "../../styles"
import "../../singleton"

MatrixField{

    Component.onCompleted: {

    }

    fields: [
        {
            displayImage: "qrc:/resources/image_source/500.svg",
            cmd: "ADDPAY",
            val: 500,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/200.svg",
            cmd: "ADDPAY",
            val: 200,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/100.svg",
            cmd: "ADDPAY",
            val: 100,
            displayColor:mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/50.svg",
            cmd: "ADDPAY",
            val: 50,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/20.svg",
            cmd: "ADDPAY",
            val: 20,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/10.svg",
            cmd: "ADDPAY",
            val: 10,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/5.svg",
            cmd: "ADDPAY",
            val: 5,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/2.svg",
            cmd: "ADDPAY",
            val: 2,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/1.svg",
            cmd: "ADDPAY",
            val: 1,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/_5.svg",
            cmd: "ADDPAY",
            val: 0.5,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/_2.svg",
            cmd: "ADDPAY",
            val: 0.2,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/_1.svg",
            cmd: "ADDPAY",
            val: 0.1,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/__5.svg",
            cmd: "ADDPAY",
            val: 0.05,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/__2.svg",
            cmd: "ADDPAY",
            val: 0.02,
            displayColor: mainStyle.colors.btnBackground
        },
        {
            displayImage: "qrc:/resources/image_source/__1.svg",
            cmd: "ADDPAY",
            val: 0.01,
            displayColor: mainStyle.colors.btnBackground
        }

    ]

    columns: 3
    rows: 5
}
