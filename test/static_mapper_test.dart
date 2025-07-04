import 'package:static_mapper/static_mapper.dart';
import 'package:test/test.dart';

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

class Address extends BaseJsonModel {
  late final street = prop<String>('street');
  late final city = prop<String>('city');
  late final zipCode = prop<String>('zipCode');

  Address(super.json);

  factory Address.fromJson(Map<String, dynamic> j) => Address(j);

  @override
  Map<String, dynamic> toJson() => json;
}

class Post extends BaseJsonModel {
  late final title = prop<String>('title');
  late final content = prop<String>('content');
  late final createdAt = prop<DateTime>(
    'createdAt',
    fromJson: (raw) => DateTime.parse(raw as String),
    toJson: (value) => value.toIso8601String(),
  );
  late final author = obj<User>('author', fromJson: User.fromJson);
  late final tags = prop<List<String>>('tags', fallback: []);
  late final addresses = list<Address>('addresses', fromJson: Address.fromJson);

  Post(super.json);

  factory Post.fromJson(Map<String, dynamic> j) => Post(j);

  @override
  Map<String, dynamic> toJson() => json;
}

void main() {
  group('JsonProperty', () {
    test('should get string value correctly', () {
      final json = {'name': 'Alice'};
      final prop = JsonProperty<String>(json, 'name');
      expect(prop.value, 'Alice');
    });

    test('should set string value correctly', () {
      final json = {'name': 'Alice'};
      final prop = JsonProperty<String>(json, 'name');
      prop.value = 'Bob';
      expect(json['name'], 'Bob');
    });

    test('should use fallback for missing key', () {
      final json = <String, dynamic>{};
      final prop = JsonProperty<String>(json, 'name', fallback: 'Guest');
      expect(prop.value, 'Guest');
    });

    test('should throw StateError for missing key without fallback', () {
      final json = <String, dynamic>{};
      final prop = JsonProperty<String>(json, 'name');
      expect(() => prop.value, throwsStateError);
    });

    test('should convert raw value using fromJson', () {
      final json = {'timestamp': '2023-01-01T10:00:00Z'};
      final prop = JsonProperty<DateTime>(
        json,
        'timestamp',
        fromJson: (raw) => DateTime.parse(raw as String),
      );
      expect(prop.value, DateTime.utc(2023, 1, 1, 10, 0, 0));
    });

    test('should convert value using toJson', () {
      final json = <String, dynamic>{};
      final prop = JsonProperty<DateTime>(
        json,
        'timestamp',
        toJson: (value) => value.toIso8601String(),
      );
      prop.value = DateTime.utc(2023, 1, 1, 10, 0, 0);
      expect(json['timestamp'], '2023-01-01T10:00:00.000Z');
    });

    test(
      'should throw StateError for type mismatch without fromJson or fallback',
      () {
        final json = {'age': 'twenty'};
        final prop = JsonProperty<int>(json, 'age');
        expect(() => prop.value, throwsStateError);
      },
    );

    test('should use fallback for type mismatch', () {
      final json = {'age': 'twenty'};
      final prop = JsonProperty<int>(json, 'age', fallback: 0);
      expect(prop.value, 0);
    });
  });

  group('BaseJsonModel and derived models', () {
    test('User model should parse basic properties', () {
      final userJson = {
        'id': '123',
        'name': 'Alice',
        'age': 30,
        'isActive': true,
      };
      final user = User(userJson);

      expect(user.id.value, '123');
      expect(user.name.value, 'Alice');
      expect(user.age.value, 30);
      expect(user.isActive.value, true);
    });

    test('User model should handle missing properties with fallback', () {
      final userJson = {'id': '456', 'name': 'Bob'};
      final user = User(userJson);

      expect(user.id.value, '456');
      expect(user.name.value, 'Bob');
      expect(user.age.value, 0);
      expect(user.isActive.value, false);
    });

    test('User model should update properties and reflect in json', () {
      final userJson = {
        'id': '123',
        'name': 'Alice',
        'age': 30,
        'isActive': true,
      };
      final user = User(userJson);

      user.name.value = 'Charlie';
      user.age.value = 31;
      user.isActive.value = false;

      expect(user.name.value, 'Charlie');
      expect(user.age.value, 31);
      expect(user.isActive.value, false);
      expect(user.json['name'], 'Charlie');
      expect(user.json['age'], 31);
      expect(user.json['isActive'], false);
    });

    test('Post model should parse nested object (author)', () {
      final postJson = {
        'title': 'My First Post',
        'content': 'Hello world!',
        'createdAt': '2024-07-04T14:30:00Z',
        'author': {'id': 'author1', 'name': 'John Doe', 'age': 40},
        'tags': ['dart', 'programming'],
        'addresses': [
          {'street': '123 Main St', 'city': 'Anytown', 'zipCode': '12345'},
        ],
      };
      final post = Post(postJson);

      expect(post.title.value, 'My First Post');
      expect(post.content.value, 'Hello world!');
      expect(post.createdAt.value, DateTime.utc(2024, 7, 4, 14, 30, 0));
      expect(post.tags.value, ['dart', 'programming']);

      final author = post.author.value;
      expect(author, isNotNull);
      expect(author!.id.value, 'author1');
      expect(author.name.value, 'John Doe');
      expect(author.age.value, 40);

      final addresses = post.addresses.value;
      expect(addresses.length, 1);
      expect(addresses[0].street.value, '123 Main St');
      expect(addresses[0].city.value, 'Anytown');
      expect(addresses[0].zipCode.value, '12345');
    });

    test('Post model should handle null nested object (author)', () {
      final postJson = {
        'title': 'Post without author',
        'content': 'Some content',
        'createdAt': '2024-07-04T15:00:00Z',
      };
      final post = Post(postJson);

      expect(post.author.value, isNull);
    });

    test('Post model should update nested object and reflect in json', () {
      final postJson = {
        'title': 'Original Post',
        'content': 'Original content',
        'createdAt': '2024-07-04T14:30:00Z',
        'author': {'id': 'author1', 'name': 'John Doe', 'age': 40},
        'tags': ['original'],
        'addresses': [
          {'street': '123 Main St', 'city': 'Anytown', 'zipCode': '12345'},
        ],
      };
      final post = Post(postJson);

      post.author.value?.name.value = 'Jane Smith';
      expect(post.author.value?.name.value, 'Jane Smith');
      expect(post.json['author']['name'], 'Jane Smith');

      final newAuthorJson = {'id': 'author2', 'name': 'New Author', 'age': 25};
      post.author.value = User(newAuthorJson);
      expect(post.author.value?.name.value, 'New Author');
      expect(post.json['author']['name'], 'New Author');
      expect(post.json['author']['id'], 'author2');

      post.tags.value = ['updated', 'tags'];
      expect(post.tags.value, ['updated', 'tags']);
      expect(post.json['tags'], ['updated', 'tags']);

      final newAddressJson = {
        'street': '456 Oak Ave',
        'city': 'Otherville',
        'zipCode': '67890',
      };
      post.addresses.value = [Address(newAddressJson)];
      expect(post.addresses.value.length, 1);
      expect(post.addresses.value[0].street.value, '456 Oak Ave');
      expect(post.json['addresses'][0]['street'], '456 Oak Ave');
    });

    test('Post model should handle empty list of addresses', () {
      final postJson = {
        'title': 'Post with no addresses',
        'content': 'Content',
        'createdAt': '2024-07-04T16:00:00Z',
        'addresses': [],
      };
      final post = Post(postJson);
      expect(post.addresses.value, isEmpty);
    });

    test('Post model should handle missing addresses key with fallback', () {
      final postJson = {
        'title': 'Post with missing addresses key',
        'content': 'Content',
        'createdAt': '2024-07-04T16:00:00Z',
      };
      final post = Post(postJson);
      expect(post.addresses.value, isEmpty);
    });

    test(
      'Post model should handle non-list for addresses key with fallback',
      () {
        final postJson = {
          'title': 'Post with invalid addresses type',
          'content': 'Content',
          'createdAt': '2024-07-04T16:00:00Z',
          'addresses': 'not a list',
        };
        final post = Post(postJson);
        expect(post.addresses.value, isEmpty);
      },
    );

    test('toJson method should return the underlying json map', () {
      final userJson = {'id': '789', 'name': 'Eve', 'age': 28};
      final user = User(userJson);
      expect(user.toJson(), userJson);

      final postJson = {
        'title': 'Test',
        'content': 'Test content',
        'createdAt': '2024-07-04T17:00:00Z',
      };
      final post = Post(postJson);
      expect(post.toJson(), postJson);
    });
  });
}
