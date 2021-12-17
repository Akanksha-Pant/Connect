import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Components/UserCard.dart';
import 'package:connect_app/Models/User.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseServices dbServices = new DatabaseServices();
    return Scaffold(
      body:  StreamBuilder<QuerySnapshot>(
        stream: dbServices.getUsers(),
        builder: (context, snapshot){
          final List<DocumentSnapshot> documents = snapshot.data.docs;
          return ListView(
            children: documents.map((doc) => UserCard(new User.fromFireStore(doc.data()))).toList(),
          );
        },
      ),
    );;
  }
}

