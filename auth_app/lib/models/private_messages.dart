class DirectMessages {
  String? type;
  String? data;
  String? room_name;
  String? user;
  String? target_user;

  DirectMessages({
    this.type,
    this.data,
    this.room_name,
    this.user,
    this.target_user,
  });

  /*DirectMessages.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    data = json["data"];
    room_name = json["room_name"];
    user = json["user"];
    target_user = json["target_user"];
  }*/

  factory DirectMessages.fromJson(Map<String, dynamic> json) => DirectMessages(
      type: json["type"],
      data: json["data"],
      room_name: json["room_name"],
      user: json["user"],
      target_user: json["target_user"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['data'] = this.data;
    data['room_name'] = this.room_name;
    data['user'] = this.user;
    data['target_user'] = this.target_user;
    return data;
  }
}
