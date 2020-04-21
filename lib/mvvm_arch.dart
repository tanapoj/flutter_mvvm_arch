library mvvm_arch;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'commons/bloc.dart' as bloc;
import 'commons/fp.dart';

import 'commons/lifecycle.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({Key key}) : super(key: key);

  @override
  State createState() => getView();

  View getView();
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {}

abstract class ViewControllerWidget extends BaseStatefulWidget {
  const ViewControllerWidget({Key key}) : super(key: key);
}

abstract class FragmentWidget extends BaseStatefulWidget {
  const FragmentWidget({Key key}) : super(key: key);
}

abstract class ViewModel {
  String get name => '{{sys.ui.ViewModel}}';

  void dispose() {}
}

class EmptyView extends Container {}

abstract class View<Base extends BaseStatefulWidget, VM extends ViewModel> extends State<Base>
    implements LifeCycleObserver {
  final List<LiveData> _liveData = [];

  VM $viewModel;

  String get name => '{{sys.ui.View}}';

  @override
  void dispose() {
    super.dispose();
    _liveData.forEach((liveData) {
      liveData?.dispose();
    });
    $viewModel?.dispose();
  }

  @override
  void observeLiveData<T>(LiveData<T> lv) {
    _liveData.add(lv);
  }

  @override
  Widget build(BuildContext context);

  Widget $watch<T>(
    LiveData<T> $viewModel, {
    @required Widget Function(BuildContext context, T value) builder,
  }) {
    return bloc.$watch($viewModel, builder: builder);
  }

  Widget $watchMerge<T>(
    Map<Symbol, LiveData<T>> $viewModel, {
    @required Widget Function(BuildContext context, Symbol symbol, T value) builder,
  }) {
    return bloc.$watchMerge($viewModel, builder: builder);
  }

  Widget $watchZip<T>(
    Map<Symbol, LiveData<T>> map, {
    @required Widget Function(BuildContext context, Memorize memorize) builder,
  }) {
    return bloc.$watchZip(map, builder: builder);
  }

  Widget $ifNot<T extends bool>(
    LiveData<T> $viewModel, {
    bool Function(T) predicate,
    @required Widget Function(BuildContext context, T value) builder,
  }) {
    return bloc.$if($viewModel, predicate: predicate, builder: builder);
  }

  Widget $if<T extends bool>(
    LiveData<T> $viewModel, {
    bool Function(T) predicate,
    @required Widget Function(BuildContext context, T value) builder,
    Widget Function(BuildContext context, T value) $else,
  }) {
    return bloc.$if($viewModel, predicate: predicate, builder: builder, $else: $else);
  }

  Widget $switch<T>(
    LiveData<T> $viewModel, {
    @required Map<T, Widget Function(BuildContext context, T value)> builders,
    Widget Function(BuildContext context, T value) $default,
  }) {
    return bloc.$switch($viewModel, builders: builders, $default: $default);
  }

  Widget $guard<T>(
    LiveData<T> $viewModel, {
    bool Function(T) check,
    @required Widget Function(BuildContext context, T value) $else,
    @required Widget Function(BuildContext context, T value) builder,
  }) {
    return bloc.$guard($viewModel, check: check, $else: $else, builder: builder);
  }
}
