import 'dart:convert';

class UserModel {
  final String uid;

  UserModel({
    required this.uid,
  });

  UserModel copyWith({
    String? uid,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'uid': uid});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() => 'UserModel(uid: $uid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

class UserData {
  final String email;
  final String password;

  UserData({required this.email, required this.password});
}
