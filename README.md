# static_mapper

A simple and flexible library for JSON mapping in Dart using static typed property access.

## ✨ Features

- Static-typed model mapping from JSON
- Fallback values for missing or invalid fields
- Nested object and list support
- Simple and composable design

## 🚀 Getting Started

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  static_mapper: latest
````

## 🔧 Define Models

```dart
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
```

## ✅ Usage Example

```dart
final userJson = {'id': '001', 'name': 'Bob'};
final user = User(userJson);

print(user.name.value);     // Bob
print(user.age.value);      // 0 (fallback)
user.age.value = 42;

print(user.toJson());       // {id: 001, name: Bob, age: 42, isActive: false}
```

## 🔄 Nested Models

```dart
class Post extends BaseJsonModel {
  late final title = prop<String>('title');
  late final author = obj<User>('author', fromJson: User.fromJson);

  Post(super.json);

  factory Post.fromJson(Map<String, dynamic> j) => Post(j);

  @override
  Map<String, dynamic> toJson() => json;
}
```

## 📄 License

MIT

-----

Made with ❤️ using Dart