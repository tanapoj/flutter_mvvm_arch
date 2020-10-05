import 'dart:async';

/// Life Cycle Observer
abstract class LifeCycleObserver {
  void observeLiveData<T>(LiveData<T> lv);
}

/// Live Data Structure
class LiveData<T> {
  final String name;
  final T initialValue;
  StreamController<T> streamController;
  Stream<T> _stream;
  T _currentValue;

  LiveData(LifeCycleObserver lc, {T initValue, this.name, bool broadcast = true})
      : this.initialValue = initValue,
        this._currentValue = initValue {
    lc?.observeLiveData(this);
    if (broadcast) {
      streamController = StreamController<T>.broadcast();
    } else {
      streamController = StreamController<T>();
    }
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

  StreamSubscription<T> subscribe(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    return streamController.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
