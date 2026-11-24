import 'dart:convert';
import 'dart:io';

class JsonCollection {
  final String path;
  final List<Map<String, dynamic>> _items = [];

  int _lastId = 0;
  Future<void> _queue = Future<void>.value();

  JsonCollection(this.path);

  Future<void> load() async {
    final file = File(path);

    _items.clear();

    if (await file.exists()) {
      final text = await file.readAsString();

      if (text.trim().isNotEmpty) {
        final data = jsonDecode(text) as List<dynamic>;

        for (final element in data) {
          _items.add(
            Map<String, dynamic>.from(element as Map),
          );
        }
      }
    }

    _lastId = 0;

    for (final item in _items) {
      final id = item['id'] as int;

      if (id > _lastId) {
        _lastId = id;
      }
    }
  }

  List<Map<String, dynamic>> all() {
    return List.unmodifiable(_items);
  }

  int nextId() {
    return ++_lastId;
  }

  void add(Map<String, dynamic> item) {
    _items.add(item);
  }

  Future<void> save() {
    final snapshot = const JsonEncoder.withIndent('  ').convert(_items);

    final operation = _queue.then((_) => _write(snapshot));

    _queue = operation.catchError((_) {});

    return operation;
  }

  Future<void> _write(String content) async {
    final temporaryFile = File('$path.tmp');

    await temporaryFile.parent.create(recursive: true);
    await temporaryFile.writeAsString(content, flush: true);
    await temporaryFile.rename(path);
  }
}