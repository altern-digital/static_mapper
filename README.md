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
  User(super.json);

  JsonProperty<String> get id => prop('id');
  JsonProperty<String> get name => prop('name');
  JsonProperty<int> get age => prop('age', fallback: 0);
  JsonProperty<bool> get isActive => prop('isActive', fallback: false);

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
  Post(super.json);

  JsonProperty<String> get title => prop('title');
  JsonProperty<User?> get author => obj('author', fromJson: (json) => User(json));

  @override
  Map<String, dynamic> toJson() => json;
}
```

## 📄 License

MIT

---

Made with ❤️ using Dart