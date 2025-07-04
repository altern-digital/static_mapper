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
      return _fromJson(raw);
    }
    if (raw is T) {
      return raw;
    }
    if (_fallback != null) {
      return _fallback;
    }
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

  JsonProperty<U?> obj<U extends BaseJsonModel>(
    String key, {
    required U Function(Map<String, dynamic>) fromJson,
  }) => JsonProperty<U?>(
    json,
    key,
    fromJson: (raw) {
      if (raw is Map<String, dynamic>) return fromJson(raw);
      return null;
    },
    toJson: (model) => model?.toJson(),
  );

  JsonProperty<List<U>> list<U extends BaseJsonModel>(
    String key, {
    required U Function(Map<String, dynamic>) fromJson,
  }) => JsonProperty<List<U>>(
    json,
    key,
    fallback: <U>[],
    fromJson: (raw) {
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
      return <U>[];
    },
    toJson: (models) => models.map((m) => m.toJson()).toList(),
  );

  Map<String, dynamic> toJson();
}
