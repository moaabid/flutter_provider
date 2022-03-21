import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdate;
  BaseObject()
      : id = const Uuid().v4(),
        lastUpdate = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapStreamSubscription;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveStreamSubscription;

  CheapObject get cheapObject => _cheapObject;

  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapStreamSubscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });
    _expensiveStreamSubscription =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapStreamSubscription.cancel();
    _expensiveStreamSubscription.cancel();
  }
}
 
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
      ),
      body: Column(
        children: [
          Row(
            children: const [
              Expanded(child: CheapWidget()),
              Expanded(child: ExpensiveWidget()),
            ],
          ),
          Row(
            children: const [Expanded(child: ObjectProviderWidget())],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    context.read<ObjectProvider>().stop();
                  },
                  child: const Text('Stop')),
              TextButton(
                  onPressed: () {
                    context.read<ObjectProvider>().start();
                  },
                  child: const Text('Start'))
            ],
          ),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
        (provider) => provider._cheapObject);

    return Container(
      height: 100,
      color: Colors.yellow,
      child: Column(
        children: [
          const Text("Cheap Object"),
          const Text("Last Updated :"),
          Text(cheapObject.lastUpdate),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final objectProvider = context.watch<ObjectProvider>();

    return Container(
      height: 100,
      color: Colors.purple,
      child: Column(
        children: [
          const Text("Object Provider"),
          const Text("ID :"),
          Text(objectProvider.id),
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
        (provider) => provider._expensiveObject);

    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text("Cheap Object"),
          const Text("Last Updated :"),
          Text(expensiveObject.lastUpdate),
        ],
      ),
    );
  }
}
