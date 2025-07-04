import 'package:static_mapper/static_mapper.dart';

class User extends BaseJsonModel {
  late final id = prop<String>('id');
  late final name = prop<String>('name');
  late final age = prop<int>('age', fallback: 0);
  late final isActive = prop<bool>('isActive', fallback: false);

  User(super.json);

  factory User.fromJson(Map<String, dynamic> j) => User(j);

  @override
  Map<String, dynamic> toJson() => json;
}

void main() {
  final userJson = {'id': 'u001', 'name': 'Alice'};

  final user = User(userJson);

  print('ID: ${user.id.value}');
  print('Name: ${user.name.value}');
  print('Age: ${user.age.value}');
  print('Active: ${user.isActive.value}');

  user.age.value = 25;
  user.isActive.value = true;

  print('Updated JSON: ${user.toJson()}');
}
