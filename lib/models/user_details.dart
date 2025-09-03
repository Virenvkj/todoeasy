import 'dart:convert';

UserDetails userDetailsFromJson(String str) =>
    UserDetails.fromJson(json.decode(str));

String userDetailsToJson(UserDetails data) => json.encode(data.toJson());

class UserDetails {
  final String uid;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  bool isGuest;

  UserDetails({
    required this.uid,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.isGuest = false,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
      uid: json["uid"],
      email: json["email"],
      password: json["password"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      isGuest: json["isGuest"]);

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "isGuest": isGuest,
      };

  Map<String, dynamic> profileNameToJson() => {
        "firstName": firstName,
        "lastName": lastName,
      };

  UserDetails copyWith({
    String? uid,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    bool? isGuest,
  }) {
    return UserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
