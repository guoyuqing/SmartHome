#include "commonview.h"
#include <QtDeclarative>
#include <QDesktopWidget>
#include <QGLWidget>
#include <QResizeEvent>
#include <QDesktopWidget>
#include "config.h"

#ifdef PLATFORM_BB10
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/Page>
#endif

class CommonView::PrivateData {
public:
	QDeclarativeView view;
};

CommonView::CommonView(QObject *parent) :
	AbstractView(parent)
{
	d = new PrivateData;
	d->view.installEventFilter(this);
	connect(QApplication::desktop(), SIGNAL(workAreaResized(int)), this, SLOT(workAreaResized(int)));

	d->view.setWindowTitle("Telldus Live! mobile");
	d->view.rootContext()->setContextProperty("HAVE_WEBKIT", HAVE_WEBKIT);

	d->view.setResizeMode(QDeclarativeView::SizeRootObjectToView);
	d->view.rootContext()->setContextProperty("SCALEFACTOR", 1);  // Default value, resizeEvent() overrides this
}

CommonView::~CommonView() {
	delete d;
}

void CommonView::loadAndShow() {
#if defined(PLATFORM_DESKTOP)
	d->view.show();
	int w = 0, h = 0;
	QStringList args = QCoreApplication::arguments();
	for(int i = 1; i < args.length(); ++i) {
		if (args.at(i) == "--width") {
			w = args.at(i+1).toInt();
			++i;
			continue;
		} else if (args.at(i) == "--height") {
			h = args.at(i+1).toInt();
			++i;
			continue;
		}
	}
	QSize size(w, h);
	if (w > 0 && h > 0) {
		d->view.setFixedSize(size);
	}
#elif defined(PLATFORM_IOS)
	QSize size(this->windowSize());
	d->view.show();
	d->view.resize(size);
#elif defined(PLATFORM_BB10)
#else
	QRect r(QApplication::desktop()->availableGeometry());
	QSize size(r.width(), r.height());
	d->view.show();
#endif

#ifdef PLATFORM_BB10
/*	QDeclarativeEngine *engine = bb::cascades::QmlDocument::defaultDeclarativeEngine();
	engine->addImportPath(QString("%1/app/native/assets/import").arg(QDir::currentPath()));
	d->qml = bb::cascades::QmlDocument::create("asset:///main.qml");
	if (!d->qml->hasErrors()) {
		bb::cascades::Page *page = d->qml->createRootObject<bb::cascades::Page>();
		if (page) {
			bb::cascades::Application::instance()->setScene(page);
		}
	} else {
		qDebug() << "Could not load qml files:" << d->qml->errors();
	}*/
#else
	d->view.rootContext()->setContextProperty("HEIGHT", size.height());
	d->view.rootContext()->setContextProperty("WIDTH", size.width());
	d->view.engine()->addImportPath(":/qmllib/common");
	d->view.setSource(QUrl("qrc:/phone/main.qml"));
#endif

#ifdef PLATFORM_BB10
//	this->resize(size);
#endif
}

void CommonView::setContextProperty(const QString &name, QObject *value) {
	d->view.rootContext()->setContextProperty(name, value);
}

void CommonView::workAreaResized(int screen) {
	QRect r(QApplication::desktop()->availableGeometry());
	d->view.resize(r.width(), r.height());
}

bool CommonView::eventFilter( QObject *obj, QEvent * event ) {
	if (event->type() != QEvent::Resize) {
		return QObject::eventFilter(obj, event);
	}
	QResizeEvent *resizeEvent = static_cast<QResizeEvent *>(event);

	QSize s = resizeEvent->size();
	if (s.width() == 0 || s.height() == 0) {
		return QObject::eventFilter(obj, event);
	}

	double scaleFactor = 1;
	if (s.width() < 450) {
		scaleFactor = 0.5;
	} else if (s.width() < 600) {
		scaleFactor = 0.75;
	}
	d->view.rootContext()->setContextProperty("SCALEFACTOR", scaleFactor);
	return QObject::eventFilter(obj, event);
}

//void CommonView::changeEvent(QEvent *event) {
	//QDeclarativeView::changeEvent(event);
	/*if (event->type() == QEvent::WindowStateChange) {
		if (this->windowState() == Qt::WindowFullScreen) {
			emit fullscreen();
		}
	}*/
//}

