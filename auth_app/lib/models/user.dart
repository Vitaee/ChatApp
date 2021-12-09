class User {
  String? username;
  String? email;
  String? image;

  User({this.username, this.email, this.image});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['image'] = this.image;
    return data;
  }
}
