import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

String now() => DateTime.now().toIso8601String();

@immutable
class Seconds {
  final String value;
  Seconds() : value = now();
}

@immutable
class Minutes {
  final String value;
  Minutes() : value = now();
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multi Provider"),
      ),
      body: MultiProvider(
        providers: [
          StreamProvider(
              create: (_) => Stream<Seconds>.periodic(
                  const Duration(seconds: 1), (_) => Seconds()),
              initialData: Seconds()),
          StreamProvider(
              create: (_) => Stream<Minutes>.periodic(
                  const Duration(minutes: 1), (_) => Minutes()),
              initialData: Minutes()),
        ],
        child: Row(
          children: const [
            Expanded(child: SecondsWidget()),
            Expanded(child: MinuteWidget())
          ],
        ),
      ),
    );
  }
}

class SecondsWidget extends StatelessWidget {
  const SecondsWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final seconds = context.watch<Seconds>();
    return Container(
      color: Colors.yellow,
      height: 100,
      child: Text(seconds.value),
    );
  }
}

class MinuteWidget extends StatelessWidget {
  const MinuteWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final minutes = context.watch<Minutes>();
    return Container(
      color: Colors.blue,
      height: 100,
      child: Text(minutes.value),
    );
  }
}
