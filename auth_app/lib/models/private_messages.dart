class DirectMessages {
  String? type;
  String? data;
  String? room_name;
  String? user;
  String? target_user;
  String? msg_saw_by_tusr;
  String date_sended;

  DirectMessages(
      {this.type,
      this.data,
      this.room_name,
      this.user,
      this.target_user,
      this.msg_saw_by_tusr,
      required this.date_sended});

  factory DirectMessages.fromJson(Map<String, dynamic> json) => DirectMessages(
      type: json["type"],
      data: json["data"],
      room_name: json["room_name"],
      user: json["user"],
      target_user: json["target_user"],
      msg_saw_by_tusr: json["msg_saw_by_tusr"],
      date_sended: json["date_sended"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['data'] = this.data;
    data['room_name'] = this.room_name;
    data['user'] = this.user;
    data['target_user'] = this.target_user;
    data['msg_saw_by_tusr'] = this.msg_saw_by_tusr;
    data['date_sended'] = this.date_sended;
    return data;
  }
}
