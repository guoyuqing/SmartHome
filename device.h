#ifndef DEVICE_H
#define DEVICE_H

#include <QObject>
#include <QMetaType>
#include <QVariantMap>
#include <QDateTime>

class Device : public QObject
{
	Q_OBJECT
	Q_ENUMS(Type)
	Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
	Q_PROPERTY(bool isFavorite READ isFavorite WRITE setIsFavorite NOTIFY isFavoriteChanged)
	Q_PROPERTY(int methods READ methods WRITE setMethods NOTIFY methodsChanged)
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QDateTime nextRunTime READ nextRunTime NOTIFY nextRunTimeChanged)
	Q_PROPERTY(bool online READ online NOTIFY onlineChanged)
	Q_PROPERTY(int state READ state WRITE setState NOTIFY stateChanged)
	Q_PROPERTY(QString stateValue READ stateValue WRITE setStateValue NOTIFY stateValueChanged)
	Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)
public:
	explicit Device(QObject *parent = 0);
	~Device();

	enum Type { DeviceType, GroupType };

	int id() const;
	void setId(int id);

	bool isFavorite() const;
	void setIsFavorite(bool isFavorite);

	int methods() const;
	void setMethods(int methods);

	QString name() const;
	void setName(const QString &name);

	QDateTime nextRunTime() const;

	bool online() const;
	void setOnline(bool online);

	int state() const;
	void setState(int state);

	QString stateValue() const;
	void setStateValue(const QString &stateValue);

	Type type() const;
	void setType(Type type);
	void setType(const QString &type);

signals:
	void idChanged();
	void isFavoriteChanged();
	void methodsChanged();
	void nameChanged();
	void nextRunTimeChanged();
	void onlineChanged();
	void stateChanged();
	void stateValueChanged();
	void typeChanged();

public slots:
	void bell();
	void dim(char level);
	void turnOff();
	void turnOn();

protected:
	void sendMethod(int action, const QString &value = "");

protected slots:
	void onActionResponse(const QVariantMap &result, const QVariantMap &data);

private:
	class PrivateData;
	PrivateData *d;
};

Q_DECLARE_METATYPE(Device*)

#endif // DEVICE_H
