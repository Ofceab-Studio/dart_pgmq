class User {
  const User({this.id});

  factory User.fromJson(Map json) => User(id: json['id']);

  final int? id;

  Map<String, dynamic> toJson() => {'id': id};
}

class CreateManyUserAndReturnOutputType {
  const CreateManyUserAndReturnOutputType({this.id});

  factory CreateManyUserAndReturnOutputType.fromJson(Map json) =>
      CreateManyUserAndReturnOutputType(id: json['id']);

  final int? id;

  Map<String, dynamic> toJson() => {'id': id};
}

class UpdateManyUserAndReturnOutputType {
  const UpdateManyUserAndReturnOutputType({this.id});

  factory UpdateManyUserAndReturnOutputType.fromJson(Map json) =>
      UpdateManyUserAndReturnOutputType(id: json['id']);

  final int? id;

  Map<String, dynamic> toJson() => {'id': id};
}
