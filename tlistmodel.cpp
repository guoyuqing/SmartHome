#include "tlistmodel.h"

#include <QDebug>

class TListModel::PrivateData {
public:
	QList<QObject *> list;
};

TListModel::TListModel(const QByteArray &role, QObject *parent) :
	QAbstractListModel(parent)
{
	d = new PrivateData;

	QHash<int, QByteArray> roles;
	roles[Qt::UserRole+1] = role;
	setRoleNames(roles);
}

TListModel::~TListModel() {
	delete d;
}

QVariant TListModel::data(const QModelIndex &index, int role) const {
	Q_UNUSED(role);
	return QVariant::fromValue(d->list.at(index.row()));
}

QVariant TListModel::get(int row) const {
	return this->data(this->index(row), Qt::DisplayRole);
}

void TListModel::append(QObject *v) {
	QList<QObject *> list;
	list << v;
	this->append(list);
}

void TListModel::append(const QList<QObject *> &objects) {
	beginInsertRows( QModelIndex(), d->list.size(), d->list.size() + objects.size() - 1);
	foreach(QObject *object, objects) {
		object->setParent(this);
		d->list << object;
	}
	endInsertRows();
}

int TListModel::rowCount(const QModelIndex &parent) const {
	Q_UNUSED(parent)
	return d->list.size();
}
