import 'dart:convert';

UserDetails userDetailsFromJson(String str) =>
    UserDetails.fromJson(json.decode(str));

String userDetailsToJson(UserDetails data) => json.encode(data.toJson());

class UserDetails {
  final String uid;
  final String email;
  final String password;
  String? firstName;
  String? lastName;

  UserDetails({
    required this.uid,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        uid: json["uid"],
        email: json["email"],
        password: json["password"],
        firstName: json["firstName"],
        lastName: json["lastName"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
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
  }) {
    return UserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}
