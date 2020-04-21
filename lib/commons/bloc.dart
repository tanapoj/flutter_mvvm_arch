import 'package:flutter/material.dart';

import 'lifecycle.dart';
import 'fp.dart';
import '../mvvm_arch.dart' as core;

Widget $watch<T>(
  LiveData<T> liveData, {
  @required Widget Function(BuildContext context, T value) builder,
}) {
  assert(liveData != null,
      '\$watch on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');
  return StreamBuilder(
      stream: liveData.stream,
      initialData: liveData.initialValue,
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data ?? liveData.value ?? liveData.initialValue;
        //assert(value is T);
        return builder(context, value);
      });
}

Widget $watchMerge<T>(
  Map<Symbol, LiveData<T>> liveDataMap, {
  @required Widget Function(BuildContext context, Symbol symbol, T value) builder,
}) {
  assert(liveDataMap != null,
      '\$watchMerge on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');

  var combine = LiveData.merge(
    liveDataMap.map((symbol, liveData) => MapEntry(symbol, liveData.stream)),
  );

  return StreamBuilder(
      stream: combine.stream,
      initialData: null,
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data;
        Symbol s = value?.first as Symbol ?? null;
        var v = value?.second ?? null;
        return builder(context, s, v);
      });
}

Widget $watchZip<T>(
  Map<Symbol, LiveData<T>> liveDataMap, {
  @required Widget Function(BuildContext context, Memorize memorize) builder,
}) {
  assert(liveDataMap != null,
      '\$watchZip on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');

  var combine = LiveData.zipMemorize(
    liveDataMap.map((symbol, liveData) => MapEntry(symbol, liveData.stream)),
  );

  return StreamBuilder(
      stream: combine.stream,
      initialData: Memorize(),
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data;
        return builder(context, value);
      });
}

Widget $ifNot<T extends bool>(
  LiveData<T> liveData, {
  bool Function(T) predicate,
  @required Widget Function(BuildContext context, T value) builder,
}) {
  return $if(liveData, predicate: predicate, builder: builder);
}

Widget $if<T extends bool>(
  LiveData<T> liveData, {
  bool Function(T) predicate,
  @required Widget Function(BuildContext context, T value) builder,
  Widget Function(BuildContext context, T value) $else,
}) {
  assert(liveData != null,
      '\$if on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');
  return StreamBuilder(
      stream: liveData.stream,
      initialData: liveData.initialValue,
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data ?? liveData.value ?? liveData.initialValue;
        assert(value is T);
        if (predicate == null && value) {
          return builder(context, value);
        }
        if (predicate != null && predicate(value)) {
          return builder(context, value);
        }
        if ($else != null) {
          return $else(context, value);
        }
        return core.EmptyView();
      });
}

Widget $switch<T>(
  LiveData<T> liveData, {
  @required Map<T, Widget Function(BuildContext context, T value)> builders,
  Widget Function(BuildContext context, T value) $default,
}) {
  assert(liveData != null,
      '\$switch on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');
  return StreamBuilder(
      stream: liveData.stream,
      initialData: liveData.initialValue,
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data ?? liveData.value ?? liveData.initialValue;

        if (builders.containsKey(value)) {
          return builders[value](context, value);
        } else if ($default != null) {
          return $default(context, value);
        }
        return core.EmptyView();
      });
}

Widget $guard<T>(
  LiveData<T> liveData, {
  bool Function(T) check,
  @required Widget Function(BuildContext context, T value) $else,
  @required Widget Function(BuildContext context, T value) builder,
}) {
  assert(liveData != null,
      '\$guard on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again');
  check ??= (T t) => t != null;

  return StreamBuilder(
      stream: liveData.stream,
      initialData: liveData.initialValue,
      builder: (BuildContext context, snapshot) {
        var value = snapshot.data ?? liveData.value ?? liveData.initialValue;
        if (check(value)) {
          return builder(context, value);
        } else {
          return $else(context, value);
        }
      });
}
