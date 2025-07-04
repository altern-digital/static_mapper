import 'package:static_mapper/static_mapper.dart';

/// Define a User model
class User extends BaseJsonModel {
  User(super.json);

  JsonProperty<String> get id => prop('id');
  JsonProperty<String> get name => prop('name');
  JsonProperty<int> get age => prop('age', fallback: 0);
  JsonProperty<bool> get isActive => prop('isActive', fallback: false);

  @override
  Map<String, dynamic> toJson() => json;
}

void main() {
  final userJson = {
    'id': 'u001',
    'name': 'Alice',
    // 'age' and 'isActive' are omitted to test fallbacks
  };

  final user = User(userJson);

  print('ID: ${user.id.value}'); // Output: ID: u001
  print('Name: ${user.name.value}'); // Output: Name: Alice
  print('Age: ${user.age.value}'); // Output: Age: 0
  print('Active: ${user.isActive.value}'); // Output: Active: false

  user.age.value = 25;
  user.isActive.value = true;

  print('Updated JSON: ${user.toJson()}');
}
