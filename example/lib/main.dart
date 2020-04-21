import 'package:flutter/material.dart';
import 'package:mvvm_arch/commons/lifecycle.dart';
import 'package:mvvm_arch/mvvm_arch.dart' as ui;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomeViewController(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomeViewController extends ui.ViewControllerWidget {
  MyHomeViewController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ui.View getView() => _MyMainView();
}

class _MyMainView extends ui.View<MyHomeViewController, _MyMainViewModel> {
  _MyMainView() {
    $viewModel = _MyMainViewModel(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            $watch($viewModel.counter, builder: (BuildContext context, count) {
              return Text(
                '$count',
                style: Theme.of(context).textTheme.display1,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: $viewModel.incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _MyMainViewModel extends ui.ViewModel {
  final LiveData<int> counter;

  _MyMainViewModel(LifeCycleObserver observer) : counter = LiveData(observer, initValue: 1);

  void incrementCounter() {
    counter.value++;
  }
}
