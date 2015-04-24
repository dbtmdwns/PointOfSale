/****************************************************************************
** Meta object code from reading C++ file 'posprinter.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "posprinter.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'posprinter.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_PosPrinter_t {
    QByteArrayData data[13];
    char stringdata[109];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_PosPrinter_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_PosPrinter_t qt_meta_stringdata_PosPrinter = {
    {
QT_MOC_LITERAL(0, 0, 10), // "PosPrinter"
QT_MOC_LITERAL(1, 11, 11), // "allPrinters"
QT_MOC_LITERAL(2, 23, 0), // ""
QT_MOC_LITERAL(3, 24, 5), // "print"
QT_MOC_LITERAL(4, 30, 11), // "htmlContent"
QT_MOC_LITERAL(5, 42, 12), // "readLogoFile"
QT_MOC_LITERAL(6, 55, 10), // "openDrawer"
QT_MOC_LITERAL(7, 66, 3), // "cut"
QT_MOC_LITERAL(8, 70, 6), // "getEnv"
QT_MOC_LITERAL(9, 77, 4), // "name"
QT_MOC_LITERAL(10, 82, 12), // "defaultvalue"
QT_MOC_LITERAL(11, 95, 8), // "readFile"
QT_MOC_LITERAL(12, 104, 4) // "path"

    },
    "PosPrinter\0allPrinters\0\0print\0htmlContent\0"
    "readLogoFile\0openDrawer\0cut\0getEnv\0"
    "name\0defaultvalue\0readFile\0path"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_PosPrinter[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       7,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,   49,    2, 0x02 /* Public */,
       3,    1,   50,    2, 0x02 /* Public */,
       5,    0,   53,    2, 0x02 /* Public */,
       6,    0,   54,    2, 0x02 /* Public */,
       7,    0,   55,    2, 0x02 /* Public */,
       8,    2,   56,    2, 0x02 /* Public */,
      11,    1,   61,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::QString,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,    9,   10,
    QMetaType::QString, QMetaType::QString,   12,

       0        // eod
};

void PosPrinter::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        PosPrinter *_t = static_cast<PosPrinter *>(_o);
        switch (_id) {
        case 0: _t->allPrinters(); break;
        case 1: _t->print((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 2: { QString _r = _t->readLogoFile();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 3: _t->openDrawer(); break;
        case 4: _t->cut(); break;
        case 5: { QString _r = _t->getEnv((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 6: { QString _r = _t->readFile((*reinterpret_cast< QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        default: ;
        }
    }
}

const QMetaObject PosPrinter::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_PosPrinter.data,
      qt_meta_data_PosPrinter,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *PosPrinter::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *PosPrinter::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_PosPrinter.stringdata))
        return static_cast<void*>(const_cast< PosPrinter*>(this));
    return QObject::qt_metacast(_clname);
}

int PosPrinter::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 7)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 7;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 7)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 7;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
