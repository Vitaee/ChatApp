class MessageData {
  String? recvUsername;
  String? lastMessage;
  String? lastMessageDate;
  String? profilePic;
  //bool? isOnline;
  String? sawbyUser;
  String? currentUser;

  MessageData(
      {this.recvUsername,
      this.lastMessage,
      this.lastMessageDate,
      this.profilePic,
      //this.isOnline,
      this.sawbyUser,
      this.currentUser});

  MessageData.fromJson(Map<String, dynamic> json) {
    recvUsername = json['recvUsername'];
    lastMessage = json['lastMessage'];
    lastMessageDate = json['lastMessageDate'];
    profilePic = json['profilePic'];
    //isOnline = json['is_online'];
    sawbyUser = json['message_seen_by_tuser'];
    currentUser = json['currentUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['recvUsername'] = this.recvUsername;
    data['lastMessage'] = this.lastMessage;
    data['lastMessageDate'] = this.lastMessageDate;
    data['profilePic'] = this.profilePic;
    //data['is_online'] = this.isOnline;
    data['message_seen_by_tuser'] = this.sawbyUser;
    data['currentUser'] = this.currentUser;
    return data;
  }
}
