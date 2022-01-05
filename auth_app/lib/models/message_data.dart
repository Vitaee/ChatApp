class MessageData {
  String? recvUsername;
  String? lastMessage;
  String? lastMessageDate;
  String? profilePic;
  bool? isOnline;
  bool? sawbyUser;
  String? currentUser;

  MessageData(
      {this.recvUsername,
      this.lastMessage,
      this.lastMessageDate,
      this.profilePic,
      this.isOnline,
      this.sawbyUser,
      this.currentUser});

  MessageData.fromJson(Map<String, dynamic> json) {
    recvUsername = json['recv_username'];
    lastMessage = json['last_message'];
    lastMessageDate = json['last_message_date'];
    profilePic = json['profile_pic'];
    isOnline = json['is_online'];
    sawbyUser = json['sawby_user'];
    currentUser = json['current_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['recv_username'] = this.recvUsername;
    data['last_message'] = this.lastMessage;
    data['last_message_date'] = this.lastMessageDate;
    data['profile_pic'] = this.profilePic;
    data['is_online'] = this.isOnline;
    data['sawby_user'] = this.sawbyUser;
    data['current_user'] = this.currentUser;
    return data;
  }
}
