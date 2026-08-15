class UserModel {
  String? uid;
  String? name;
  final String email;
  String? password;
  String? profilePicture;

  UserModel({
    this.uid,
    this.name,
    required this.email,
    this.password,
    this.profilePicture = 'null currently',
  });

  factory UserModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return UserModel(
      uid: json['uid'] ?? docId,
      name: json['name'],
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}
