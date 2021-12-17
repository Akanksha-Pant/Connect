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
    check(interview);
    await interviewCollection.add(interview.toJson()).then((value) => (
        updateInterview(value.id.toString(), interview)
    ));
    interview.participants.forEach((participant) {
      addInterviewIdToUserCollection(interview.interview_id, participant);
    });
  }
  
  Future<void> updateInterview(String docRef, Interview interview) async{
    interview.setId(docRef);
    await interviewCollection.doc(docRef).update(interview.toJson());
  }

  Stream<QuerySnapshot> getInterviews(){
    return interviewCollection.snapshots();
  }

  void check(Interview interview){
    print("hello world");
    interview.participants.forEach((participant) {
      collection.doc(participant).get().then((value) {
        User user = User.fromFireStore(value.data());
        user.interviewIds.forEach((interviewId) {
          interviewCollection.doc(interviewId).get().then((value){
            Interview schedulledInterview = new Interview.fromFireStore(value.data());
            if(AppUtilityFunctions().intersects(interview.start_time, schedulledInterview.start_time, interview.start_time, schedulledInterview.end_time)){
              print("OOpppsss...looks like your friend already has an interview scheduled");
            }
            print(schedulledInterview.interview_id);
            print(schedulledInterview.end_time);
          });
        });
      });
    });
  }


  Future<void> addInterviewIdToUserCollection(String interviewId, String userId){
    collection.doc(userId).update({"interviews" : FieldValue.arrayUnion([interviewId])});
  }


}