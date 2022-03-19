import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Provider Example",
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        routes: {
          '/new': (context) => const AddNewBreadCrumb(),
        },
        home: const HomePage(),
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;

  BreadCrumb({required this.isActive, required this.name});

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BreadCrumb &&
        other.isActive == isActive &&
        other.name == name;
  }

  @override
  int get hashCode => isActive.hashCode ^ name.hashCode;

  String get title => name + (isActive ? '>' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _breadCrumbItems = [];

  UnmodifiableListView<BreadCrumb> get breadCrumbItems =>
      UnmodifiableListView(_breadCrumbItems);

  void addBreadCrumb(BreadCrumb breadCrumb) {
    for (final item in _breadCrumbItems) {
      item.activate();
    }
    _breadCrumbItems.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _breadCrumbItems.clear();
    notifyListeners();
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Consumer<BreadCrumbProvider>(
              builder: (context, ref, child) {
                return BreadCrumbWidget(breadCrumb: ref.breadCrumbItems);
              },
            ),
            TextButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(
                    '/new',
                  );
                },
                child: const Text('Add New BreadCrumb')),
            TextButton(
                onPressed: () {
                  final provider = context.read<BreadCrumbProvider>();
                  provider.reset();
                },
                child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}

class AddNewBreadCrumb extends StatefulWidget {
  const AddNewBreadCrumb({Key? key}) : super(key: key);

  @override
  State<AddNewBreadCrumb> createState() => _AddNewBreadCrumbState();
}

class _AddNewBreadCrumbState extends State<AddNewBreadCrumb> {
  late final TextEditingController _text;

  @override
  void initState() {
    _text = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bread Crumb'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _text,
              decoration: const InputDecoration(hintText: 'Bread crumb'),
            ),
            ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  context.read<BreadCrumbProvider>().addBreadCrumb(
                      BreadCrumb(isActive: false, name: _text.text));
                  Navigator.of(context).pop();
                })
          ],
        ),
      ),
    );
  }
}

class BreadCrumbWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumb;
  const BreadCrumbWidget({
    Key? key,
    required this.breadCrumb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumb.map((breadCrumb) {
        return Text(
          breadCrumb.title,
          style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black),
        );
      }).toList(),
    );
  }
}
