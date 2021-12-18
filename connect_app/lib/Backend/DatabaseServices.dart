import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';

class DatabaseServices{

  final CollectionReference collection = FirebaseFirestore.instance.collection("Users");
  final CollectionReference interviewCollection = FirebaseFirestore.instance.collection("Interviews");

  Stream<QuerySnapshot> getUsers() {
    return collection.snapshots();
  }

  Future<void> addInterview(Interview interview) async{
    await check(interview);
    await interviewCollection.add(interview.toJson()).then((value) => (
        updateInterviewId(value.id.toString(), interview)
    ));
    interview.participants.forEach((participant) {
      addInterviewIdToUserCollection(interview.interview_id, participant);
    });
  }
  
  Future<void> updateInterviewId(String docRef, Interview interview) async{
    interview.setId(docRef);
    await interviewCollection.doc(docRef).update(interview.toJson());
  }


  List<Interview> getInterviews(String userId){
    List<Interview> interviewList = [];
    collection.doc(userId).get().then((value) {
      User currentUser = new User.fromFireStore(value.data());
      currentUser.interviewIds.forEach((interviewId) {
        interviewCollection.doc(interviewId).get().then((interview) {
          interviewList.add(new Interview.fromFireStore(interview.data()));
        });
      });
    });
    return interviewList;
  }

  void check(Interview interview) async {
    interview.participants.forEach((participant) {
      print("yessssssss");
      collection.doc(participant).get().then((value) {
        print(value.data());
        User user = User.fromFireStore(value.data());
        user.interviewIds.forEach((interviewId) {
          interviewCollection.doc(interviewId).get().then((value){
            Interview schedulledInterview = new Interview.fromFireStore(value.data());
            if(AppUtilityFunctions().intersects(interview.start_time, schedulledInterview.start_time, interview.end_time, schedulledInterview.end_time)){
              print("OOpppsss...looks like your friend already has an interview scheduled");
            }
          });
        });
      });
    });
  }

  Future<List<User>> getDummyUser() async{
    List<User> userList = [];
    await collection.get().then((value) => {
      value.docs.forEach((user) {
        userList.add(new User.fromFireStore(user.data()));
      })
    });
    return userList;
  }
  Future<void> addInterviewIdToUserCollection(String interviewId, String userId){
    collection.doc(userId).update({"interviews" : FieldValue.arrayUnion([interviewId])});
  }


}