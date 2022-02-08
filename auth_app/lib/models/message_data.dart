class MessageData {
  String? recvUsername;
  String? lastMessage;
  String? lastMessageDate;
  String? profilePic;
  //bool? isOnline;
  String? sawbyUser;
  String? currentUser;
  String? recvUsername1;

  MessageData(
      {this.recvUsername,
      this.lastMessage,
      this.lastMessageDate,
      this.profilePic,
      this.recvUsername1,
      //this.isOnline,
      this.sawbyUser,
      this.currentUser});

  MessageData.fromJson(Map<String, dynamic> json) {
    recvUsername = json['recvUsername'];
    lastMessage = json['lastMessage'];
    lastMessageDate = json['lastMessageDate'];
    profilePic = json['profilePic'];
    //isOnline = json['is_online'];
    sawbyUser = json['msg_saw_by_tusr'];
    currentUser = json['currentUser'];
    recvUsername1 = json['recvUsername1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['recvUsername'] = this.recvUsername;
    data['recvUsername1'] = this.recvUsername1;
    data['lastMessage'] = this.lastMessage;
    data['lastMessageDate'] = this.lastMessageDate;
    data['profilePic'] = this.profilePic;
    //data['is_online'] = this.isOnline;
    data['msg_saw_by_tusr'] = this.sawbyUser;
    data['currentUser'] = this.currentUser;
    return data;
  }
}
