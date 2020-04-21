import 'package:async/async.dart' show StreamGroup;

class Pair<F extends dynamic, S extends dynamic> {
  final F first;
  final S second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair{(${first.runtimeType}) $first, (${second.runtimeType}) $second}';
  }
}

class Memorize {
  final Map<Symbol, dynamic> _symbol = {};

  T put<T>(Symbol symbol, T value) {
    _symbol[symbol] = value;
    return value;
  }

  T get<T>(Symbol symbol) => _symbol.containsKey(symbol) ? _symbol[symbol] : null;

  dynamic operator [](Symbol symbol) => get(symbol);

  static Memorize from(Memorize memorize) => memorize ?? Memorize();

  Map<Symbol, dynamic> toMap() => _symbol;

  @override
  String toString() {
    return 'Memorize{$_symbol}';
  }
}

Stream<Pair<Symbol, T>> mergeSymbol<T>(Map<Symbol, Stream<T>> streamsMap) {
  var s = streamsMap.map((name, streams) {
    return MapEntry(name, streams.map((stream) => Pair(name, stream)));
  }).values;
  return StreamGroup.merge(s);
}

Stream<Memorize> memorizeBarrier<T>(Stream<Pair<Symbol, T>> streams) {
  var mem = Memorize();
  return streams.map((pair) {
    mem.put(pair.first, pair.second);
    return mem;
  });
}

extension TransformFuture<I> on Future<I> {
  Future<O> flatMap<O>(O Function(I data) mapper) async {
    var oldRes = await this;
    var newRes = mapper(oldRes);
    return newRes;
  }
}
