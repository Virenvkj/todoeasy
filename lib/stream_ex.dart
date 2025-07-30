import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/models/user_details.dart';

class StreamEx extends StatefulWidget {
  const StreamEx({super.key});

  @override
  State<StreamEx> createState() => _StreamExState();
}

class _StreamExState extends State<StreamEx> {
  final firebaseFireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stream Ex'),
        ),
        body: Center(
          child: StreamBuilder(
            stream: firebaseFireStore
                .collection('/users')
                .doc('i9Eq1DFxtQDudlTqu4g2')
                .snapshots(),
            builder: (context, data) {
              if (data.hasData) {
                final userDetails =
                    UserDetails.fromJson(data.requireData.data()!);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(userDetails.firstName.toString()),
                    Text(userDetails.lastName.toString()),
                    Text(userDetails.email.toString()),
                    Text(userDetails.password.toString()),
                    Text(userDetails.uid.toString()),
                  ],
                );
              }
              return const Text('No data found');
            },
          ),
        ));
  }
}
