class JsonProperty<T> {
  final Map<String, dynamic> _json;
  final String _key;
  final T? _fallback;
  final T Function(dynamic raw)? _fromJson;
  final dynamic Function(T value)? _toJson;

  JsonProperty(
    this._json,
    this._key, {
    T? fallback,
    T Function(dynamic raw)? fromJson,
    dynamic Function(T value)? toJson,
  }) : _fallback = fallback,
       _fromJson = fromJson,
       _toJson = toJson;

  T get value {
    if (!_json.containsKey(_key)) {
      if (_fallback != null) return _fallback;
      throw StateError('Missing key `$_key`');
    }
    final raw = _json[_key];
    if (_fromJson != null) {
      // If fromJson is provided, use it to convert the raw value.
      return _fromJson(raw);
    }
    if (raw is T) {
      // If raw value is already of type T, return it directly.
      return raw;
    }
    if (_fallback != null) {
      // If raw value is not T and fromJson is not provided, use fallback if available.
      return _fallback;
    }
    // Fallback and custom fromJson not provided, and type mismatch.
    throw StateError('Expected `$_key` to be a $T but was ${raw.runtimeType}');
  }

  set value(T newValue) {
    if (_toJson != null) {
      _json[_key] = _toJson(newValue);
    } else {
      _json[_key] = newValue;
    }
  }
}

abstract class BaseJsonModel {
  final Map<String, dynamic> json;

  BaseJsonModel(this.json);

  /// Creates a JsonProperty for a basic type with optional fallback,
  /// custom deserialization, and custom serialization.
  JsonProperty<T> prop<T>(
    String key, {
    T? fallback,
    T Function(dynamic raw)? fromJson,
    dynamic Function(T value)? toJson,
  }) => JsonProperty<T>(
    json,
    key,
    fallback: fallback,
    fromJson: fromJson,
    toJson: toJson,
  );

  /// Creates a JsonProperty for a nested object extending BaseJsonModel,
  /// with an optional fallback object.
  JsonProperty<U?> obj<U extends BaseJsonModel>(
    String key, {
    required U Function(Map<String, dynamic>) fromJson,
    U? fallback, // Added optional fallback for obj
  }) => JsonProperty<U?>(
    json,
    key,
    fallback: fallback, // Pass fallback to JsonProperty
    fromJson: (raw) {
      if (raw is Map<String, dynamic>) return fromJson(raw);
      return null;
    },
    toJson: (model) => model?.toJson(),
  );

  /// Creates a JsonProperty for a list of nested objects extending BaseJsonModel,
  /// with an optional fallback list (defaults to an empty list).
  JsonProperty<List<U>> list<U extends BaseJsonModel>(
    String key, {
    required U Function(Map<String, dynamic>) fromJson,
    List<U>? fallback, // Added optional fallback for list
  }) => JsonProperty<List<U>>(
    json,
    key,
    fallback:
        fallback ?? <U>[], // Use provided fallback or default to empty list
    fromJson: (raw) {
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
      return <
        U
      >[]; // If raw is not a list, return an empty list based on common list behavior.
    },
    toJson: (models) => models.map((m) => m.toJson()).toList(),
  );

  Map<String, dynamic> toJson();
}
