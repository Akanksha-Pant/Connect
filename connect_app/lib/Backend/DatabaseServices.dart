import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Models/User.dart';

class DatabaseServices{
  final CollectionReference collection = FirebaseFirestore.instance.collection("Users");

  Stream<QuerySnapshot> getUsers(){
    return collection.snapshots();
  }


}