import 'dart:async';

import 'fp.dart';

abstract class LifeCycleObserver {
  void observeLiveData<T>(LiveData<T> lv);
}

class LiveData<T> {
  final String name;
  final T initialValue;
  StreamController<T> streamController;
  Stream<T> _stream;
  T _currentValue;

  String get _tag => '{{LiveData:$name}}';

  LiveData(LifeCycleObserver lc, {T initValue, this.name})
      : this.initialValue = initValue,
        this._currentValue = initValue {
    lc?.observeLiveData(this);
    streamController = StreamController<T>.broadcast();
  }

  LiveData.fromStream(Stream stream, {T initValue, this.name})
      : this._stream = stream,
        this.initialValue = initValue,
        this._currentValue = initValue;

  Stream<T> get stream => streamController?.stream ?? _stream;

  set value(T value) {
    this._currentValue = value;
    try {
      streamController?.add(value);
    } catch (e) {
      streamController?.close();
      streamController = null;
    }
  }

  T get value => this._currentValue;

  void dispose() {
    streamController.close();
  }

  ToggleableSubscriber<T> subscribe(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    return ToggleableSubscriber<T>.start(
      streamController.stream,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  // Helper

  LiveData<S> map<S>(S convert(T event), {S initialValue}) =>
      LiveData.fromStream(stream.map(convert), name: name, initValue: initialValue);

  static LiveData<T> merge<T>(
    Map<Symbol, Stream<T>> streamsMap, {
    String name,
    T initialValue,
  }) {
    return LiveData.fromStream(mergeSymbol(streamsMap), name: name, initValue: initialValue);
  }

  static LiveData<T> zipMemorize<T>(
    Map<Symbol, Stream<T>> streamsMap, {
    String name,
    T initialValue,
  }) {
    return LiveData.fromStream(memorizeBarrier(mergeSymbol(streamsMap)),
        name: name, initValue: initialValue);
  }
}

class ToggleableSubscriber<T> {
  bool enable = true;

  ToggleableSubscriber.start(
    Stream<T> stream,
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    try {
      stream.listen(
        (T event) {
          //print('enable $enable');
          if (!enable) return;
          onData(event);
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } catch (e) {
    }
  }

  ToggleableSubscriber pause() {
    enable = false;
    return this;
  }

  ToggleableSubscriber resume() {
    enable = true;
    return this;
  }
}
