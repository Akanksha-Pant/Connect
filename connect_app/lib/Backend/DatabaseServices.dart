import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';

class DatabaseServices{

  final CollectionReference collection = FirebaseFirestore.instance.collection("Users");
  final CollectionReference interviewCollection = FirebaseFirestore.instance.collection("Interviews");

  Stream<QuerySnapshot> getUsers() {
    return collection.snapshots();
  }

  Future<void> addInterview(Interview interview) async{
    await interviewCollection.add(interview.toJson()).then((value) => (
        updateInterview(value.id.toString(), interview)
    ));
    print(interview.toJson());
  }
  
  Future<void> updateInterview(String docRef, Interview interview) async{
    interview.setId(docRef);
    await interviewCollection.doc(docRef).update(interview.toJson());
    print(interview.toJson());
  }

  Stream<QuerySnapshot> getInterviews(){

  }

}