#include "friendrequestmodel.h"
#include "network/tcpsocket.h"
#include <QObject>
#include <QImage>
#include <QList>
#include "friendmodel.h"

namespace {
QString headCachePath = "/root/.config/OICQ/client/head";
}

FriendRequestModel::FriendRequestModel(QObject* parent)
    :_tcpSocket(&TcpSocket::singleTon()),
    _friendModel(&FriendModel::singleTon()),
    QAbstractListModel { parent }
{
    // 添加好友请求
    QObject::connect(_tcpSocket,
                     &TcpSocket::addFriendRequest,
                     this,
                     [this](const QJsonValue& jsonvalue, const QList<QImage>& images) {
                         QJsonArray jsonArray = jsonvalue.toArray();

                         if (jsonArray.size() != images.size()) {
                             return;
                         }

                         int i = 0;
                         beginResetModel();
                         for (const QJsonValue& jsonValue : jsonArray) {
                             if (!jsonValue.isObject()) {
                                 return;
                             }
                             QJsonObject obj = jsonValue.toObject();
                             Friend f;
                             f.name = obj.value("username").toString();
                             f.userid = obj.value("userid").toInt(); // 假设 userid 是 int 类型
                             QImage image = images[i++];
                             QString headpath = headCachePath + "/" + generateRandomAlphanumeric(10)
                                                + ".jpg";
                             image.save(headpath);
                             f.headPath = "file:///" + headpath;

                             friends.append(f);
                         }
                         endResetModel();
                     });
}

int FriendRequestModel::rowCount(const QModelIndex& parent) const
{
    return friends.length();
}

QVariant FriendRequestModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= friends.length()) {
        return QVariant("");
    }
    Friend f = friends.at(index.row());
    if (role == Qt::UserRole){
        return f.headPath;
    }else if (role == Qt::UserRole + 1){
        return f.name;
    }
    return QVariant("");
}

QHash<int, QByteArray> FriendRequestModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Qt::UserRole] = "headpath";
    roles[Qt::UserRole + 1] = "name";
    return roles;
}

//返回单例对象
FriendRequestModel& FriendRequestModel::singleTon()
{
    static FriendRequestModel frm(nullptr);
    return frm;
}

// 选择是否添加好友
// 发送两个学号,结果给服务端
void FriendRequestModel::choseAddFriend(int res, int index)
{
    QJsonObject sendObj;
    Friend nowf = friends.at(index);
    qint64 id =nowf.userid;
    beginResetModel();
    friends.remove(index);   //删除该条请求
    endResetModel();
    sendObj.insert("friendId", id);
    if (res == 0) {
        sendObj.insert("res", Fail); //拒绝添加
    }else{
        sendObj.insert("res", Success); //同意添加
        //直接在客户端加入 listView 的列表
        _friendModel->addNewFriend(nowf.name, id, nowf.headPath);

    }
    _tcpSocket->packingMessageFromJson(sendObj, AddFriendRes);
}
