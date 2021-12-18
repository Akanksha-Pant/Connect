import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Backend/Exceptions/IntervieweeBusyException.dart';
import 'package:connect_app/Backend/Exceptions/RequiredLengthNotFound.dart';
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


  Future<List<Interview>> getInterviews(String userId) async{
    List<String > interviewIds = [];
    List<Interview>  interviews = [];

    await collection.doc(userId).get().then((value){
      User user = new User.fromFireStore(value.data());
      interviewIds = user.interviewIds;
    });
    for(var interviewId in interviewIds){
      await interviewCollection.doc(interviewId).get().then((value) {
        Interview interview = new Interview.fromFireStore(value.data());
        interviews.add(interview);
        print(interview.participants.toString());
      });
    }
    return interviews;
  }

  Future<void> addNewParticipants(Interview interview, List<String> newParticipants) async{
    Interview newInterview = interview;
    newInterview.setParticipants(newParticipants);
    await check(newInterview);

    for(String participant in newParticipants){
      collection.doc(participant).update({"interviews" : FieldValue.arrayUnion([interview.interview_id])});
    }

    interviewCollection.doc(interview.interview_id).update({"participants" : FieldValue.arrayUnion(interview.participants)});
  }

  Future<void> removeParticipants(Interview interview, List<String> participantsToBeRemoved){
    interviewCollection.doc(interview.interview_id).update({"participants" : FieldValue.arrayRemove(participantsToBeRemoved)});
    participantsToBeRemoved.forEach((participantId) {
      collection.doc(participantId).update({"interviews" : FieldValue.arrayRemove([interview.interview_id])});
    });
  }

  Future<void> updateTimings(Interview interview, DateTime startTime, DateTime endTime){
    check(interview);
    interviewCollection.doc(interview.interview_id).update({"start_time" : startTime.millisecondsSinceEpoch, "end_time" : endTime.millisecondsSinceEpoch});
    print("Timings updated Successfully");

  }


  Future<void> check(Interview interview) async {
    List<User> users = [];
    for(var participant in interview.participants){
      await collection.doc(participant).get().then((value) {
        User user = new User.fromFireStore(value.data());
        users.add(user);
      });
    }
    for(User user in users){
      for(String interviewId in user.interviewIds){
        await interviewCollection.doc(interviewId).get().then((value) {
          Interview schedulledInterview = new Interview.fromFireStore(value.data());
          if(AppUtilityFunctions().intersects(interview.start_time, schedulledInterview.start_time, interview.end_time, schedulledInterview.end_time)){

            throw  IntervieweeBusyException();
          }
        });
      }
    }
    if(interview.participants.length <= 3){
      throw  RequiredLengthNotFound();
    }
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

  Future<User> getUserbyId(String userId) async{
    User user ;
    await collection.doc(userId).get().then((value) {
      user = User.fromFireStore(value.data());
    });
    return user;
  }

}