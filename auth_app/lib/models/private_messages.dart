class DirectMessages {
  String? type;
  String? data;
  String? room_name;
  String? user;
  String? target_user;
  bool? message_seen_by_tuser;
  DateTime? date_sended;

  DirectMessages(
      {this.type,
      this.data,
      this.room_name,
      this.user,
      this.target_user,
      this.message_seen_by_tuser,
      this.date_sended});

  factory DirectMessages.fromJson(Map<String, dynamic> json) => DirectMessages(
      type: json["type"],
      data: json["data"],
      room_name: json["room_name"],
      user: json["user"],
      target_user: json["target_user"],
      message_seen_by_tuser: json["message_seen_by_tuser"],
      date_sended: json["date_sended"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['data'] = this.data;
    data['room_name'] = this.room_name;
    data['user'] = this.user;
    data['target_user'] = this.target_user;
    data['nessage_seen_by_tuser'] = this.message_seen_by_tuser;
    data['date_sended'] = this.date_sended;
    return data;
  }
}
