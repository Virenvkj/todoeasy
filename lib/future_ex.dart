import 'package:flutter/material.dart';

class FutureEx extends StatefulWidget {
  const FutureEx({super.key});

  @override
  State<FutureEx> createState() => _FutureExState();
}

class _FutureExState extends State<FutureEx> {
  Future<String> fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    return 'Data is loaded';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Ex'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return Text(snapshot.requireData);
          },
        ),
      ),
    );
  }
}
