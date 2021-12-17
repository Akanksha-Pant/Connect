import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Components/UserCard.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Screens/BookInterviewScreen.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseServices dbServices = new DatabaseServices();
    List<String> selectedUsers = <String>[];
    List<bool> isSelected = [];
    return Scaffold(
      body:  StreamBuilder<QuerySnapshot>(
        stream: dbServices.getUsers(),
        builder: (context, snapshot){
          final List<DocumentSnapshot> documents = snapshot.data.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index){
              User user = User.fromFireStore(documents[index].data());
              return InkWell(
                onTap: (){
                  selectedUsers.add(user.user_id);
                },
                child: UserCard(user),
              );

            },
            //children: documents.map((doc) => UserCard(new User.fromFireStore(doc.data()))).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookInterview(selectedUsers: selectedUsers,)),);
      }, child: Icon(Icons.navigate_next_sharp),),
    );;
  }
}

