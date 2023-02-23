class user {
  final int id;
  final String name;
  final String email;

  user({
    required this.id,
    required this.name,
    required this.email,
  });

  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: int.parse(json['UserId']),
      name: json['UserName'],
      email: json['UserEMail'],
    );
  }
}
