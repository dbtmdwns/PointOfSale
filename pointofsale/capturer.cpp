#include <QPixmap>
#include <QPainter>
#include <QStyleOptionGraphicsItem>

Capturer::Capturer(QObject *parent) :
    QObject(parent)
{

}


void Capturer::save(QQuickItem *item)
{
    QPixmap pix(item->width(), item->height());
    QPainter painter(&pix);
    QStyleOptionGraphicsItem option;
    item->paint(&painter, &option, NULL);
    pix.save("sample.png");
}

/*
void renderItem(QGraphicsItem* item, QPainter* painter,
QStyleOptionGraphicsItem* option,
const QTransform& baseTransform)
{
QTransform itemTransform = item->sceneTransform();
itemTransform *= baseTransform;
painter->setWorldTransform(itemTransform, false);
item->paint(painter, option, NULL);

// Recurse into children
//TODO this should be breadth-first not depth-first!
foreach ( QGraphicsItem* child, item->childItems() )
{
    renderItem(child, painter, option, baseTransform);
}
}

void Capture::save(QDeclarativeItem* item)
{
delete m_pixmap;
m_pixmap = NULL;

m_pixmap = new QPixmap(item->width(), item->height());
QPainter painter(m_pixmap);
QStyleOptionGraphicsItem option;

// Get the inverse transform of the root item's scene transform; all the
// children's transforms will be transformed by this in order to bring
// their coordinate systems from the scene space to the root item space
QTransform inverse = item->sceneTransform().inverted();

// Recursively render the item and all its children
renderItem(item, &painter, &option, inverse);
}
*/
