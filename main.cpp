#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
	QGuiApplication::setApplicationName("ShaderPlot");
	QGuiApplication::setOrganizationName("Yakumo");
	QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication app(argc, argv);

	QQuickStyle::setStyle("Material");

	QQmlApplicationEngine engine;
	engine.load(QUrl(QLatin1String("qrc:/qml/app.qml")));

	return app.exec();
}
